import 'package:flutter/foundation.dart';

import '../models/company.dart';
import '../services/api_exception.dart';
import '../services/api_service.dart';

class CompanyProvider extends ChangeNotifier {
  CompanyProvider(this._api);

  final ApiService _api;

  List<Company> _companies = [];
  bool _isLoading = false;
  String? _error;

  List<Company> get companies => List.unmodifiable(_companies);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCompanies() async {
    _isLoading = true;
    _error = null;
    notifyListeners(); // UI shows a spinner

    try {
      _companies = await _api.getCompanies();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners(); // UI shows the list or the error
    }
  }

  // Errors are NOT caught here: the form screen catches them to show a SnackBar
  Future<void> addCompany({
    required String name,
    required String registrationNumber,
  }) async {
    await _api.createCompany(name: name, registrationNumber: registrationNumber);
    await fetchCompanies();
  }

  Future<void> addService({
    required int companyId,
    required String name,
    required String description,
    required double price,
  }) async {
    await _api.createService(
      companyId: companyId,
      name: name,
      description: description,
      price: price,
    );
    await fetchCompanies();
  }
}