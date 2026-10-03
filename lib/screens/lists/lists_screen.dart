import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';

import '../../design/theme.dart';
import '../../design/typography.dart';
import '../../design/tokens.dart';
import '../../widgets/cards.dart';
import '../../widgets/buttons.dart';
import '../../providers/data_providers.dart';

const _iconOptions = [
  {'icon': LucideIcons.shoppingCart, 'label': 'Shopping'},
  {'icon': LucideIcons.bookOpen, 'label': 'Reading'},
  {'icon': LucideIcons.map, 'label': 'Travel'},
  {'icon': LucideIcons.gift, 'label': 'Gift'},
  {'icon': LucideIcons.activity, 'label': 'Workout'},
  {'icon': LucideIcons.home, 'label': 'Home'},
  {'icon': LucideIcons.briefcase, 'label': 'Work'},
  {'icon': LucideIcons.heart, 'label': 'Health'},
  {'icon': LucideIcons.star, 'label': 'Favorites'},
  {'icon': LucideIcons.music, 'label': 'Music'},
];

const _mockFriends = [
  {'name': 'Sarah J.', 'initial': 'S', 'color': Color(0xFFFFB053)},
  {'name': 'Mike R.', 'initial': 'M', 'color': Color(0xFF4D9FF4)},
  {'name': 'Emma W.', 'initial': 'E', 'color': Color(0xFF10F1D3)},
  {'name': 'David L.', 'initial': 'D', 'color': Color(0xFF9E77F1)},
  {'name': 'Chloe K.', 'initial': 'C', 'color': Color(0xFF63C2A5)},
];

class ListsScreen extends ConsumerStatefulWidget {
  const ListsScreen({super.key});

