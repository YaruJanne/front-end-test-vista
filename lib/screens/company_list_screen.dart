import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/company.dart';
import '../models/service.dart';
import '../providers/company_provider.dart';
import '../utils/format.dart';
import 'create_company_screen.dart';
import 'create_service_screen.dart';

class CompanyListScreen extends StatelessWidget {
  const CompanyListScreen({super.key});

  void _openCreateCompany(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateCompanyScreen()),
    );
  }

  void _openCreateService(BuildContext context, {int? companyId}) {
    if (context.read<CompanyProvider>().companies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a company first.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateServiceScreen(initialCompanyId: companyId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompanyProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Companies'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: provider.isLoading ? null : provider.fetchCompanies,
          ),
        ],
      ),
      body: _buildBody(context, provider),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'addService',
            onPressed: () => _openCreateService(context),
            icon: const Icon(Icons.design_services),
            label: const Text('Add Service'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'addCompany',
            onPressed: () => _openCreateCompany(context),
            icon: const Icon(Icons.add_business),
            label: const Text('Add Company'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, CompanyProvider provider) {
    // 1. First load: spinner
    if (provider.isLoading && provider.companies.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Failed and nothing to show: error with retry
    if (provider.error != null && provider.companies.isEmpty) {
      return _MessageView(
        icon: Icons.cloud_off,
        title: 'Could not load companies',
        message: provider.error!,
        actionLabel: 'Retry',
        onAction: provider.fetchCompanies,
      );
    }

    // 3. Loaded but empty
    if (provider.companies.isEmpty) {
      return _MessageView(
        icon: Icons.business,
        title: 'No companies yet',
        message: 'Tap "Add Company" to create your first one.',
        actionLabel: 'Refresh',
        onAction: provider.fetchCompanies,
      );
    }

    // 4. The list (responsive: 1, 2 or 3 columns depending on width)
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        final width = constraints.maxWidth;
        final columns = width >= 1200 ? 3 : (width >= 800 ? 2 : 1);
        final cardWidth =
        ((width - spacing * 2 - spacing * (columns - 1)) / columns)
            .floorToDouble();

        return RefreshIndicator(
          onRefresh: provider.fetchCompanies,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(spacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (provider.isLoading) const LinearProgressIndicator(),
                if (provider.error != null) _ErrorBanner(message: provider.error!),
                const SizedBox(height: 8),
                Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: provider.companies
                      .map((company) => SizedBox(
                    width: cardWidth,
                    child: _CompanyCard(
                      company: company,
                      onAddService: () =>
                          _openCreateService(context, companyId: company.id),
                    ),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 140), // space so the buttons don't cover the last card
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CompanyCard extends StatelessWidget {
  const _CompanyCard({required this.company, required this.onAddService});

  final Company company;
  final VoidCallback onAddService;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(company.name.isNotEmpty ? company.name[0].toUpperCase() : '?'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Reg. No: ${company.registrationNumber}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'Services (${company.services.length})',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            if (company.services.isEmpty)
              Text(
                'No services yet',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...company.services.map((s) => _ServiceRow(service: s)),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onAddService,
                icon: const Icon(Icons.add),
                label: const Text('Add service'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.service});

  final Service service;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  service.description,
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formatPrice(service.price),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message, style: TextStyle(color: colors.onErrorContainer)),
    );
  }
}