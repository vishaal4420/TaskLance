import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_snackbar.dart';

class FeedbackScreen extends StatefulWidget {
  final String projectId;
  const FeedbackScreen({super.key, required this.projectId});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leave Feedback')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('How was your experience working on this project?', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                iconSize: 48,
                icon: Icon(index < _rating ? Icons.star_rounded : Icons.star_outline_rounded, color: Colors.amber),
                onPressed: () => setState(() => _rating = index + 1),
              );
            }),
          ),
          const SizedBox(height: 32),
          const AppTextField(label: 'Public Testimonial', maxLines: 5, hint: 'Share your thoughts about the collaboration...'),
          const SizedBox(height: 16),
          const AppTextField(label: 'Private Feedback for Client', maxLines: 3, hint: 'Any constructive feedback?'),
          const SizedBox(height: 48),
          AppButton(
            label: 'Submit Feedback',
            onPressed: () {
              AppSnackBar.success(context, 'Feedback submitted!');
              context.pop();
            },
            width: double.infinity,
          )
        ],
      ),
    );
  }
}