  @override
  ConsumerState<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends ConsumerState<ListsScreen> {
  void _showCreateListModal() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CreateListSheet(
        onAdd: (list) => ref.read(listsProvider.notifier).addList(list),
      ),
    );
  }

  void _showShareModal(ListData list) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ShareListSheet(
        list: list,
        onFriendAdded: (initial) {
          ref.read(listsProvider.notifier).addMember(list.id, initial);
        },
      ),
    );
  }

  void _openList(ListData list) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => _ListDetailScreen(
          list: list,
          onShare: () => _showShareModal(list),
        ),
      ),
    );
  }

  void _deleteList(String id) {
    ref.read(listsProvider.notifier).deleteList(id);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final lists = ref.watch(listsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text('My Lists',
            style: AppTypography.heading3.copyWith(color: colors.textPrimary)),
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        actions: [
          IconButton(
            onPressed: _showCreateListModal,
            icon: Icon(LucideIcons.plus, color: colors.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: lists.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.listChecks, size: 48, color: colors.surface3),
                  const SizedBox(height: AppSpacing.md),
                  Text('No lists yet',
                      style: AppTypography.heading3
                          .copyWith(color: colors.textSecondary)),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Tap + to create your first list',
                      style: AppTypography.body
                          .copyWith(color: colors.textTertiary)),
                  const SizedBox(height: AppSpacing.xl),
                  PillButton(label: 'Create List', onTap: _showCreateListModal),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.85,
              ),
              itemCount: lists.length,
              itemBuilder: (context, index) {
                final list = lists[index];
                return _ListCard(
                  data: list,
                  colors: colors,
                  onTap: () => _openList(list),
                  onDelete: () => _deleteList(list.id),
                  onShare: () => _showShareModal(list),
                );
              },
            ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// LIST CARD
// ══════════════════════════════════════════════════════════════════════════

class _ListCard extends StatelessWidget {
  const _ListCard({
    required this.data,
    required this.colors,
    required this.onTap,
    required this.onDelete,
    required this.onShare,
  });
  final ListData data;
  final AppColorsExtension colors;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SolidCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(data.icon, color: colors.primary, size: 20),
                ),
                PopupMenuButton(
                  icon: Icon(LucideIcons.moreVertical,
                      size: 20, color: colors.textSecondary),
                  color: colors.surface2,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: onTap,
                      child: Text('Open',
                          style: AppTypography.body
                              .copyWith(color: colors.textPrimary)),
                    ),
                    PopupMenuItem(
                      onTap: onShare,
                      child: Text('Share',
                          style: AppTypography.body
                              .copyWith(color: colors.textPrimary)),
                    ),
                    PopupMenuItem(
                      onTap: onDelete,
                      child: Text('Delete',
                          style: AppTypography.body
                              .copyWith(color: colors.danger)),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Text(data.title,
                style:
                    AppTypography.heading3.copyWith(color: colors.textPrimary),
                maxLines: 2),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Text('${data.itemCnt} items',
                    style: AppTypography.caption
                        .copyWith(color: colors.textSecondary)),
                if (data.members.length > 1) ...[
                  const SizedBox(width: 4),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.textTertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('Shared',
                      style: AppTypography.caption
                          .copyWith(color: colors.primary, fontWeight: FontWeight.w600)),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 24,
              child: Stack(
                clipBehavior: Clip.none,
                children: List.generate(data.members.length, (i) {
                  return Positioned(
                    left: i * 16.0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == 0 ? colors.primary : colors.surface3,
                        border: Border.all(color: colors.surface1, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        data.members[i],
                        style: AppTypography.caption.copyWith(
                            color: i == 0 ? Colors.white : colors.textPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// LIST DETAIL SCREEN
// ══════════════════════════════════════════════════════════════════════════

class _ListDetailScreen extends ConsumerStatefulWidget {
  const _ListDetailScreen({required this.list, required this.onShare});
  final ListData list;
  final VoidCallback onShare;

  @override
  ConsumerState<_ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends ConsumerState<_ListDetailScreen> {
  late final List<String> _items;
  final Set<int> _checked = {};
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _items = List<String>.from(widget.list.items);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _addItem() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _items.add(text);
      ref.read(listsProvider.notifier).updateListItems(widget.list.id, _items);
      _ctrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(widget.list.title,
            style: AppTypography.heading3.copyWith(color: colors.textPrimary)),
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        actions: [
          IconButton(
            onPressed: widget.onShare,
            icon: Icon(LucideIcons.userPlus, color: colors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Column(
        children: [
          // Member avatars in detail
          if (widget.list.members.length > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Text('Shared with: ', style: AppTypography.caption.copyWith(color: colors.textSecondary)),
                  const SizedBox(width: 4),
                  Wrap(
                    spacing: -8,
                    children: widget.list.members.map((m) => Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: m == 'A' ? colors.primary : colors.surface3,
                        border: Border.all(color: colors.background, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(m, style: AppTypography.caption.copyWith(color: m == 'A' ? Colors.white : colors.textPrimary, fontSize: 10)),
                    )).toList(),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: Text('No items yet. Add one below!',
                        style: AppTypography.body
                            .copyWith(color: colors.textTertiary)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: _items.length,
                    itemBuilder: (ctx, i) => CheckboxListTile(
                      value: _checked.contains(i),
                      onChanged: (v) =>
                          setState(() => v! ? _checked.add(i) : _checked.remove(i)),
                      title: Text(
                        _items[i],
                        style: AppTypography.body.copyWith(
                          color: _checked.contains(i)
                              ? colors.textTertiary
                              : colors.textPrimary,
                          decoration: _checked.contains(i)
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      activeColor: colors.primary,
                      checkColor: Colors.white,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.sm,
              bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: colors.surface1,
              border: Border(top: BorderSide(color: colors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    style: AppTypography.body.copyWith(color: colors.textPrimary),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addItem(),
                    decoration: InputDecoration(
                      hintText: 'Add item...',
                      hintStyle:
                          AppTypography.body.copyWith(color: colors.textTertiary),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _addItem,
                  icon: Icon(LucideIcons.plus, color: colors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// SHARE LIST MODAL
// ══════════════════════════════════════════════════════════════════════════

class _ShareListSheet extends StatelessWidget {
  const _ShareListSheet({required this.list, required this.onFriendAdded});
  final ListData list;
  final Function(String) onFriendAdded;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: colors.surface1,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: colors.border),
      ),
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
          Text('Share List', style: AppTypography.heading2.copyWith(color: colors.textPrimary)),
          const SizedBox(height: AppSpacing.xs),
          Text('Invite friends to collaborate on "${list.title}"', style: AppTypography.body.copyWith(color: colors.textSecondary)),
          const SizedBox(height: AppSpacing.xl),
          Text('FRIENDS', style: AppTypography.caption.copyWith(color: colors.textTertiary, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: AppSpacing.md),
          ..._mockFriends.map((f) {
            final isAdded = list.members.contains(f['initial']);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (f['color'] as Color).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(f['initial'] as String, style: TextStyle(color: f['color'] as Color, fontWeight: FontWeight.bold)),
              ),
              title: Text(f['name'] as String, style: AppTypography.body.copyWith(color: colors.textPrimary)),
              trailing: isAdded
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Shared', style: AppTypography.caption.copyWith(color: colors.mint)),
                        const SizedBox(width: 4),
                        Icon(LucideIcons.checkCircle2, color: colors.mint, size: 18),
                      ],
                    )
                  : TextButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        onFriendAdded(f['initial'] as String);
                        Navigator.pop(context);
                      },
                      child: Text('Invite', style: TextStyle(color: colors.primary)),
                    ),
            );
          }),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: colors.surface2,
                      borderRadius: AppRadius.borderRadiusMd,
                      border: Border.all(color: colors.border),
                    ),
                    child: Text('Copy invite link', style: AppTypography.body.copyWith(color: colors.textSecondary)),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                  child: const Icon(LucideIcons.copy, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// CREATE LIST MODAL
// ══════════════════════════════════════════════════════════════════════════

class _CreateListSheet extends StatefulWidget {
  const _CreateListSheet({required this.onAdd});
  final void Function(ListData list) onAdd;

  @override
  State<_CreateListSheet> createState() => _CreateListSheetState();
}

class _CreateListSheetState extends State<_CreateListSheet> {
  final _ctrl = TextEditingController();
  int _iconIndex = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_ctrl.text.trim().isEmpty) return;
    HapticFeedback.heavyImpact();
    final icon = _iconOptions[_iconIndex]['icon'] as IconData;
    widget.onAdd(ListData(
      id: const Uuid().v4(),
      title: _ctrl.text.trim(),
      icon: icon,
      itemCnt: 0,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: colors.surface1,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: colors.border),
      ),
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
              Text('New List',
                  style: AppTypography.heading2
                      .copyWith(color: colors.textPrimary)),
              IconButton(
                icon: Icon(LucideIcons.x, color: colors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          Text('LIST NAME',
              style: AppTypography.caption.copyWith(
                  color: colors.textTertiary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8)),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.surface2,
              borderRadius: AppRadius.borderRadiusMd,
              border: Border.all(color: colors.border),
            ),
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              style: AppTypography.body.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. Grocery List',
                hintStyle: AppTypography.body.copyWith(color: colors.textTertiary),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text('CHOOSE ICON',
              style: AppTypography.caption.copyWith(
                  color: colors.textTertiary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: List.generate(_iconOptions.length, (i) {
              final isSelected = i == _iconIndex;
              return GestureDetector(
                onTap: () => setState(() => _iconIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary.withValues(alpha: 0.15)
                        : colors.surface2,
                    borderRadius: AppRadius.borderRadiusMd,
                    border: Border.all(
                      color: isSelected ? colors.primary : colors.border,
                    ),
                  ),
                  child: Icon(
                    _iconOptions[i]['icon'] as IconData,
                    size: 22,
                    color: isSelected ? colors.primary : colors.textSecondary,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.xxl),

          SizedBox(
            width: double.infinity,
            child: PillButton(label: 'Create List', onTap: _submit),
          ),
        ],
      ),
    );
  }
}
