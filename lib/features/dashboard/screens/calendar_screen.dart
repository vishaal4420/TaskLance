import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/dashboard_providers.dart';
import '../../../models/milestone.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _currentMonth = DateTime.now();

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  int get _daysInMonth {
    return DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    final monthString = DateFormat('MMMM yyyy').format(_currentMonth);
    final daysCount = _daysInMonth;
    final isCurrentMonth = _currentMonth.year == DateTime.now().year && _currentMonth.month == DateTime.now().month;
    final currentDay = DateTime.now().day;
    
    final milestonesAsync = ref.watch(dashboardMilestonesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.chevron_left), onPressed: _previousMonth),
                Text(monthString, style: AppTextStyles.headlineMedium),
                IconButton(icon: const Icon(Icons.chevron_right), onPressed: _nextMonth),
              ],
            ),
          ),
          Expanded(
            child: milestonesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (milestones) {
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: daysCount,
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final isToday = isCurrentMonth && day == currentDay;
                    
                    final hasEvent = milestones.any((m) => 
                      m.dueDate != null && 
                      m.dueDate!.year == _currentMonth.year && 
                      m.dueDate!.month == _currentMonth.month && 
                      m.dueDate!.day == day
                    );

                    return Container(
                      decoration: BoxDecoration(
                        color: isToday ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderLight.withOpacity(0.5)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            day.toString(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isToday ? Colors.white : null,
                              fontWeight: isToday ? FontWeight.bold : null,
                            ),
                          ),
                          if (hasEvent) ...[
                            const SizedBox(height: 4),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isToday ? Colors.white : AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ]
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Upcoming Deadlines', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                milestonesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox(),
                  data: (milestones) {
                    final upcoming = milestones
                        .where((m) => m.dueDate != null && m.dueDate!.isAfter(DateTime.now().subtract(const Duration(days: 1))))
                        .toList();
                    upcoming.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
                    
                    if (upcoming.isEmpty) {
                      return const Text('No upcoming deadlines');
                    }
                    
                    return Column(
                      children: upcoming.take(3).map((m) => ListTile(
                        leading: Container(width: 4, height: 40, color: AppColors.error),
                        title: Text(m.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text('Due: ${DateFormat('MMM dd').format(m.dueDate!)}'),
                        trailing: const Text('Soon'),
                      )).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
