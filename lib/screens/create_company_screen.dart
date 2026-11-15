import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/company_provider.dart';
import '../services/api_exception.dart';
import '../widgets/app_input.dart';
import '../widgets/form_container.dart';
import '../widgets/top_bar.dart';

class CreateCompanyScreen extends StatefulWidget {
  const CreateCompanyScreen({super.key});

  @override
  State<CreateCompanyScreen> createState() => _CreateCompanyScreenState();
}

class _CreateCompanyScreenState extends State<CreateCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _regNoController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _regNoController.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return; // shows errors under fields

    // Grab these BEFORE the await, so we don't use `context` after an async gap
    final provider = context.read<CompanyProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    setState(() => _isSubmitting = true);
    try {
      await provider.addCompany(
        name: _nameController.text.trim(),
        registrationNumber: _regNoController.text.trim(),
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Company created')),
      );
      navigator.pop(); // back to the list (already refreshed by the provider)
    } on ApiException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: errorColor),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(title: 'New company'),
      body: FormContainer(
        title: 'Create a company',
        subtitle: 'Register a company so you can add services to it.',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                enabled: !_isSubmitting,
                textInputAction: TextInputAction.next,
                decoration: appInputDecoration(
                  context,
                  label: 'Company name',
                  hint: 'e.g. Vista Sdn Bhd',
                ),
                validator: (v) => _required(v, 'Company name'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _regNoController,
                enabled: !_isSubmitting,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: appInputDecoration(
                  context,
                  label: 'Registration number',
                  hint: 'e.g. 202301000123',
                  helper: 'Must be unique, e.g. SSM registration number',
                ),
                validator: (v) => _required(v, 'Registration number'),
              ),
              const SizedBox(height: 28),
              FormActions(
                submitLabel: 'Create company',
                isSubmitting: _isSubmitting,
                onSubmit: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
