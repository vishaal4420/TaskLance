import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/shimmer_widgets.dart';
import '../../../core/widgets/empty_error_states.dart';
import '../../../core/widgets/status_chip.dart';
import '../providers/deliverable_providers.dart';

class DeliverablesScreen extends ConsumerStatefulWidget {
  final String projectId;

  const DeliverablesScreen({super.key, required this.projectId});

  @override
  ConsumerState<DeliverablesScreen> createState() => _DeliverablesScreenState();
}

class _DeliverablesScreenState extends ConsumerState<DeliverablesScreen> {
  String? _filter;

  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> all) {
    if (_filter == null) return all;
    return all.where((d) => d['status'] == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final delAsync = ref.watch(projectDeliverablesProvider(widget.projectId));

    return Scaffold(
      appBar: AppBar(title: const Text('Deliverables')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(
            '/deliverables/upload?projectId=${widget.projectId}'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.upload_rounded, color: Colors.white),
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final f in [null, 'approved', 'review', 'revision', 'pending'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        f == null ? 'All' : f[0].toUpperCase() + f.substring(1),
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
                      selectedColor: AppColors.primary.withOpacity(0.15),
                      checkmarkColor: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: delAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: ShimmerList(count: 4, itemHeight: 100),
              ),
              error: (e, _) => ErrorState(message: e.toString()),
              data: (all) {
                final filtered = _filtered(all);
                if (filtered.isEmpty) {
                  return EmptyState(
                    title: 'No Deliverables',
                    subtitle: 'Upload your first deliverable',
                    actionLabel: 'Upload',
                    onAction: () => context.push(
                        '/deliverables/upload?projectId=${widget.projectId}'),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.88,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final d = filtered[i];
                    final fileName = (d['fileName'] as String?) ?? (d['name'] as String?) ?? 'file';
                    final title = (d['title'] as String?) ?? fileName;
                    final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'file';
                    final type = (d['type'] as String?) ?? (
                      (ext == 'pdf') ? 'pdf' :
                      (ext == 'png' || ext == 'jpg' || ext == 'jpeg') ? 'image' :
                      (ext == 'doc' || ext == 'docx') ? 'doc' : 'file'
                    );
                    
                    final Color typeColor = type == 'pdf'
                        ? Colors.red
                        : type == 'image'
                            ? Colors.blue
                            : type == 'doc'
                                ? Colors.green
                                : AppColors.primary;
                                
                    final status = (d['status'] as String?) ?? 'pending';
                    String dateStr = d['date'] as String? ?? '';
                    if (dateStr.isEmpty && d['createdAt'] != null) {
                      final dt = (d['createdAt'] as Timestamp).toDate();
                      dateStr = DateFormat('MMM dd, yyyy').format(dt);
                    }
                    if (dateStr.isEmpty) dateStr = 'Unknown';
                    
                    final fileUrl = d['fileUrl'] as String? ?? 'demo';

                    return GestureDetector(
                      onTap: () => context.push(
                          '/deliverables/preview?url=$fileUrl&name=$fileName'),
                      child: _DeliverableCard(
                        name: title,
                        type: type,
                        status: status,
                        date: dateStr,
                        color: typeColor,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliverableCard extends StatelessWidget {
  final String name, type, status, date;
  final Color color;

  const _DeliverableCard({
    required this.name,
    required this.type,
    required this.status,
    required this.date,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final icon = type == 'pdf'
        ? Icons.picture_as_pdf_rounded
        : type == 'image'
            ? Icons.image_rounded
            : Icons.insert_drive_file_rounded;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const Spacer(),
          Text(name, style: AppTextStyles.labelMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Row(
            children: [
              StatusChip.fromString(status, small: true),
              const Spacer(),
              Text(date.substring(5), style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
            ],
          ),
        ],
      ),
    );
  }
}
