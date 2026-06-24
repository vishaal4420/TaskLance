import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/utils/validators.dart';
import '../../../models/milestone.dart';
import '../../milestones/providers/milestone_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class UploadDeliverableScreen extends ConsumerStatefulWidget {
  final String projectId;

  const UploadDeliverableScreen({super.key, required this.projectId});

  @override
  ConsumerState<UploadDeliverableScreen> createState() =>
      _UploadDeliverableScreenState();
}

class _UploadDeliverableScreenState
    extends ConsumerState<UploadDeliverableScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _fileName;
  String? _filePath;
  MilestoneModel? _selectedMilestone;
  bool _submitForReview = true;
  bool _loading = false;
  double _progress = 0;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fileName == null) {
      AppSnackBar.error(context, 'Please select a file first');
      return;
    }
    setState(() {
      _loading = true;
      _progress = 0;
    });
    
    final deliverableId = const Uuid().v4();

    try {
      // Copy file to local app directory
      final appDir = await getApplicationDocumentsDirectory();
      final delivDir = Directory('${appDir.path}/deliverables/${widget.projectId}');
      if (!await delivDir.exists()) {
        await delivDir.create(recursive: true);
      }
      
      final newPath = '${delivDir.path}/${DateTime.now().millisecondsSinceEpoch}_$_fileName';
      
      // Simulate progress for UI
      if (mounted) {
        setState(() => _progress = 0.5);
      }
      
      await File(_filePath!).copy(newPath);
      
      if (mounted) {
        setState(() => _progress = 1.0);
      }
      
      final downloadUrl = newPath;
      
      final deliverableData = {
        'id': deliverableId,
        'projectId': widget.projectId,
        'milestoneId': _selectedMilestone?.id,
        'milestoneTitle': _selectedMilestone?.title,
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'fileName': _fileName,
        'fileUrl': downloadUrl,
        'status': _submitForReview ? 'pending_review' : 'draft',
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      final batch = FirebaseFirestore.instance.batch();
      
      // Save deliverable
      final delRef = FirebaseFirestore.instance.collection('deliverables').doc(deliverableId);
      batch.set(delRef, deliverableData);
      
      // Update milestone if selected and submitting for review
      if (_selectedMilestone != null && _submitForReview) {
        final msRef = FirebaseFirestore.instance.collection('milestones').doc(_selectedMilestone!.id);
        batch.update(msRef, {
          'status': MilestoneStatus.review.name,
        });
      }
      
      await batch.commit();
      
      if (!mounted) return;
      AppSnackBar.success(context, 'Deliverable uploaded successfully!');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, 'Failed to upload deliverable: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final milestonesAsync = ref.watch(projectMilestonesProvider(widget.projectId));
    final milestones = milestonesAsync.valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Deliverable')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // File picker area
            GestureDetector(
              onTap: () async {
                final result = await FilePicker.platform.pickFiles();
                if (result != null && result.files.isNotEmpty) {
                  setState(() {
                    _fileName = result.files.single.name;
                    _filePath = result.files.single.path;
                  });
                }
              },
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _fileName != null
                        ? AppColors.secondary
                        : AppColors.borderLight,
                    style: BorderStyle.solid,
                    width: _fileName != null ? 2 : 1,
                  ),
                ),
                child: _fileName == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_rounded,
                              size: 40,
                              color: AppColors.primary.withOpacity(0.6)),
                          const SizedBox(height: 8),
                          Text('Tap to select file',
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                          Text('PDF, Images, Documents',
                              style: AppTextStyles.labelSmall.copyWith(
                                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              size: 36, color: AppColors.secondary),
                          const SizedBox(height: 8),
                          Text(_fileName!,
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.secondary)),
                          TextButton(
                            onPressed: () => setState(() => _fileName = null),
                            child: const Text('Remove'),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Title',
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => Validators.required(v, label: 'Title'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Description',
              controller: _descCtrl,
              maxLines: 3,
              hint: 'What does this deliverable contain?',
            ),
            const SizedBox(height: 16),
            // Milestone selector
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Milestone',
                    style: AppTextStyles.labelLarge.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                const SizedBox(height: 6),
                DropdownButtonFormField<MilestoneModel>(
                  initialValue: _selectedMilestone,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    hintText: 'Select milestone (optional)',
                  ),
                  items: milestones.map((m) => DropdownMenuItem(
                    value: m,
                    child: Text(m.title, overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedMilestone = v),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Submit for review immediately',
                  style: AppTextStyles.bodyMedium),
              subtitle: Text('Notify client for approval',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              value: _submitForReview,
              onChanged: (v) => setState(() => _submitForReview = v),
            ),
            const SizedBox(height: 16),
            if (_loading) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 8,
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              const SizedBox(height: 8),
              Text('Uploading... ${(_progress * 100).toInt()}%',
                  style: AppTextStyles.labelSmall.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
            ],
            AppButton(
              label: 'Upload',
              onPressed: _loading ? null : _upload,
              isLoading: false,
              icon: Icons.cloud_upload_rounded,
              width: double.infinity,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
