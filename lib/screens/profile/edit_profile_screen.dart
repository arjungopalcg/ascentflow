import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/typography.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/buttons.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final _name = TextEditingController(text: ref.read(userProfileProvider).name);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref.read(userProfileProvider.notifier).setName(_name.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary.withValues(alpha: colors.isDark ? 0.18 : 0.1),
                border: Border.all(color: colors.primary, width: 2),
              ),
              child: Icon(LucideIcons.user, size: 44, color: colors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Your name',
            style: AppTypography.label.copyWith(color: colors.textSecondary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _name,
            maxLength: 30,
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _save(),
            style: AppTypography.bodyLarge.copyWith(color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: 'How should we greet you?',
              counterText: '',
              filled: true,
              fillColor: colors.surface1,
              border: OutlineInputBorder(
                borderRadius: AppRadius.borderRadiusMd,
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.borderRadiusMd,
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.borderRadiusMd,
                borderSide: BorderSide(color: colors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          PillButton(label: 'Save', onTap: _save),
        ],
      ),
    );
  }
}
