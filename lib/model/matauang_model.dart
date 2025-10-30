class CurrencyModel {
  final String code; // Contoh: "USD", "EUR", "IDR"
  final String name; // Contoh: "US Dollar", "Euro", "Rupiah"
  final double rate; // Nilai tukar terhadap mata uang dasar (misal: IDR)

  const CurrencyModel({
    required this.code,
    required this.name,
    required this.rate,
  });

  // Data mata uang simulasi (Anda bisa mengganti nilai tukar ini)
  static const List<CurrencyModel> supportedCurrencies = [
    // Mata uang dasar (rate 1.0)
    CurrencyModel(code: 'IDR', name: 'Rupiah Indonesia', rate: 1.0),

    // Nilai tukar simulasi terhadap IDR (Angka diperkirakan tahun 2025)
    CurrencyModel(
      code: 'USD',
      name: 'US Dollar',
      rate: 16500.0,
    ), // 1 USD = 16500 IDR
    CurrencyModel(
      code: 'EUR',
      name: 'Euro',
      rate: 18000.0,
    ), // 1 EUR = 18000 IDR
    CurrencyModel(
      code: 'JPY',
      name: 'Yen Jepang',
      rate: 105.0,
    ), // 1 JPY = 105 IDR
  ];
}
