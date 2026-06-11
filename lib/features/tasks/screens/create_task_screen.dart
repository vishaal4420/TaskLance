import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/utils/validators.dart';
import '../../../models/task.dart';
import '../../../models/project.dart';
import 'package:uuid/uuid.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../../data/repositories/task_repository.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  final String? initialProjectId;
  
  const CreateTaskScreen({super.key, this.initialProjectId});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  ProjectModel? _selectedProject;
  DateTime? _dueDate = DateTime.now().add(const Duration(days: 7));
  String? _selectedAssigneeUid;
  String? _selectedAssigneeName;
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProject == null) {
      AppSnackBar.error(context, 'Please select a project');
      return;
    }
    
    setState(() => _loading = true);
    try {
      final taskId = const Uuid().v4();
      final task = TaskModel(
        id: taskId,
        projectId: _selectedProject!.id,
        title: _titleCtrl.text,
        description: _descCtrl.text,
        status: TaskStatus.todo,
        priority: _priority,
        assigneeUid: _selectedAssigneeUid,
        assigneeName: _selectedAssigneeName,
        dueDate: _dueDate,
        createdAt: DateTime.now(),
      );
      
      await ref.read(taskRepositoryProvider).createTask(task);
      
      if (!mounted) return;
      AppSnackBar.success(context, 'Task added!');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, 'Failed to create task: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(dashboardProjectsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('New Task')),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading projects: $e')),
        data: (projects) {
          if (_selectedProject == null && widget.initialProjectId != null) {
            try {
              _selectedProject = projects.firstWhere((p) => p.id == widget.initialProjectId);
            } catch (_) {}
          }
          if (_selectedProject == null && projects.isNotEmpty) {
            _selectedProject = projects.first;
          }

          final List<Map<String, String>> assignees = [];
          if (_selectedProject != null) {
            if (_selectedProject!.clientUid.isNotEmpty) {
              assignees.add({
                'uid': _selectedProject!.clientUid,
                'name': _selectedProject!.clientName ?? 'Client'
              });
            }
            if (_selectedProject!.freelancerUid != null && _selectedProject!.freelancerUid!.isNotEmpty) {
              assignees.add({
                'uid': _selectedProject!.freelancerUid!,
                'name': 'Freelancer' // We don't store freelancerName on project currently, fallback
              });
            }
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                AppTextField(
                  label: 'Task Title',
                  controller: _titleCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) => Validators.required(v, label: 'Title'),
                ),
                const SizedBox(height: 16),
                // Project dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Project',
                        style: AppTextStyles.labelLarge.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<ProjectModel>(
                      value: _selectedProject,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                      ),
                      hint: const Text('Select project'),
                      items: projects.map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.title, overflow: TextOverflow.ellipsis),
                      )).toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedProject = v;
                          _selectedAssigneeUid = null;
                          _selectedAssigneeName = null;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Priority
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Priority',
                        style: AppTextStyles.labelLarge.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                    const SizedBox(height: 8),
                    Row(
                      children: TaskPriority.values.map((p) {
                        final selected = _priority == p;
                        final color = p == TaskPriority.high
                            ? AppColors.error
                            : p == TaskPriority.medium
                                ? AppColors.warning
                                : AppColors.secondary;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _priority = p),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: selected ? color : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: color),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  p.name[0].toUpperCase() + p.name.substring(1),
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: selected ? Colors.white : color,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Due date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Due Date',
                        style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _dueDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (d != null) setState(() => _dueDate = d);
                      },
                      icon: const Icon(Icons.calendar_today_rounded, size: 16),
                      label: Text(_dueDate == null
                          ? 'Select due date'
                          : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Description',
                  controller: _descCtrl,
                  maxLines: 4,
                  hint: 'Describe the task...',
                ),
                const SizedBox(height: 16),
                // Assignee
                if (assignees.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Assignee',
                          style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                      const SizedBox(height: 8),
                      Row(
                        children: assignees.map((a) {
                          final uid = a['uid']!;
                          final name = a['name']!;
                          final selected = _selectedAssigneeUid == uid;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () => setState(() {
                                if (selected) {
                                  _selectedAssigneeUid = null;
                                  _selectedAssigneeName = null;
                                } else {
                                  _selectedAssigneeUid = uid;
                                  _selectedAssigneeName = name;
                                }
                              }),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected ? AppColors.primary : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: AvatarWidget(name: name, size: 40),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Add Task',
                  onPressed: _create,
                  isLoading: _loading,
                  width: double.infinity,
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
