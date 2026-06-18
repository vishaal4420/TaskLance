import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/shimmer_widgets.dart';
import '../../../core/widgets/empty_error_states.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/utils/currency_formatter.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../providers/invoice_providers.dart';
import '../../../models/invoice.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../models/user.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/success_dialog.dart';
import 'mock_payment_modal.dart';

class InvoiceDetailScreen extends ConsumerStatefulWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _markAsPaid() async {
    try {
      await ref.read(invoiceRepositoryProvider).updateInvoiceStatus(widget.invoiceId, InvoiceStatus.paid);
      if (!mounted) return;
      SuccessDialog.show(
        context,
        title: 'Payment Successful',
        message: 'Invoice has been paid successfully.',
        onOk: () => context.pop(),
      );
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Error updating status: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _markAsPaid();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    AppSnackBar.error(context, 'Payment failed: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    AppSnackBar.error(context, 'External wallet selected: ${response.walletName}');
  }

  void _openCheckout(InvoiceModel invoice) {
    MockPaymentModal.show(
      context,
      amount: invoice.total,
      projectName: invoice.projectName,
      onSuccess: () {
        if (mounted) _markAsPaid();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final invoiceAsync = ref.watch(invoiceDetailProvider(widget.invoiceId));

    return invoiceAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: ShimmerList(count: 4, itemHeight: 80),
        ),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorState(message: e.toString()),
      ),
      data: (invoice) {
        if (invoice == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const ErrorState(message: 'Invoice not found'),
          );
        }

        final role = ref.watch(currentUserRoleProvider);
        final isClient = role == UserRole.client;

        void handleShare() {
          final shareUrl = 'https://tasklance.app/invoices/${invoice.id}.pdf';
          Share.share('Here is your invoice #${invoice.invoiceNumber} from TaskLance: $shareUrl');
        }

        void handleDownload() async {
          final downloadUrl = 'https://tasklance.app/invoices/${invoice.id}.pdf';
          final Uri url = Uri.parse(downloadUrl);
          try {
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            } else {
              if (context.mounted) AppSnackBar.error(context, 'Could not launch download link');
            }
          } catch (e) {
            if (context.mounted) AppSnackBar.error(context, 'Invalid download URL');
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Invoice #${invoice.invoiceNumber}'),
            actions: [
              IconButton(
                tooltip: 'Download',
                icon: const Icon(Icons.download_rounded),
                onPressed: handleDownload,
              ),
              IconButton(
                tooltip: 'Share',
                icon: const Icon(Icons.share_rounded),
                onPressed: handleShare,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Amount', style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                        const SizedBox(height: 4),
                        Text(CurrencyFormatter.format(invoice.total), style: AppTextStyles.displayMedium.copyWith(color: AppColors.primary)),
                      ],
                    ),
                    StatusChip.fromInvoiceStatus(invoice.status),
                  ],
                ),
                const SizedBox(height: 24),
                // Client Info
                _Section(
                  title: 'Billed To',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(invoice.clientName, style: AppTextStyles.titleMedium),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Dates
                Row(
                  children: [
                    Expanded(
                      child: _Section(
                        title: 'Issued Date',
                        child: Text('${invoice.createdAt.day}/${invoice.createdAt.month}/${invoice.createdAt.year}', style: AppTextStyles.bodyMedium),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _Section(
                        title: 'Due Date',
                        child: Text('${invoice.dueDate.day}/${invoice.dueDate.month}/${invoice.dueDate.year}', style: AppTextStyles.bodyMedium),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Items
                _Section(
                  title: 'Line Items',
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Expanded(flex: 3, child: Text('Item', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                          Expanded(child: Text('Qty', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center)),
                          Expanded(flex: 2, child: Text('Amount', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.right)),
                        ],
                      ),
                      const Divider(height: 16),
                      ...invoice.lineItems.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(flex: 3, child: Text(item.description, style: AppTextStyles.bodySmall)),
                            Expanded(child: Text(item.quantity.toString(), textAlign: TextAlign.center, style: AppTextStyles.bodySmall)),
                            Expanded(flex: 2, child: Text(CurrencyFormatter.format(item.total), textAlign: TextAlign.right, style: AppTextStyles.bodySmall)),
                          ],
                        ),
                      )),
                      const Divider(height: 24),
                      _SummaryRow(label: 'Subtotal', value: CurrencyFormatter.format(invoice.subtotal)),
                      if (invoice.taxAmount > 0) _SummaryRow(label: 'Tax', value: '+${CurrencyFormatter.format(invoice.taxAmount)}'),
                      if (invoice.discountAmount > 0) _SummaryRow(label: 'Discount', value: '-${CurrencyFormatter.format(invoice.discountAmount)}'),
                      const SizedBox(height: 8),
                      _SummaryRow(label: 'Total', value: CurrencyFormatter.format(invoice.total), bold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (invoice.notes != null)
                  _Section(
                    title: 'Notes',
                    child: Text(invoice.notes!, style: AppTextStyles.bodySmall),
                  ),
                const SizedBox(height: 32),
                if (!isClient && invoice.status == InvoiceStatus.draft)
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await ref.read(invoiceRepositoryProvider).updateInvoiceStatus(invoice.id, InvoiceStatus.sent);
                        if (context.mounted) AppSnackBar.success(context, 'Invoice sent!');
                      } catch (e) {
                        if (context.mounted) AppSnackBar.error(context, 'Error sending invoice: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Send Invoice'),
                  )
                else if (!isClient && (invoice.status == InvoiceStatus.sent || invoice.status == InvoiceStatus.viewed || invoice.status == InvoiceStatus.overdue))
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await ref.read(invoiceRepositoryProvider).updateInvoiceStatus(invoice.id, InvoiceStatus.paid);
                        if (context.mounted) AppSnackBar.success(context, 'Marked as paid!');
                      } catch (e) {
                        if (context.mounted) AppSnackBar.error(context, 'Error updating status: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Mark as Paid'),
                  )
                else if (isClient && (invoice.status == InvoiceStatus.sent || invoice.status == InvoiceStatus.viewed || invoice.status == InvoiceStatus.overdue))
                  ElevatedButton(
                    onPressed: () {
                      _openCheckout(invoice);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Pay Invoice'),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final bool bold;

  const _SummaryRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? AppTextStyles.titleMedium.copyWith(color: AppColors.primary)
        : AppTextStyles.bodySmall;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
