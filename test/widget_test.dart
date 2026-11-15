import 'package:flutter_test/flutter_test.dart';
import 'package:front_end_test_vista/models/company.dart';
import 'package:front_end_test_vista/utils/format.dart';

void main() {
  test('Company.fromJson parses company with nested services', () {
    final company = Company.fromJson({
      'id': 1,
      'name': 'Vista Sdn Bhd',
      'registrationNumber': '202301000123',
      'services': [
        {
          'id': 1,
          'companyId': 1,
          'name': 'Web Design',
          'description': 'Company website design',
          'price': 1500,
        },
      ],
    });

    expect(company.name, 'Vista Sdn Bhd');
    expect(company.services.length, 1);
    expect(company.services.first.price, 1500.0);
  });

  test('Company.fromJson handles missing services list', () {
    final company = Company.fromJson({
      'id': 2,
      'name': 'Acme Sdn Bhd',
      'registrationNumber': '202401000999',
    });

    expect(company.services, isEmpty);
  });

  test('formatPrice adds currency, thousands separators and 2 decimals', () {
    expect(formatPrice(0), 'RM 0.00');
    expect(formatPrice(300), 'RM 300.00');
    expect(formatPrice(1500), 'RM 1,500.00');
    expect(formatPrice(1234567.5), 'RM 1,234,567.50');
  });
}
