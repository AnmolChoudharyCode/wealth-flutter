import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/financial_profile.dart';
import '../models/goal.dart';
import '../providers/goals_provider.dart';
import '../utils/wealth_calculator.dart';

class SetGoalPage extends ConsumerStatefulWidget {
  const SetGoalPage({super.key});

  @override
  ConsumerState<SetGoalPage> createState() => _SetGoalPageState();
}

class _SetGoalPageState extends ConsumerState<SetGoalPage> {
  final _formKey = GlobalKey<FormState>();

  // Financial profile controllers
  late final TextEditingController _mobileCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _sipCtrl;
  late final TextEditingController _returnCtrl;
  late final TextEditingController _aumCtrl;
  late final TextEditingController _sipIncreaseCtrl;
  late final TextEditingController _inflationCtrl;

  final List<Goal> _goals = [];

  @override
  void initState() {
    super.initState();
    final existing = ref.read(goalsProvider);
    final p = existing.profile;
    _mobileCtrl = TextEditingController(text: p?.mobileNo ?? '');
    _ageCtrl = TextEditingController(
        text: p != null ? p.currentAge.toStringAsFixed(0) : '');
    _sipCtrl = TextEditingController(
        text: p != null ? p.monthlySIP.toStringAsFixed(0) : '');
    _returnCtrl = TextEditingController(
        text: p != null ? p.expectedReturn.toStringAsFixed(0) : '12');
    _aumCtrl = TextEditingController(
        text: p != null ? p.currentAUM.toStringAsFixed(0) : '');
    _sipIncreaseCtrl = TextEditingController(
        text: p != null ? p.annualSIPIncrease.toStringAsFixed(0) : '10');
    _inflationCtrl = TextEditingController(
        text: p != null ? p.inflationRate.toStringAsFixed(0) : '6');

    if (existing.goals.isNotEmpty) {
      _goals.addAll(existing.goals);
    }
  }

  @override
  void dispose() {
    _mobileCtrl.dispose();
    _ageCtrl.dispose();
    _sipCtrl.dispose();
    _returnCtrl.dispose();
    _aumCtrl.dispose();
    _sipIncreaseCtrl.dispose();
    _inflationCtrl.dispose();
    super.dispose();
  }

  void _proceed() {
    if (!_formKey.currentState!.validate()) return;

    final profile = FinancialProfile(
      mobileNo: _mobileCtrl.text.trim(),
      currentAge: double.tryParse(_ageCtrl.text) ?? 30,
      monthlySIP: double.tryParse(_sipCtrl.text) ?? 0,
      expectedReturn: double.tryParse(_returnCtrl.text) ?? 12,
      currentAUM: double.tryParse(_aumCtrl.text) ?? 0,
      annualSIPIncrease: double.tryParse(_sipIncreaseCtrl.text) ?? 10,
      inflationRate: double.tryParse(_inflationCtrl.text) ?? 6,
    );

    ref.read(goalsProvider.notifier).save(profile: profile, goals: _goals);
    context.pop();
  }

  void _showGoalDialog({Goal? editing}) {
    showDialog<void>(
      context: context,
      builder: (_) => _GoalDialog(
        initialGoal: editing,
        onSave: (goal) {
          setState(() {
            if (editing != null) {
              final idx = _goals.indexWhere((g) => g.id == editing.id);
              if (idx != -1) _goals[idx] = goal;
            } else {
              _goals.add(goal);
            }
          });
        },
      ),
    );
  }

  void _deleteGoal(String id) {
    setState(() => _goals.removeWhere((g) => g.id == id));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.dark : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Set Your Goal'),
        backgroundColor: isDark ? AppColors.dark : AppColors.lightBg,
        foregroundColor: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        elevation: 0,
        leading: BackButton(
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            // ── Financial Profile ──────────────────────────────────────────
            _SectionCard(
              color: cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(
                    icon: Icons.person_outline,
                    title: 'Financial Profile',
                    subtitle: 'Enter your current financial information',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildProfileForm(isDark),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),

            // ── Life Goals ─────────────────────────────────────────────────
            _SectionCard(
              color: cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _SectionTitle(
                          icon: Icons.flag_outlined,
                          title: 'Life Goals',
                          subtitle: 'Define your financial milestones',
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: _showGoalDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Goal'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.darkPurple,
                        ),
                      ),
                    ],
                  ),
                  if (_goals.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    ..._goals.map((goal) => _GoalListTile(
                          goal: goal,
                          onEdit: () => _showGoalDialog(editing: goal),
                          onDelete: () => _deleteGoal(goal.id),
                        )),
                  ] else ...[
                    const SizedBox(height: AppSpacing.lg),
                    Center(
                      child: Text(
                        'No goals added yet.',
                        style: AppTextStyles.bodyMd
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            AppSpacing.sm,
            AppSpacing.pagePadding,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: _proceed,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.darkPurple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Proceed'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileForm(bool isDark) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 500;
      final fields = [
        _LabeledField(
          label: 'Mobile No.',
          required: true,
          child: _AppTextField(
            controller: _mobileCtrl,
            hint: '10-digit mobile number',
            keyboardType: TextInputType.phone,
            maxLength: 10,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Mobile is required';
              if (v.trim().length < 10) return 'Enter valid 10-digit number';
              return null;
            },
          ),
        ),
        _LabeledField(
          label: 'Current Age',
          child: _AppTextField(
            controller: _ageCtrl,
            hint: '30',
            keyboardType: TextInputType.number,
          ),
        ),
        _LabeledField(
          label: 'Current AUM (₹)',
          child: _AppTextField(
            controller: _aumCtrl,
            hint: '500000',
            keyboardType: TextInputType.number,
          ),
        ),
        _LabeledField(
          label: 'Monthly SIP (₹)',
          child: _AppTextField(
            controller: _sipCtrl,
            hint: '10000',
            keyboardType: TextInputType.number,
          ),
        ),
        _LabeledField(
          label: 'Annual SIP Increase (%)',
          child: _AppTextField(
            controller: _sipIncreaseCtrl,
            hint: '10',
            keyboardType: TextInputType.number,
          ),
        ),
        _LabeledField(
          label: 'Expected Return / CAGR (%)',
          child: _AppTextField(
            controller: _returnCtrl,
            hint: '12',
            keyboardType: TextInputType.number,
          ),
        ),
        _LabeledField(
          label: 'Inflation Rate (%)',
          child: _AppTextField(
            controller: _inflationCtrl,
            hint: '6',
            keyboardType: TextInputType.number,
          ),
        ),
      ];

      if (isWide) {
        final rows = <Widget>[];
        for (var i = 0; i < fields.length; i += 2) {
          rows.add(Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: fields[i]),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: i + 1 < fields.length ? fields[i + 1] : const SizedBox()),
            ],
          ));
          if (i + 2 < fields.length) rows.add(const SizedBox(height: AppSpacing.md));
        }
        return Column(children: rows);
      }

      return Column(
        children: fields
            .expand((f) => [f, const SizedBox(height: AppSpacing.md)])
            .toList()
          ..removeLast(),
      );
    });
  }
}

