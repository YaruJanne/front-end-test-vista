import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'providers/company_provider.dart';
import 'services/api_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CompanyProvider(ApiService())..fetchCompanies(),
      child: const VistaApp(),
    ),
  );
}

class VistaApp extends StatelessWidget {
  const VistaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vista Companies',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      // Temporary test screen, replaced by CompanyListScreen in Phase 6
      home: Scaffold(
        body: Center(
          child: Consumer<CompanyProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) return const CircularProgressIndicator();
              if (provider.error != null) return Text('Error: ${provider.error}');
              return Text('Loaded ${provider.companies.length} companies');
            },
          ),
        ),
      ),
    );
  }
}