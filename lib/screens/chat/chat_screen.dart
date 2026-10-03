import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../design/theme.dart';
import '../../design/typography.dart';
import '../../design/tokens.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _selectedPersona = 0;
  final List<String> _personas = ['Coach', 'Tough Love', 'Data Analyst', 'Empath'];
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  final List<Map<String, dynamic>> _contexts = [
    {'label': 'Tasks', 'locked': true},
    {'label': 'Goals', 'locked': true},
    {'label': 'Health', 'locked': false},
    {'label': 'Finances', 'locked': false},
  ];

  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text': 'Hey! Looking at your goals, you have a 14-day streak going. What\'s the plan for today?',
    },
    {
      'isUser': true,
      'text': 'I need to finish the marketing report but I keep putting it off.',
    },
    {
      'isUser': false,
      'text': 'Classic procrastination. Break it into a 25-minute deep work block. Open the focus timer now.',
    },
  ];

  static const _aiReplies = [
    'That\'s a solid plan. Keep it up!',
    'Let me check your goals... You\'re 72% toward your weekly target. Push a bit harder today.',
    'Consistency beats motivation every time. Small steps lead to big results.',
    'Break it into 3 smaller tasks — it becomes much more manageable.',
    'Your peak performance window seems to be 9-11 AM. Schedule the hard stuff then.',
    'Reflecting on your progress is key to sustained growth.',
    'Great question. Let me analyze your patterns and get back to you.',
  ];

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _messages.add({'isUser': true, 'text': text});
      _inputCtrl.clear();
    });
    _scrollToBottom();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'isUser': false,
          'text': _aiReplies[_messages.length % _aiReplies.length],
        });
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text('AI Coach',
            style: AppTypography.heading3.copyWith(color: colors.textPrimary)),
        backgroundColor: colors.surface1.withValues(alpha: 0.95),
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              // Clear chat
              HapticFeedback.lightImpact();
              setState(() => _messages.clear());
            },
            icon: Icon(LucideIcons.rotateCcw, color: colors.textSecondary),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Persona Selector ─────────────────────────────────
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: _personas.length,
                  itemBuilder: (context, i) {
                    final isSelected = i == _selectedPersona;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedPersona = i);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primary.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: AppRadius.borderRadiusPill,
                          border: Border.all(
                            color: isSelected ? colors.primary : colors.border,
                          ),
                        ),
                        child: Text(
                          _personas[i],
                          style: AppTypography.caption.copyWith(
                            color: isSelected
                                ? colors.primary
                                : colors.textTertiary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // ── Context Lock Bar ──────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: colors.border)),
                ),
                child: SizedBox(
                  height: 32,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    itemCount: _contexts.length,
                    itemBuilder: (context, i) {
                      final ctx = _contexts[i];
                      final isLocked = ctx['locked'] as bool;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => ctx['locked'] = !isLocked);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: colors.surface2,
                            borderRadius: AppRadius.borderRadiusSm,
                            border: Border.all(color: colors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isLocked
                                    ? LucideIcons.checkSquare
                                    : LucideIcons.square,
                                size: 14,
                                color: isLocked
                                    ? colors.mint
                                    : colors.textTertiary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                ctx['label'] as String,
                                style: AppTypography.caption
                                    .copyWith(color: colors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Chat messages ─────────────────────────────────────
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.sparkles,
                              size: 48,
                              color: colors.primary.withValues(alpha: 0.4)),
                          const SizedBox(height: AppSpacing.md),
                          Text('Start a conversation',
                              style: AppTypography.heading3
                                  .copyWith(color: colors.textSecondary)),
                          const SizedBox(height: AppSpacing.xs),
                          Text('Ask your AI coach anything',
                              style: AppTypography.body
                                  .copyWith(color: colors.textTertiary)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final isUser = msg['isUser'] as bool;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Row(
                            mainAxisAlignment: isUser
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!isUser) ...[
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colors.primary.withValues(alpha: 0.15),
                                  ),
                                  child: Icon(LucideIcons.sparkles,
                                      size: 12, color: colors.primary),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                              ],
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? colors.primary.withValues(alpha: 0.9)
                                        : colors.surface2,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft:
                                          Radius.circular(isUser ? 16 : 4),
                                      bottomRight:
                                          Radius.circular(isUser ? 4 : 16),
                                    ),
                                  ),
                                  child: Text(
                                    msg['text'] as String,
                                    style: AppTypography.body.copyWith(
                                      color: isUser
                                          ? Colors.white
                                          : colors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              if (isUser) const SizedBox(width: 28),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // ── Input Area ────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: colors.surface1,
                border: Border(top: BorderSide(color: colors.border)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: colors.surface2,
                        borderRadius: AppRadius.borderRadiusPill,
                        border: Border.all(color: colors.border),
                      ),
                      child: TextField(
                        controller: _inputCtrl,
                        style: AppTypography.body
                            .copyWith(color: colors.textPrimary),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Message coach...',
                          hintStyle: AppTypography.body
                              .copyWith(color: colors.textTertiary),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(LucideIcons.send,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
