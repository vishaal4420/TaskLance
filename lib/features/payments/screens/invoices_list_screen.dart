import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/cards.dart';
import '../../../core/widgets/shimmer_widgets.dart';
import '../../../core/widgets/empty_error_states.dart';
import '../../../core/utils/currency_formatter.dart';
import '../providers/invoice_providers.dart';
import '../../../models/invoice.dart';
import '../../../models/user.dart';
import '../../auth/providers/auth_providers.dart';

class InvoicesListScreen extends ConsumerStatefulWidget {
  const InvoicesListScreen({super.key});

  @override
  ConsumerState<InvoicesListScreen> createState() => _InvoicesListScreenState();
}

class _InvoicesListScreenState extends ConsumerState<InvoicesListScreen> {
  InvoiceStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(invoicesProvider);

    final invoices = invoicesAsync.valueOrNull ?? [];

    final total = invoices.fold(0.0, (s, i) => s + i.total);
    final paid = invoices
        .where((i) => i.status == InvoiceStatus.paid)
        .fold(0.0, (s, i) => s + i.total);
    final overdue = invoices
        .where((i) => i.status == InvoiceStatus.overdue)
        .fold(0.0, (s, i) => s + i.total);

    return Scaffold(
      floatingActionButton: ref.watch(currentUserRoleProvider) == UserRole.freelancer
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/invoices/create'),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text('New Invoice', style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
            )
          : null,
      appBar: AppBar(title: const Text('Invoices')),
      body: Column(
        children: [
          // Summary strip
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _SummaryItem(label: 'Total', value: CurrencyFormatter.format(total), color: Colors.white),
                const _Divider(),
                _SummaryItem(label: 'Paid', value: CurrencyFormatter.format(paid), color: AppColors.secondaryLight),
                const _Divider(),
                _SummaryItem(label: 'Overdue', value: CurrencyFormatter.format(overdue), color: Colors.redAccent.shade100),
              ],
            ),
          ),
          // Filter chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final f in [null, InvoiceStatus.draft, InvoiceStatus.sent, InvoiceStatus.paid, InvoiceStatus.overdue])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        f == null ? 'All' : f.name[0].toUpperCase() + f.name.substring(1),
                        style: AppTextStyles.labelMedium.copyWith(
                          color: _filter == f
                              ? AppColors.primary
                              : Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                        ),
                      ),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                      selectedColor: AppColors.primary.withAlpha(38),
                      checkmarkColor: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: invoicesAsync.when(
              loading: () => const Padding(padding: EdgeInsets.all(16), child: ShimmerList(count: 3, itemHeight: 80)),
              error: (e, _) => ErrorState(message: e.toString()),
              data: (invoices) {
                final filtered = _filter == null ? invoices : invoices.where((i) => i.status == _filter).toList();
                if (filtered.isEmpty) {
                  return EmptyState(
                    title: 'No Invoices',
                    subtitle: 'Create your first invoice',
                    lottieAsset: 'assets/lottie/no_invoices.json',
                    actionLabel: 'Create Invoice',
                    onAction: () => context.push('/invoices/create'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => InvoiceCard(
                    invoice: filtered[i],
                    onTap: () => context.push('/invoices/${filtered[i].id}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label, value;
  final Color color;

  const _SummaryItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.titleLarge.copyWith(color: color)),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: Colors.white60)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 8));
  }
}