// ─── Goal Dialog ──────────────────────────────────────────────────────────────

class _GoalDialog extends StatefulWidget {
  final Goal? initialGoal;
  final ValueChanged<Goal> onSave;

  const _GoalDialog({this.initialGoal, required this.onSave});

  @override
  State<_GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<_GoalDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _currentValueCtrl;
  late String _category;

  static const _categories = [
    'Retirement',
    'Education',
    'House',
    'Vacation',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final g = widget.initialGoal;
    _nameCtrl = TextEditingController(text: g?.name ?? '');
    _yearCtrl = TextEditingController(
        text: g != null ? g.targetYear.toString() : '');
    _amountCtrl = TextEditingController(
        text: g != null ? g.targetAmount.toStringAsFixed(0) : '');
    _currentValueCtrl = TextEditingController(
        text: g != null ? g.currentValue.toStringAsFixed(0) : '0');
    _category = g?.category ?? 'Retirement';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _yearCtrl.dispose();
    _amountCtrl.dispose();
    _currentValueCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final goal = Goal(
      id: widget.initialGoal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      category: _category,
      targetYear: int.parse(_yearCtrl.text),
      targetAmount: double.parse(_amountCtrl.text),
      currentValue: double.tryParse(_currentValueCtrl.text) ?? 0,
    );
    widget.onSave(goal);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;

    return AlertDialog(
      title: Text(widget.initialGoal != null ? 'Edit Goal' : 'Add New Goal'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LabeledField(
                label: 'Goal Name',
                required: true,
                child: _AppTextField(
                  controller: _nameCtrl,
                  hint: "Child's Education",
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Category', style: AppTextStyles.labelLg),
              const SizedBox(height: AppSpacing.xs),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(isDense: true),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _LabeledField(
                      label: 'Target Year',
                      required: true,
                      child: _AppTextField(
                        controller: _yearCtrl,
                        hint: '2035',
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final y = int.tryParse(v ?? '');
                          if (y == null) return 'Required';
                          if (y < currentYear) return '≥ $currentYear';
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _LabeledField(
                      label: 'Target Amount (₹)',
                      required: true,
                      child: _AppTextField(
                        controller: _amountCtrl,
                        hint: '5000000',
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final n = double.tryParse(v ?? '');
                          if (n == null || n <= 0) return 'Required';
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _LabeledField(
                label: 'Current Value (₹)',
                child: _AppTextField(
                  controller: _currentValueCtrl,
                  hint: '0',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          style: FilledButton.styleFrom(backgroundColor: AppColors.darkPurple),
          child: Text(widget.initialGoal != null ? 'Update' : 'Add Goal'),
        ),
      ],
    );
  }
}

// ─── Goal List Tile ───────────────────────────────────────────────────────────

class _GoalListTile extends StatelessWidget {
  final Goal goal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GoalListTile({
    required this.goal,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.lightBg,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.darkPurple.withAlpha(20),
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
            ),
            child: const Icon(Icons.flag_outlined,
                color: AppColors.darkPurple, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(goal.name, style: AppTextStyles.headingSm),
                Text(
                  '${goal.category} · ${goal.targetYear} · '
                  '${WealthCalculator.formatRupee(goal.targetAmount)}',
                  style: AppTextStyles.bodySm,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: AppColors.textSecondary,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 18),
            color: AppColors.negative,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  final Color color;

  const _SectionCard({required this.child, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.darkPurple.withAlpha(20),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
          ),
          child: Icon(icon, color: AppColors.darkPurple, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.headingSm),
              Text(subtitle,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textSecondary,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final bool required;
  final Widget child;

  const _LabeledField({
    required this.label,
    this.required = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.labelLg.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textOnDarkMuted
                  : AppColors.textSecondary,
            ),
            children: [
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.negative),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }
}

class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int? maxLength;
  final String? Function(String?)? validator;

  const _AppTextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.maxLength,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
        ),
      ),
    );
  }
}
