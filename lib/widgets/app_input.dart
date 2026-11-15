import 'package:material_ui/material_ui.dart';

/// One consistent input style for every field in the app:
/// white fill, hairline border, accent border on focus, 8px corners.
InputDecoration appInputDecoration(
  BuildContext context, {
  String? label,
  String? hint,
  String? helper,
  String? prefixText,
  Widget? prefixIcon,
  Widget? suffixIcon,
  bool dense = false,
}) {
  final colors = Theme.of(context).colorScheme;

  OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    labelText: label,
    hintText: hint,
    helperText: helper,
    prefixText: prefixText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    isDense: dense,
    filled: true,
    fillColor: colors.surfaceContainerLowest,
    hintStyle: TextStyle(color: colors.onSurfaceVariant),
    border: border(colors.outlineVariant),
    enabledBorder: border(colors.outline),
    disabledBorder: border(colors.outlineVariant),
    focusedBorder: border(colors.primary, 1.5),
    errorBorder: border(colors.error),
    focusedErrorBorder: border(colors.error, 1.5),
  );
}
