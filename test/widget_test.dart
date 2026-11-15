import 'package:flutter_test/flutter_test.dart';
import 'package:front_end_test_vista/models/company.dart';

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
}