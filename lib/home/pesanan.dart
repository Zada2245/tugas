import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:tugas/model/produk_model.dart';
import 'package:tugas/model/matauang_model.dart';
import 'package:tugas/controllers/pesanan_controller.dart';

class OrderPage extends StatefulWidget {
  final ProdukModel produk;
  final int? currentUserId;

  const OrderPage({
    super.key,
    required this.produk,
    required this.currentUserId,
  });

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final TextEditingController _alamatController = TextEditingController();
  final MapController _mapController = MapController();

  LatLng _currentLatLng = LatLng(-7.797068, 110.370529);
  String _currentLocationText = "Yogyakarta, Indonesia (Simulasi)";
  String _locationStatus = "Lokasi terdeteksi";

  // Zona waktu
  final Map<String, String> _majorTimeZones = {
    'Waktu Lokal': 'Asia/Jakarta',
    'London (GMT)': 'Europe/London',
    'New York (EST)': 'America/New_York',
    'Tokyo (JST)': 'Asia/Tokyo',
    'Sydney (AEST)': 'Australia/Sydney',
  };
  late String _selectedTimeZoneId;
  DateTime _convertedTime = DateTime.now();
  final DateFormat _timeFormatter = DateFormat('HH:mm (dd MMM)', 'id_ID');

  // Mata uang
  CurrencyModel _selectedCurrency = CurrencyModel.supportedCurrencies.first;

  // Pesanan
  bool _isSubmitting = false;
  final PesananController _pesananController = PesananController();

  @override
  void initState() {
    super.initState();
    _initLocalTimeZone();
  }

  void _initLocalTimeZone() {
    final localLocation = tz.local;
    _selectedTimeZoneId = localLocation.name;
    _updateConvertedTime(localLocation.name);
  }

  void _updateConvertedTime(String timeZoneId) {
    final nowInLocal = tz.TZDateTime.now(tz.local);
    final selectedLocation = tz.getLocation(timeZoneId);
    setState(() {
      _selectedTimeZoneId = timeZoneId;
      _convertedTime = tz.TZDateTime.from(nowInLocal, selectedLocation);
    });
  }

