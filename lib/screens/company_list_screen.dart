import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/company.dart';
import '../providers/company_provider.dart';
import '../widgets/app_input.dart';
import '../widgets/company_card.dart';
import '../widgets/message_view.dart';
import '../widgets/summary_header.dart';
import '../widgets/top_bar.dart';
import 'create_company_screen.dart';
import 'create_service_screen.dart';

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({super.key});

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  // Search is local UI state: it only changes what THIS screen shows.
  // The provider still holds the full list, so the summary stats stay accurate.
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Company> _filter(List<Company> companies) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return companies;
    return companies
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.registrationNumber.toLowerCase().contains(q))
        .toList();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  void _openCreateCompany() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateCompanyScreen()),
    );
  }

  void _openCreateService({int? companyId}) {
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
    final companies = provider.companies;
    final filtered = _filter(companies);

    // Summary numbers (always for ALL companies, not just search results)
    final serviceCount =
        companies.fold<int>(0, (sum, c) => sum + c.services.length);
    final totalValue = companies.fold<double>(
      0,
      (sum, c) => sum + c.services.fold<double>(0, (s, sv) => s + sv.price),
    );

    return Scaffold(
      appBar: TopBar(
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: provider.isLoading ? null : provider.fetchCompanies,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Thin progress line while refreshing existing data
          SizedBox(
            height: 2,
            child: provider.isLoading && companies.isNotEmpty
                ? const LinearProgressIndicator(minHeight: 2)
                : null,
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 600;
                final gutter = isNarrow ? 16.0 : 32.0;
                final available = constraints.maxWidth - gutter * 2;
                final contentWidth = available > 1200 ? 1200.0 : available;
                final side = (constraints.maxWidth - contentWidth) / 2;

                return RefreshIndicator(
                  onRefresh: provider.fetchCompanies,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding:
                        EdgeInsets.fromLTRB(side, isNarrow ? 20 : 32, side, 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PageHeader(
                          isNarrow: isNarrow,
                          onNewCompany: _openCreateCompany,
                          onAddService: () => _openCreateService(),
                        ),
                        const SizedBox(height: 24),
                        SummaryHeader(
                          companyCount: companies.length,
                          serviceCount: serviceCount,
                          totalValue: totalValue,
                          compact: isNarrow,
                        ),
                        const SizedBox(height: 32),
                        _Toolbar(
                          isNarrow: isNarrow,
                          controller: _searchController,
                          onChanged: (value) => setState(() => _query = value),
                          onClear: _clearSearch,
                          resultLabel:
                              '${filtered.length} of ${companies.length} companies',
                        ),
                        const SizedBox(height: 16),
                        if (provider.error != null && companies.isNotEmpty) ...[
                          _ErrorBanner(message: provider.error!),
                          const SizedBox(height: 16),
                        ],
                        _buildContent(provider, filtered, contentWidth),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    CompanyProvider provider,
    List<Company> filtered,
    double width,
  ) {
    // 1. First load
    if (provider.isLoading && provider.companies.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 64),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // 2. Failed with nothing to show
    if (provider.error != null && provider.companies.isEmpty) {
      return MessageView(
        icon: Icons.cloud_off_outlined,
        title: 'Could not load companies',
        message: provider.error!,
        actionLabel: 'Try again',
        onAction: provider.fetchCompanies,
      );
    }

    // 3. Loaded but empty
    if (provider.companies.isEmpty) {
      return MessageView(
        icon: Icons.business_outlined,
        title: 'No companies yet',
        message: 'Create your first company to get started.',
        actionLabel: 'New company',
        onAction: _openCreateCompany,
      );
    }

    // 4. Search returned nothing
    if (filtered.isEmpty) {
      return MessageView(
        icon: Icons.search_off,
        title: 'No results',
        message: 'No company matches "$_query".',
        actionLabel: 'Clear search',
        onAction: _clearSearch,
      );
    }

    // 5. Responsive grid: 1, 2 or 3 columns
    const spacing = 16.0;
    final columns = width >= 1100 ? 3 : (width >= 700 ? 2 : 1);
    final cardWidth =
        ((width - spacing * (columns - 1)) / columns).floorToDouble();

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: filtered
          .map((company) => SizedBox(
                width: cardWidth,
                child: CompanyCard(
                  // Keeps each card's expanded state correct when filtering
                  key: ValueKey(company.id),
                  company: company,
                  onAddService: () => _openCreateService(companyId: company.id),
                ),
              ))
          .toList(),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.isNarrow,
    required this.onNewCompany,
    required this.onAddService,
  });

  final bool isNarrow;
  final VoidCallback onNewCompany;
  final VoidCallback onAddService;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Companies',
          style: TextStyle(
            fontSize: isNarrow ? 24 : 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage companies and the services they offer.',
          style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
        ),
      ],
    );

    final addService = OutlinedButton.icon(
      onPressed: onAddService,
      icon: const Icon(Icons.add, size: 18),
      label: const Text('Add service'),
    );
    final newCompany = FilledButton.icon(
      onPressed: onNewCompany,
      icon: const Icon(Icons.add, size: 18),
      label: const Text('New company'),
    );

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          titleBlock,
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: addService),
              const SizedBox(width: 8),
              Expanded(child: newCompany),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: titleBlock),
        addService,
        const SizedBox(width: 8),
        newCompany,
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.isNarrow,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.resultLabel,
  });

  final bool isNarrow;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String resultLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final search = TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: appInputDecoration(
        context,
        hint: 'Search by name or registration no.',
        dense: true,
        prefixIcon: Icon(Icons.search, size: 20, color: colors.onSurfaceVariant),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear',
                icon: const Icon(Icons.close, size: 18),
                onPressed: onClear,
              ),
      ),
    );

    if (isNarrow) return search;

    return Row(
      children: [
        SizedBox(width: 360, child: search),
        const Spacer(),
        Text(
          resultLabel,
          style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: colors.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: colors.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
