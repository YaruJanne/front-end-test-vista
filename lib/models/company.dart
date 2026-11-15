import 'service.dart';

class Company {
  final int id;
  final String name;
  final String registrationNumber;
  final List<Service> services;

  const Company({
    required this.id,
    required this.name,
    required this.registrationNumber,
    required this.services,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    final servicesJson = json['services'] as List<dynamic>? ?? [];
    return Company(
      id: json['id'] as int,
      name: json['name'] as String,
      registrationNumber: json['registrationNumber'] as String,
      services: servicesJson
          .map((s) => Service.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}