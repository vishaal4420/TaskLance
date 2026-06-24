import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/project_card.dart';
import '../../../models/project.dart';
import '../providers/dashboard_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(dashboardProjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search projects, tasks...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            fillColor: Colors.transparent,
          ),
          onChanged: (val) {
            setState(() {
              _query = val.trim();
            });
          },
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchCtrl.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: _query.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_rounded, size: 64, color: AppColors.borderLight),
                  const SizedBox(height: 16),
                  Text('Type to start searching',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight)),
                ],
              ),
            )
          : projectsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (projects) {
                final results = projects
                    .where((p) => p.title.toLowerCase().contains(_query.toLowerCase()) || 
                                  p.description.toLowerCase().contains(_query.toLowerCase()))
                    .toList();

                if (results.isEmpty) {
                  return Center(
                    child: Text('No results found.', style: AppTextStyles.bodyMedium),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => ProjectCard(
                    project: results[i],
                    onTap: () => context.push('/projects/${results[i].id}'),
                  ),
                );
              },
            ),
    );
  }
}
