import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/seed_data.dart';
import '../../../models/project.dart';
import '../../../models/milestone.dart';
import '../../../models/invoice.dart';

final clientProjectsProvider = FutureProvider<List<ProjectModel>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 600));
  return SeedData.projects;
});

final clientPendingMilestonesProvider =
    FutureProvider<List<MilestoneModel>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 600));
  return SeedData.milestones
      .where((m) => m.status == MilestoneStatus.review)
      .toList();
});

final recentInvoicesProvider =
    FutureProvider<List<InvoiceModel>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 600));
  return SeedData.invoices.take(2).toList();
});
