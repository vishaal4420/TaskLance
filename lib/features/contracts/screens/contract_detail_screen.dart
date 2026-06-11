import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/shimmer_widgets.dart';
import '../../../core/widgets/empty_error_states.dart';
import '../../../models/contract.dart';

final contractDetailProvider = StreamProvider.family<ContractModel?, String>((ref, id) {
  return FirebaseFirestore.instance.collection('contracts').doc(id).snapshots().map((doc) {
    if (doc.exists && doc.data() != null) {
      return ContractModel.fromJson(doc.data()!);
    }
    return null;
  });
});

class ContractDetailScreen extends ConsumerStatefulWidget {
  final String contractId;
  const ContractDetailScreen({super.key, required this.contractId});

  @override
  ConsumerState<ContractDetailScreen> createState() => _ContractDetailScreenState();
}

class _ContractDetailScreenState extends ConsumerState<ContractDetailScreen> {
  bool _isGeneratingPdf = false;

  Future<void> _generateAndSharePdf(ContractModel contract) async {
    setState(() => _isGeneratingPdf = true);
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(32),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'SERVICE AGREEMENT',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Client: ${contract.clientName}'),
                      pw.Text('Date: ${DateFormat.yMMMd().format(contract.signedAt)}'),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text('Freelancer: ${contract.freelancerName}'),
                  pw.SizedBox(height: 8),
                  pw.Text('Contract Amount: \$${contract.amount.toStringAsFixed(2)}'),
                  pw.Divider(height: 32),
                  pw.Text(
                    'TERMS AND CONDITIONS',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Text(contract.terms, style: const pw.TextStyle(lineSpacing: 2)),
                  pw.Spacer(),
                  pw.Divider(),
                  pw.Text('Digitally generated and signed via TaskLance', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                ],
              ),
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/contract_${contract.id}.pdf');
      await file.writeAsBytes(await pdf.save());

      if (!mounted) return;
      await Share.shareXFiles([XFile(file.path)], text: 'Contract: ${contract.title}');
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Error generating PDF: $e');
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contractAsync = ref.watch(contractDetailProvider(widget.contractId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contract Details'),
        actions: [
          contractAsync.when(
            data: (contract) => contract == null
                ? const SizedBox()
                : _isGeneratingPdf
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () => _generateAndSharePdf(contract),
                        tooltip: 'Download PDF',
                      ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: contractAsync.when(
        loading: () => const Padding(padding: EdgeInsets.all(16), child: ShimmerList(count: 3, itemHeight: 100)),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (contract) {
          if (contract == null) {
            return const ErrorState(message: 'Contract not found');
          }

          final formattedDate = DateFormat.yMMMd().format(contract.signedAt);

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.primary.withOpacity(0.05),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success),
                    const SizedBox(width: 8),
                    Text('Digitally Signed on $formattedDate', style: AppTextStyles.labelMedium.copyWith(color: AppColors.success)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(contract.title.toUpperCase(), style: AppTextStyles.headlineLarge),
                      const SizedBox(height: 24),
                      Text(
                        contract.terms,
                        style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
