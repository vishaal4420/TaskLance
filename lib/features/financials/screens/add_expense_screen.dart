import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_snackbar.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  String? _attachedFileName;

  Future<void> _pickReceipt() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'pdf'],
      );

      if (result != null) {
        setState(() {
          _attachedFileName = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Failed to pick file');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Expense')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AppTextField(label: 'Amount (\$)', keyboardType: TextInputType.number, hint: '0.00'),
          const SizedBox(height: 16),
          const AppTextField(label: 'Description', hint: 'e.g. Server hosting fee'),
          const SizedBox(height: 16),
          const AppTextField(label: 'Category', hint: 'Software, Travel, Hardware...'),
          const SizedBox(height: 32),
          if (_attachedFileName != null)
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: Text(_attachedFileName!),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _attachedFileName = null),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: _pickReceipt,
              icon: const Icon(Icons.upload_file),
              label: const Text('Attach Receipt (Optional)'),
            ),
          const SizedBox(height: 32),
          AppButton(
            label: 'Save Expense',
            onPressed: () {
              AppSnackBar.success(context, 'Expense logged successfully!');
              context.pop();
            },
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
