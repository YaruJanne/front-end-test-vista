/// Formats 1500 → "RM 1,500.00"
String formatPrice(double price) {
  final parts = price.toStringAsFixed(2).split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
  );
  return 'RM $whole.${parts[1]}';
}