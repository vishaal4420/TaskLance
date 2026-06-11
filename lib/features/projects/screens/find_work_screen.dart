import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/project_card.dart';
import '../../../core/widgets/shimmer_widgets.dart';
import '../providers/project_providers.dart';

class FindWorkScreen extends ConsumerWidget {
  const FindWorkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openProjectsAsync = ref.watch(openProjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Work'),
      ),
      body: openProjectsAsync.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, __) => const ShimmerCard(height: 140),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (projects) {
          if (projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 64, color: AppColors.textSecondaryLight),
                  const SizedBox(height: 16),
                  Text('No open projects right now.', style: AppTextStyles.titleMedium),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final p = projects[i];
              return ProjectCard(
                project: p,
                onTap: () => context.push('/projects/${p.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
