import 'package:material_ui/material_ui.dart';

import '../utils/format.dart';

/// Row of three stat cards: companies, services, total service value.
class SummaryHeader extends StatelessWidget {
  const SummaryHeader({
    super.key,
    required this.companyCount,
    required this.serviceCount,
    required this.totalValue,
    this.compact = false,
  });

  final int companyCount;
  final int serviceCount;
  final double totalValue;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final gap = compact ? 8.0 : 16.0;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Companies',
            value: '$companyCount',
            icon: Icons.business_outlined,
            compact: compact,
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: _StatCard(
            label: 'Services',
            value: '$serviceCount',
            icon: Icons.design_services_outlined,
            compact: compact,
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: _StatCard(
            label: 'Total value',
            value: formatPrice(totalValue),
            icon: Icons.payments_outlined,
            compact: compact,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.compact,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(compact ? 14 : 20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              if (!compact) Icon(icon, size: 18, color: colors.onSurfaceVariant),
            ],
          ),
          SizedBox(height: compact ? 6 : 12),
          // Shrinks long values (e.g. RM 12,400.00) instead of overflowing on phones
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: compact ? 20 : 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
