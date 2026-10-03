import 'package:flutter/material.dart';
import '../../design/theme.dart';
import '../../design/typography.dart';
import '../../design/tokens.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../widgets/buttons.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        title: Text('Edit Profile', style: AppTypography.heading3.copyWith(color: colors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.primary.withValues(alpha: 0.15),
                      border: Border.all(color: colors.primary, width: 2),
                    ),
                    child: Icon(LucideIcons.user, size: 50, color: colors.primary),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.background, width: 3),
                      ),
                      child: const Icon(LucideIcons.camera, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _buildTextField(colors, 'Display Name', 'Alex'),
            const SizedBox(height: AppSpacing.lg),
            _buildTextField(colors, 'Username', '@alexflow'),
            const SizedBox(height: AppSpacing.lg),
            _buildTextField(colors, 'Bio', 'Ambitious developer & designer.'),
            const SizedBox(height: AppSpacing.xxl),
            PillButton(
              label: 'Save Changes',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(AppColorsExtension colors, String label, String initialValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.label.copyWith(color: colors.textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          initialValue: initialValue,
          style: AppTypography.body.copyWith(color: colors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.surface2,
            border: OutlineInputBorder(
              borderRadius: AppRadius.borderRadiusLg,
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
