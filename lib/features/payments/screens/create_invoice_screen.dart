import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/success_dialog.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/utils/currency_formatter.dart';
import 'package:uuid/uuid.dart';
import '../../../models/invoice.dart';
import '../../../models/project.dart';
import '../../auth/providers/auth_providers.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../providers/invoice_providers.dart';

class CreateInvoiceScreen extends ConsumerStatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  ConsumerState<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taxCtrl = TextEditingController(text: '0');
  final _discCtrl = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();
  ProjectModel? _selectedProject;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 14));

  final List<_LineItem> _lineItems = [
    _LineItem(desc: 'Discovery & Design System', qty: 1, price: 1500),
  ];

  double get _subtotal => _lineItems.fold(0, (s, i) => s + i.qty * i.price);
  double get _taxAmount => _subtotal * (double.tryParse(_taxCtrl.text) ?? 0) / 100;
  double get _discAmount => _subtotal * (double.tryParse(_discCtrl.text) ?? 0) / 100;
  double get _total => _subtotal + _taxAmount - _discAmount;

  @override
  void dispose() {
    _taxCtrl.dispose();
    _discCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(bool send) async {
    if (_selectedProject == null) {
      AppSnackBar.error(context, 'Please select a project to bill.');
      return;
    }

    if (_lineItems.isEmpty || _lineItems.every((e) => e.desc.trim().isEmpty)) {
      AppSnackBar.error(context, 'Please add at least one line item.');
      return;
    }

    try {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) throw Exception('Not logged in');

      final invoiceId = const Uuid().v4();
      final invoiceNum = 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final newInvoice = InvoiceModel(
        id: invoiceId,
        invoiceNumber: invoiceNum,
        projectId: _selectedProject!.id,
        projectName: _selectedProject!.title,
        freelancerUid: user.uid,
        clientUid: _selectedProject!.clientUid,
        clientName: _selectedProject!.clientName ?? 'Client',
        lineItems: _lineItems.map((e) => InvoiceLineItem(
          description: e.desc,
          quantity: e.qty.toDouble(),
          unitPrice: e.price,
        )).toList(),
        taxPercent: double.tryParse(_taxCtrl.text) ?? 0,
        discountPercent: double.tryParse(_discCtrl.text) ?? 0,
        notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
        dueDate: _dueDate,
        createdAt: DateTime.now(),
        status: send ? InvoiceStatus.sent : InvoiceStatus.draft,
      );

      await ref.read(invoiceRepositoryProvider).createInvoice(newInvoice);

      if (!mounted) return;
      SuccessDialog.show(
        context,
        title: send ? 'Invoice Sent' : 'Draft Saved',
        message: send ? 'Invoice has been sent to the client.' : 'Your invoice draft has been saved.',
        onOk: () {
          context.pop();
          context.pop();
        },
      );
    } catch (e) {
      AppSnackBar.error(context, 'Error saving invoice: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(dashboardProjectsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('New Invoice')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Client selector
            _Section(
              title: 'Bill To (Project)',
              child: projectsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error loading projects: $e'),
                data: (projects) {
                  final activeProjects = projects.where((p) => p.status == ProjectStatus.active).toList();
                  if (activeProjects.isEmpty) {
                    return const Text('No active projects found to bill.');
                  }
                  
                  return GestureDetector(
                    onTap: () => _showProjectPicker(context, activeProjects),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      ),
                      child: _selectedProject == null
                          ? Row(children: [
                              const Icon(Icons.folder_outlined, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text('Select Project', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
                            ])
                          : Row(children: [
                              AvatarWidget(name: _selectedProject!.clientName ?? 'Client', size: 36, url: _selectedProject!.clientAvatarUrl),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(_selectedProject!.clientName ?? 'Client', style: AppTextStyles.titleSmall),
                                  Text(_selectedProject!.title, style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight), overflow: TextOverflow.ellipsis),
                                ]),
                              ),
                            ]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Line items
            _Section(
              title: 'Line Items',
              child: Column(
                children: [
                  // Header
                  Row(children: [
                    const Expanded(flex: 4, child: Text('Description', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                    const Expanded(child: Text('Qty', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center)),
                    const Expanded(flex: 2, child: Text('Price', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.right)),
                    const SizedBox(width: 32),
                  ]),
                  const Divider(height: 12),
                  ...List.generate(_lineItems.length, (i) => _LineItemRow(
                    item: _lineItems[i],
                    onChanged: () => setState(() {}),
                    onDelete: () => setState(() => _lineItems.removeAt(i)),
                  )),
                  TextButton.icon(
                    onPressed: () => setState(() => _lineItems.add(_LineItem(desc: '', qty: 1, price: 0))),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Line Item'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Tax %',
                    controller: _taxCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Discount %',
                    controller: _discCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Due date
            OutlinedButton.icon(
              onPressed: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (d != null) setState(() => _dueDate = d);
              },
              icon: const Icon(Icons.calendar_today_rounded, size: 16),
              label: Text('Due: ${_dueDate.day}/${_dueDate.month}/${_dueDate.year}'),
            ),
            const SizedBox(height: 16),
            AppTextField(label: 'Notes', controller: _notesCtrl, maxLines: 3),
            const SizedBox(height: 16),
            // Summary
            _Section(
              title: 'Summary',
              child: Column(
                children: [
                  _SummaryRow(label: 'Subtotal', value: CurrencyFormatter.format(_subtotal)),
                  if (_taxAmount > 0) _SummaryRow(label: 'Tax', value: '+${CurrencyFormatter.format(_taxAmount)}'),
                  if (_discAmount > 0) _SummaryRow(label: 'Discount', value: '-${CurrencyFormatter.format(_discAmount)}'),
                  const Divider(height: 16),
                  _SummaryRow(
                    label: 'Total',
                    value: CurrencyFormatter.format(_total),
                    bold: true,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _save(false),
                    child: const Text('Save Draft'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _save(true),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    child: const Text('Send Invoice'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showProjectPicker(BuildContext context, List<ProjectModel> projects) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: projects.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) return Padding(padding: const EdgeInsets.only(bottom: 12), child: Text('Select Project', style: AppTextStyles.headlineSmall));
          final project = projects[i - 1];
          return ListTile(
            leading: AvatarWidget(name: project.clientName ?? 'Client', size: 40, url: project.clientAvatarUrl),
            title: Text(project.clientName ?? 'Client'),
            subtitle: Text(project.title),
            onTap: () { setState(() => _selectedProject = project); Navigator.pop(context); },
          );
        },
      ),
    );
  }
}

class _LineItem {
  String desc;
  int qty;
  double price;

  _LineItem({required this.desc, required this.qty, required this.price});
}

class _LineItemRow extends StatelessWidget {
  final _LineItem item;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  const _LineItemRow({required this.item, required this.onChanged, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 4, 
            child: AppTextField(
              label: 'Item description',
              initialValue: item.desc,
              onChanged: (v) { item.desc = v; onChanged(); },
            )
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppTextField(
              label: '1',
              initialValue: item.qty.toString(),
              keyboardType: TextInputType.number,
              onChanged: (v) { item.qty = int.tryParse(v) ?? 1; onChanged(); },
            )
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2, 
            child: AppTextField(
              label: '0.00',
              initialValue: item.price.toString(),
              keyboardType: TextInputType.number,
              onChanged: (v) { item.price = double.tryParse(v) ?? 0.0; onChanged(); },
            )
          ),
          IconButton(icon: const Icon(Icons.close, size: 16), onPressed: onDelete, color: AppColors.error),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  final Color? color;

  const _SummaryRow({required this.label, required this.value, this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? AppTextStyles.titleMedium.copyWith(color: color)
        : AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label, style: style),
          const Spacer(),
          Text(value, style: style),
        ],
      ),
    );
  }
}
