import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/deliverable_repository.dart';

final projectDeliverablesProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, projectId) {
  final repository = ref.watch(deliverableRepositoryProvider);
  return repository.streamDeliverablesForProject(projectId);
});