  /// ✅ NEW: Mendapatkan nama alamat dari koordinat (reverse geocoding)
  Future<void> _getAddressFromLatLng(double lat, double lon) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'FlutterMapApp/1.0'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['display_name'] != null) {
          setState(() {
            _currentLocationText = data['display_name'];
            _locationStatus = "Alamat ditemukan!";
          });
        } else {
          setState(() => _locationStatus = "Alamat tidak ditemukan.");
        }
      }
    } catch (e) {
      setState(() => _locationStatus = "Gagal memuat alamat: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _locationStatus = "Mengambil lokasi...");

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationStatus = "Layanan lokasi tidak aktif.");
      return;
    }

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => _locationStatus = "Akses lokasi ditolak.");
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLatLng = LatLng(position.latitude, position.longitude);
      _mapController.move(_currentLatLng, 15.0);
      _locationStatus = "Lokasi ditemukan!";
    });

    // 🔹 Ambil nama alamat otomatis
    await _getAddressFromLatLng(position.latitude, position.longitude);
  }

  Future<void> _searchAddress(String address) async {
    if (address.isEmpty) return;
    setState(() => _locationStatus = "Mencari alamat...");
    final url =
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(address)}&format=json&limit=1';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'FlutterMapApp/1.0'},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          setState(() {
            _currentLatLng = LatLng(lat, lon);
            _currentLocationText = data[0]['display_name'];
            _mapController.move(_currentLatLng, 15.0);
            _locationStatus = "Alamat ditemukan!";
          });
        } else {
          setState(() => _locationStatus = "Alamat tidak ditemukan.");
        }
      } else {
        setState(() => _locationStatus = "Gagal menghubungi server.");
      }
    } catch (e) {
      setState(() => _locationStatus = "Gagal mencari alamat: $e");
    }
  }

  NumberFormat _getCurrencyFormatter() {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: _selectedCurrency.code == 'IDR'
          ? 'Rp '
          : '${_selectedCurrency.code} ',
      decimalDigits: 0,
    );
  }

  double _getConvertedPrice() => widget.produk.harga / _selectedCurrency.rate;

  Future<void> _submitOrder() async {
    setState(() => _isSubmitting = true);
    try {
      if (widget.currentUserId == null)
        throw Exception('User ID tidak ditemukan.');
      if (widget.produk.stok != null && widget.produk.stok! <= 0)
        throw Exception('Stok produk habis!');

      final result = await _pesananController.createOrder(
        userId: widget.currentUserId!,
        produkId: widget.produk.id,
        totalHarga: widget.produk.harga,
        lokasiSewa: _currentLocationText,
        produkStokSaatIni: widget.produk.stok,
      );

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pemesanan berhasil! ${result['message']}'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat pesanan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = _getCurrencyFormatter();
    final convertedPrice = _getConvertedPrice();

    return Scaffold(
      appBar: AppBar(title: const Text('Halaman Pemesanan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pemesanan untuk: ${widget.produk.nama}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 30),

            // Konversi Mata Uang (Tampilan Saja)
            const Text(
              'Konversi Mata Uang (Tampilan Saja)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<CurrencyModel>(
              decoration: const InputDecoration(
                labelText: 'Pilih Mata Uang',
                border: OutlineInputBorder(),
              ),
              value: _selectedCurrency,
              items: CurrencyModel.supportedCurrencies
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text('${c.code} (${c.name})'),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCurrency = val);
              },
            ),
            const SizedBox(height: 15),
            Card(
              color: Colors.teal.withOpacity(0.15),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Harga Asli (IDR): Rp ${widget.produk.harga.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Setara dengan: ${currencyFormatter.format(convertedPrice)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 30),

            // Lokasi Pengambilan
            const Text(
              'Lokasi Pengambilan (LBS)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _alamatController,
              decoration: InputDecoration(
                labelText: 'Cari alamat...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchAddress(_alamatController.text),
                ),
              ),
              onSubmitted: _searchAddress,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text("Gunakan Lokasi Saya"),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _locationStatus,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 200,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentLatLng,
                  initialZoom: 15,
                  onTap: (tapPosition, latLng) async {
                    setState(() {
                      _currentLatLng = latLng;
                      _locationStatus = "Memuat alamat...";
                    });
                    await _getAddressFromLatLng(
                      latLng.latitude,
                      latLng.longitude,
                    );
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentLatLng,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Text(
              'Alamat saat ini:',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            Text(
              _currentLocationText,
              style: const TextStyle(
                fontSize: 13,
                color: Color.fromARGB(221, 255, 255, 255),
              ),
            ),

            const Divider(height: 30),

            // Konversi Waktu Dunia
            const Text(
              'Konversi Waktu Dunia (Tampilan Saja)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Pilih Zona Waktu',
                border: OutlineInputBorder(),
              ),
              value: _selectedTimeZoneId,
              items: _majorTimeZones.entries
                  .map(
                    (e) => DropdownMenuItem(value: e.value, child: Text(e.key)),
                  )
                  .toList(),
              onChanged: (newValue) {
                if (newValue != null) _updateConvertedTime(newValue);
              },
            ),
            const SizedBox(height: 15),
            Card(
              color: Colors.blueGrey.withOpacity(0.15),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Waktu di Zona Lokal:',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      _timeFormatter.format(tz.TZDateTime.now(tz.local)),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Waktu di Zona Pilihan:',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      _timeFormatter.format(_convertedTime),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 30),

            // Tombol submit
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitOrder,
              icon: _isSubmitting
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                _isSubmitting ? 'Memproses...' : 'Konfirmasi Pemesanan',
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
