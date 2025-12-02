import 'package:dio/dio.dart';
import '../model/menu.dart';

class MealService {
  final Dio _dio = Dio();

  // Endpoint TheMealDB
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // Fungsi untuk generate rating unik berdasarkan ID atau nama menu
  double _generateRating(String idMeal, String mealName) {
    // Menggunakan hash dari id dan nama untuk generate rating yang konsisten
    final combined = '$idMeal-$mealName';
    int hash = combined.hashCode.abs();

    // Rating dari 1.0 sampai 5.0 dengan step 0.5
    List<double> ratings = [1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0];
    return ratings[hash % ratings.length];
  }

  // 1. Fungsi Utama: Ambil menu berdasarkan kategori (Chicken, Seafood, dll)
  Future<List<Menu>> fetchMenuByCategory(String category) async {
    try {
      // Menggunakan DIO untuk GET request
      final response = await _dio.get(
        '$_baseUrl/filter.php',
        queryParameters: {'c': category},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final List<dynamic>? mealsJson = data['meals'];

        if (mealsJson == null) return [];

        // Mapping JSON ke Model Menu
        return mealsJson.map((json) {
          // Trik Simulasi Harga: Karena API tidak ada harga, kita buat random berdasarkan ID
          double fakePrice = 15000 + (int.parse(json['idMeal']) % 20) * 1000;

          // Generate rating unik untuk setiap menu
          double rating = _generateRating(
            json['idMeal'].toString(),
            json['strMeal'] ?? '',
          );

          return Menu(
            name: json['strMeal'] ?? 'Unknown Meal',
            image: json['strMealThumb'] ?? '',
            price: fakePrice,
            description:
                'Menu spesial dari kategori $category yang lezat dan bergizi.',
            rating: rating,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error Fetching Menu (Dio): $e');
      return [];
    }
  }

  // 2. Fungsi untuk Landing Page (Menu Rekomendasi)
  // Kita ambil kategori 'Beef' sebagai contoh menu spesial di halaman depan
  Future<List<Menu>> fetchMeals() async {
    return fetchMenuByCategory('Beef');
  }
}
