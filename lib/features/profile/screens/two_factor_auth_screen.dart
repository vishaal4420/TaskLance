import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  bool _is2faEnabled = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Two-Factor Auth')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.security_rounded,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Secure Your Account',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Two-factor authentication adds an extra layer of security to your account. Once enabled, you\'ll need both your password and an authentication code to log in.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                title: Text('Enable 2FA', style: AppTextStyles.titleMedium),
                subtitle: Text(
                  _is2faEnabled ? 'Currently active' : 'Currently inactive',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _is2faEnabled ? AppColors.success : AppColors.textSecondaryLight,
                  ),
                ),
                value: _is2faEnabled,
                onChanged: (v) {
                  setState(() => _is2faEnabled = v);
                },
              ),
            ),
            if (_is2faEnabled) ...[
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      color: Colors.white,
                      child: QrImageView(
                        data: 'otpauth://totp/TaskLance:User?secret=ABCD1234EFGH5678&issuer=TaskLance',
                        version: QrVersions.auto,
                        size: 200.0,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Secret Key: ABCD-1234-EFGH-5678',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
