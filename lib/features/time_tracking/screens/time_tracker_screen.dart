import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_snackbar.dart';

class TimeTrackerScreen extends StatefulWidget {
  final String taskId;
  const TimeTrackerScreen({super.key, required this.taskId});

  @override
  State<TimeTrackerScreen> createState() => _TimeTrackerScreenState();
}

class _TimeTrackerScreenState extends State<TimeTrackerScreen> {
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _seconds++);
      });
    }
    setState(() => _isRunning = !_isRunning);
  }

  void _saveLog() {
    if (_isRunning) _toggleTimer();
    AppSnackBar.success(context, 'Time logged successfully!');
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    int h = totalSeconds ~/ 3600;
    int m = (totalSeconds % 3600) ~/ 60;
    int s = totalSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Time Tracker')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Current Session', style: AppTextStyles.titleMedium.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
            const SizedBox(height: 16),
            Text(
              _formatTime(_seconds),
              style: AppTextStyles.displayLarge.copyWith(fontSize: 64, color: AppColors.primary, fontFeatures: const [FontFeature.tabularFigures()]),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.large(
                  heroTag: 'play',
                  onPressed: _toggleTimer,
                  backgroundColor: _isRunning ? AppColors.warning : AppColors.primary,
                  child: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 40),
                ),
                if (_seconds > 0) ...[
                  const SizedBox(width: 24),
                  FloatingActionButton.large(
                    heroTag: 'stop',
                    onPressed: _saveLog,
                    backgroundColor: AppColors.success,
                    child: const Icon(Icons.stop_rounded, color: Colors.white, size: 40),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
