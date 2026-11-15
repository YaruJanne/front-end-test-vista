import 'package:material_ui/material_ui.dart';

/// Centers a form and limits its width, so it looks good on phones AND wide screens.
class FormContainer extends StatelessWidget {
  const FormContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: child,
        ),
      ),
    );
  }
}