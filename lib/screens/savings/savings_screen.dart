import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';

import '../../design/theme.dart';
import '../../design/typography.dart';
import '../../design/tokens.dart';
import '../../widgets/cards.dart';
import '../../widgets/buttons.dart';

class SavingsGoal {
  final String id;
  String title;
  double current;
  double target;
  Color color;
  String currency;
  String currencySymbol;

  SavingsGoal({
    required this.id,
    required this.title,
    required this.current,
    required this.target,
    required this.color,
    this.currency = 'USD',
    this.currencySymbol = '\$',
  });
}

const _currencies = [
  {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
  {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
  {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
  {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
  {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
  {'code': 'AED', 'symbol': 'AED', 'name': 'UAE Dirham'},
  {'code': 'CAD', 'symbol': 'CA\$', 'name': 'Canadian Dollar'},
  {'code': 'AUD', 'symbol': 'A\$', 'name': 'Australian Dollar'},
  {'code': 'CHF', 'symbol': 'Fr', 'name': 'Swiss Franc'},
  {'code': 'SGD', 'symbol': 'S\$', 'name': 'Singapore Dollar'},
  {'code': 'MYR', 'symbol': 'RM', 'name': 'Malaysian Ringgit'},
  {'code': 'BRL', 'symbol': 'R\$', 'name': 'Brazilian Real'},
  {'code': 'KRW', 'symbol': '₩', 'name': 'South Korean Won'},
  {'code': 'SAR', 'symbol': '﷼', 'name': 'Saudi Riyal'},
];

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  final _goals = <SavingsGoal>[
    SavingsGoal(
      id: 's1',
      title: 'Emergency Fund',
      current: 2500,
      target: 5000,
      color: const Color(0xFF9E77F1),
    ),
    SavingsGoal(
      id: 's2',
      title: 'Vacation',
      current: 800,
      target: 2000,
      color: const Color(0xFF10F1D3),
    ),
    SavingsGoal(
      id: 's3',
      title: 'New Laptop',
      current: 1500,
      target: 2400,
      color: const Color(0xFFFFB053),
    ),
  ];

  void _showCreateGoalSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CreateGoalSheet(
        onAdd: (goal) => setState(() => _goals.add(goal)),
      ),
    );
  }

  void _showAddContributionSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddContributionSheet(
        goals: _goals,
        onAdd: (id, amount) => setState(() {
          final g = _goals.firstWhere((x) => x.id == id);
          g.current = (g.current + amount).clamp(0, g.target);
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final totalCurrent = _goals.fold<double>(0, (s, g) => s + g.current);
    final totalTarget = _goals.fold<double>(0, (s, g) => s + g.target);
    final ratio = totalTarget > 0
        ? (totalCurrent / totalTarget).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text('Savings Goals',
            style: AppTypography.heading3.copyWith(color: colors.textPrimary)),
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        actions: [
          IconButton(
            onPressed: _showCreateGoalSheet,
            icon: Icon(LucideIcons.plus, color: colors.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // ── Total Ring ────────────────────────────────────────────
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: ratio,
                    strokeWidth: 16,
                    backgroundColor: colors.surface2,
                    valueColor: AlwaysStoppedAnimation(colors.primary),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Total Savings',
                            style: AppTypography.caption
                                .copyWith(color: colors.textSecondary)),
                        Text(
                          '\$${totalCurrent.toInt()}',
                          style: AppTypography.display.copyWith(
                              color: colors.textPrimary, fontSize: 32),
                        ),
                        Text('of \$${totalTarget.toInt()}',
                            style: AppTypography.body
                                .copyWith(color: colors.textTertiary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),

          // ── Goals List ───────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your Goals',
                  style: AppTypography.heading2
                      .copyWith(color: colors.textPrimary)),
              TextButton.icon(
                onPressed: _showCreateGoalSheet,
                icon: Icon(LucideIcons.plus, size: 14, color: colors.primary),
                label: Text('New Goal',
                    style: AppTypography.label.copyWith(color: colors.primary)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          if (_goals.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  children: [
                    Icon(LucideIcons.piggyBank,
                        size: 48, color: colors.surface3),
                    const SizedBox(height: AppSpacing.md),
                    Text('No savings goals yet',
                        style: AppTypography.heading3
                            .copyWith(color: colors.textSecondary)),
                  ],
                ),
              ),
            )
          else
            ..._goals.map((g) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _SavingsGoalCard(goal: g, colors: colors),
                )),

          const SizedBox(height: AppSpacing.xxl),

          // ── Add Contribution ─────────────────────────────────────
          if (_goals.isNotEmpty)
            PillButton(
              label: 'Add Contribution',
              onTap: _showAddContributionSheet,
            ),
          const SizedBox(height: AppSpacing.md),
          if (_goals.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showCreateGoalSheet,
                icon: Icon(LucideIcons.plus, size: 16, color: colors.primary),
                label: Text('Create New Goal',
                    style:
                        AppTypography.body.copyWith(color: colors.primary)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors.primary.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusPill),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _SavingsGoalCard extends StatelessWidget {
  const _SavingsGoalCard({required this.goal, required this.colors});
  final SavingsGoal goal;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    final ratio = (goal.current / goal.target).clamp(0.0, 1.0);
    final sym = goal.currencySymbol;

    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: goal.color),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(goal.title,
                      style: AppTypography.bodyLarge
                          .copyWith(color: colors.textPrimary)),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.surface3,
                      borderRadius: AppRadius.borderRadiusSm,
                    ),
                    child: Text(goal.currency,
                        style: AppTypography.caption
                            .copyWith(color: colors.textTertiary, fontSize: 10)),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('${(ratio * 100).toInt()}%',
                      style: AppTypography.body
                          .copyWith(color: colors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: AppRadius.borderRadiusPill,
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: colors.surface3,
              valueColor: AlwaysStoppedAnimation(goal.color),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$sym${goal.current.toInt()} saved',
                  style: AppTypography.caption.copyWith(
                      color: colors.textPrimary, fontWeight: FontWeight.bold)),
              Text('$sym${(goal.target - goal.current).toInt()} to go',
                  style: AppTypography.caption
                      .copyWith(color: colors.textTertiary)),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// CREATE GOAL SHEET
// ══════════════════════════════════════════════════════════════════════════

class _CreateGoalSheet extends StatefulWidget {
  const _CreateGoalSheet({required this.onAdd});
  final void Function(SavingsGoal goal) onAdd;

  @override
  State<_CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends State<_CreateGoalSheet> {
  final _titleCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();

  String _selectedCurrency = 'USD';
  String _selectedSymbol = '\$';

  final _colors = [
    const Color(0xFF9E77F1),
    const Color(0xFF10F1D3),
    const Color(0xFFFFB053),
    const Color(0xFFFF6B6B),
    const Color(0xFF63C2A5),
    const Color(0xFF4D9FF4),
  ];
  int _colorIndex = 0;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty) return;
    final target = double.tryParse(_targetCtrl.text);
    if (target == null || target <= 0) return;
    HapticFeedback.heavyImpact();
    widget.onAdd(SavingsGoal(
      id: const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      current: 0,
      target: target,
      color: _colors[_colorIndex],
      currency: _selectedCurrency,
      currencySymbol: _selectedSymbol,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currency = _currencies.firstWhere((c) => c['code'] == _selectedCurrency);

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: colors.surface1,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: colors.border),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: AppRadius.borderRadiusPill,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('New Savings Goal',
                    style: AppTypography.heading2
                        .copyWith(color: colors.textPrimary)),
                IconButton(
                  icon: Icon(LucideIcons.x, color: colors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Goal Title
            _Label('GOAL TITLE', colors),
            const SizedBox(height: AppSpacing.xs),
            _Input(ctrl: _titleCtrl, hint: 'e.g. Emergency Fund', colors: colors),
            const SizedBox(height: AppSpacing.md),

            // Currency
            _Label('CURRENCY', colors),
            const SizedBox(height: AppSpacing.xs),
            GestureDetector(
              onTap: () async {
                final result = await showModalBottomSheet<Map<String, String>>(
                  context: context,
                  backgroundColor: colors.surface1,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (ctx) => _CurrencyPicker(
                    colors: colors,
                    selectedCode: _selectedCurrency,
                  ),
                );
                if (result != null) {
                  setState(() {
                    _selectedCurrency = result['code']!;
                    _selectedSymbol = result['symbol']!;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 14),
                decoration: BoxDecoration(
                  color: colors.surface2,
                  borderRadius: AppRadius.borderRadiusMd,
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  children: [
                    Text(_selectedSymbol,
                        style: AppTypography.heading3
                            .copyWith(color: colors.primary)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(currency['code']!,
                              style: AppTypography.body
                                  .copyWith(color: colors.textPrimary,
                                      fontWeight: FontWeight.w600)),
                          Text(currency['name']!,
                              style: AppTypography.caption
                                  .copyWith(color: colors.textSecondary)),
                        ],
                      ),
                    ),
                    Icon(LucideIcons.chevronDown,
                        size: 18, color: colors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Target Amount
            _Label('TARGET AMOUNT', colors),
            const SizedBox(height: AppSpacing.xs),
            _Input(
              ctrl: _targetCtrl,
              hint: '0.00',
              colors: colors,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefix: '$_selectedSymbol ',
            ),
            const SizedBox(height: AppSpacing.md),

            // Color picker
            _Label('COLOR', colors),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: List.generate(_colors.length, (i) {
                return GestureDetector(
                  onTap: () => setState(() => _colorIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _colors[i],
                      border: _colorIndex == i
                          ? Border.all(color: Colors.white, width: 2.5)
                          : null,
                      boxShadow: _colorIndex == i
                          ? [
                              BoxShadow(
                                  color: _colors[i].withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1)
                            ]
                          : null,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.xxl),

            SizedBox(
              width: double.infinity,
              child: PillButton(label: 'Create Goal', onTap: _submit),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// CURRENCY PICKER
// ══════════════════════════════════════════════════════════════════════════

class _CurrencyPicker extends StatelessWidget {
  const _CurrencyPicker({required this.colors, required this.selectedCode});
  final AppColorsExtension colors;
  final String selectedCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text('Select Currency',
              style: AppTypography.heading2.copyWith(color: colors.textPrimary)),
        ),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _currencies.length,
            itemBuilder: (ctx, i) {
              final c = _currencies[i];
              final isSelected = c['code'] == selectedCode;
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.surface2,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(c['symbol']!,
                      style: AppTypography.body.copyWith(
                          color: colors.primary, fontWeight: FontWeight.bold)),
                ),
                title: Text(c['code']!,
                    style: AppTypography.body.copyWith(
                        color: colors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                subtitle: Text(c['name']!,
                    style: AppTypography.caption
                        .copyWith(color: colors.textSecondary)),
                trailing: isSelected
                    ? Icon(LucideIcons.checkCircle2, color: colors.primary)
                    : null,
                onTap: () => Navigator.pop(context, c),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// ADD CONTRIBUTION SHEET
// ══════════════════════════════════════════════════════════════════════════

class _AddContributionSheet extends StatefulWidget {
  const _AddContributionSheet({required this.goals, required this.onAdd});
  final List<SavingsGoal> goals;
  final void Function(String id, double amount) onAdd;

  @override
  State<_AddContributionSheet> createState() => _AddContributionSheetState();
}

class _AddContributionSheetState extends State<_AddContributionSheet> {
  final _amtCtrl = TextEditingController();
  late String _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.goals.first.id;
  }

  @override
  void dispose() {
    _amtCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selectedGoal = widget.goals.firstWhere((g) => g.id == _selectedId);

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: colors.surface1,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Add Contribution',
                  style: AppTypography.heading2
                      .copyWith(color: colors.textPrimary)),
              IconButton(
                icon: Icon(LucideIcons.x, color: colors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Amount',
              style: AppTypography.caption.copyWith(color: colors.textTertiary)),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _amtCtrl,
            style: AppTypography.display
                .copyWith(color: colors.textPrimary, fontSize: 40),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: InputDecoration(
              prefixText: '${selectedGoal.currencySymbol} ',
              prefixStyle: AppTypography.display
                  .copyWith(color: colors.textSecondary, fontSize: 40),
              border: InputBorder.none,
              hintText: '0',
              hintStyle: AppTypography.display
                  .copyWith(color: colors.border, fontSize: 40),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Towards Goal',
              style: AppTypography.caption.copyWith(color: colors.textTertiary)),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonHideUnderline(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 6),
              decoration: BoxDecoration(
                color: colors.surface2,
                borderRadius: AppRadius.borderRadiusMd,
                border: Border.all(color: colors.border),
              ),
              child: DropdownButton<String>(
                value: _selectedId,
                isExpanded: true,
                dropdownColor: colors.surface2,
                style: AppTypography.body.copyWith(color: colors.textPrimary),
                onChanged: (v) => setState(() => _selectedId = v!),
                items: widget.goals
                    .map((g) => DropdownMenuItem(
                          value: g.id,
                          child: Row(
                            children: [
                              Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle, color: g.color)),
                              const SizedBox(width: AppSpacing.sm),
                              Text(g.title),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          SizedBox(
            width: double.infinity,
            child: PillButton(
              label: 'Add Funds',
              onTap: () {
                final amount = double.tryParse(_amtCtrl.text);
                if (amount == null || amount <= 0) return;
                HapticFeedback.heavyImpact();
                widget.onAdd(_selectedId, amount);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════════════════════════

class _Label extends StatelessWidget {
  const _Label(this.text, this.colors);
  final String text;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: AppTypography.caption.copyWith(
            color: colors.textTertiary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8));
  }
}

class _Input extends StatelessWidget {
  const _Input({
    required this.ctrl,
    required this.hint,
    required this.colors,
    this.keyboardType,
    this.prefix,
  });
  final TextEditingController ctrl;
  final String hint;
  final AppColorsExtension colors;
  final TextInputType? keyboardType;
  final String? prefix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: colors.border),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: AppTypography.body.copyWith(color: colors.textPrimary),
        decoration: InputDecoration(
          prefixText: prefix,
          prefixStyle: AppTypography.body.copyWith(color: colors.textSecondary),
          hintText: hint,
          hintStyle: AppTypography.body.copyWith(color: colors.textTertiary),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
