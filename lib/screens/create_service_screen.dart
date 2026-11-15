import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/company_provider.dart';
import '../services/api_exception.dart';
import '../widgets/app_input.dart';
import '../widgets/form_container.dart';
import '../widgets/top_bar.dart';

class CreateServiceScreen extends StatefulWidget {
  const CreateServiceScreen({super.key, this.initialCompanyId});

  /// Pre-selects a company when opened from a company card
  final int? initialCompanyId;

  @override
  State<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends State<CreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  int? _selectedCompanyId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final companies = context.read<CompanyProvider>().companies;
    final exists = companies.any((c) => c.id == widget.initialCompanyId);
    _selectedCompanyId = exists ? widget.initialCompanyId : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) return 'Price is required';
    final price = double.tryParse(value.trim());
    if (price == null) return 'Price must be a number';
    if (price < 0) return 'Price cannot be negative';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CompanyProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    setState(() => _isSubmitting = true);
    try {
      await provider.addService(
        companyId: _selectedCompanyId!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Service created')),
      );
      navigator.pop();
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
    final companies = context.watch<CompanyProvider>().companies;

    return Scaffold(
      appBar: const TopBar(title: 'New service'),
      body: FormContainer(
        title: 'Add a service',
        subtitle: 'Add a service and link it to one of your companies.',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<int>(
                initialValue: _selectedCompanyId,
                isExpanded: true,
                decoration: appInputDecoration(context, label: 'Company'),
                items: companies
                    .map((c) => DropdownMenuItem<int>(
                          value: c.id,
                          child: Text(
                            '${c.name} (${c.registrationNumber})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: _isSubmitting
                    ? null
                    : (value) => setState(() => _selectedCompanyId = value),
                validator: (value) =>
                    value == null ? 'Please select a company' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                enabled: !_isSubmitting,
                textInputAction: TextInputAction.next,
                decoration: appInputDecoration(
                  context,
                  label: 'Service name',
                  hint: 'e.g. Web Design',
                ),
                validator: (v) => _required(v, 'Service name'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                enabled: !_isSubmitting,
                maxLines: 3,
                decoration: appInputDecoration(
                  context,
                  label: 'Description',
                  hint: 'What does this service include?',
                ).copyWith(alignLabelWithHint: true),
                validator: (v) => _required(v, 'Description'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _priceController,
                enabled: !_isSubmitting,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: appInputDecoration(
                  context,
                  label: 'Price',
                  hint: '1500.00',
                  prefixText: 'RM ',
                  helper: 'Numbers only, up to 2 decimal places',
                ),
                validator: _validatePrice,
              ),
              const SizedBox(height: 28),
              FormActions(
                submitLabel: 'Create service',
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
