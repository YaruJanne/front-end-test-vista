import 'package:material_ui/material_ui.dart';

/// Rounded square with the company's initials, colored consistently per name.
class CompanyAvatar extends StatelessWidget {
  const CompanyAvatar({super.key, required this.name, this.size = 36});

  final String name;
  final double size;

  static const List<MaterialColor> _palette = [
    Colors.indigo,
    Colors.teal,
    Colors.deepOrange,
    Colors.purple,
    Colors.blue,
    Colors.green,
    Colors.pink,
    Colors.blueGrey,
  ];

  // Same name → same color every time
  MaterialColor get _color =>
      _palette[name.codeUnits.fold<int>(0, (sum, c) => sum + c) % _palette.length];

  // "Vista Sdn Bhd" → "VS"
  String get _initials {
    final words =
        name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _color;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.22 : 0.10),
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Text(
        _initials,
        style: TextStyle(
          color: isDark ? color.shade200 : color.shade700,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}
