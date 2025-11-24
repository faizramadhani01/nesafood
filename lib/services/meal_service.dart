// lib/services/meal_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/menu.dart';

class MealService {
  // URL API TheMealDB untuk kategori 'Chicken' (Ayam)
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  /// Mengambil data menu dari API
  Future<List<Menu>> fetchMeals() async {
    try {
      // Request data ke internet
      final response = await http.get(Uri.parse('$_baseUrl/filter.php?c=Chicken'));

      // Jika server menjawab OK (200)
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic>? mealsJson = data['meals'];

        if (mealsJson == null) return [];

        // Ubah data mentah (JSON) menjadi objek Menu aplikasi kita
        return mealsJson.map((json) {
          return Menu(
            name: json['strMeal'] ?? 'Unknown Meal',
            image: json['strMealThumb'] ?? 'assets/placeholder.png',
            // Karena API ini gratis & simpel, tidak ada harga.
            // Kita buat harga simulasi 25.000 agar tetap bisa masuk keranjang.
            price: 25000.0, 
            description: 'Menu spesial olahan ayam lezat dari resep internasional TheMealDB.',
          );
        }).toList();
      } else {
        throw Exception('Gagal koneksi ke server API');
      }
    } catch (e) {
      print('Error fetching API: $e');
      return []; // Kembalikan list kosong jika error (biar aplikasi tidak crash)
    }
  }
}