import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/status_chip.dart';

class FilePreviewScreen extends StatelessWidget {
  final String fileUrl;
  final String fileName;

  const FilePreviewScreen({super.key, required this.fileUrl, required this.fileName});

  @override
  Widget build(BuildContext context) {
    final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'file';
    final Color typeColor = ext == 'pdf'
        ? Colors.red
        : ext == 'png' || ext == 'jpg'
            ? Colors.blue
            : ext == 'docx' || ext == 'doc'
                ? Colors.green
                : AppColors.primary;
    final IconData icon = ext == 'pdf'
        ? Icons.picture_as_pdf_rounded
        : ext == 'png' || ext == 'jpg'
            ? Icons.image_rounded
            : Icons.insert_drive_file_rounded;

    void handleShare() {
      final actualUrl = fileUrl == 'demo' ? 'https://tasklance.app/demo-file.pdf' : fileUrl;
      Share.share('Check out this file from TaskLance: $actualUrl');
    }

    void handleDownload() async {
      final actualUrl = fileUrl == 'demo' ? 'https://tasklance.app/demo-file.pdf' : fileUrl;
      final Uri url = Uri.parse(actualUrl);
      try {
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) AppSnackBar.error(context, 'Could not launch download link');
        }
      } catch (e) {
        if (context.mounted) AppSnackBar.error(context, 'Invalid download URL');
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.6),
        foregroundColor: Colors.white,
        title: Text(fileName,
            style: AppTextStyles.titleSmall.copyWith(color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: handleShare,
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            onPressed: handleDownload,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(icon, color: typeColor, size: 60),
                  ),
                  const SizedBox(height: 20),
                  Text(fileName,
                      style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('Demo preview',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.6))),
                ],
              ),
            ),
          ),
          // Bottom sheet info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fileName, style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('May 27, 2026',
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.white60)),
                    const SizedBox(width: 12),
                    const StatusChip(label: 'Approved', color: AppColors.secondary, small: true),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: handleDownload,
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('Download'),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white38)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: handleShare,
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('Share'),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white38)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
