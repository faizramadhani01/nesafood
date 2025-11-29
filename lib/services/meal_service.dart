import 'package:dio/dio.dart'; 
import '../model/menu.dart';

class MealService {
  
  final Dio _dio = Dio(); 

  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1'; 

  Future<List<Menu>> fetchMeals() async {
    try {
      final response = await _dio.get('$_baseUrl/filter.php?c=Chicken'); 

      if (response.statusCode == 200) { 
        final Map<String, dynamic> data = response.data;
        final List<dynamic>? mealsJson = data['meals']; 

        if (mealsJson == null) return [];

        return mealsJson.map((json) { 
          return Menu(
            name: json['strMeal'] ?? 'Unknown Meal', 
            image: json['strMealThumb'] ?? 'assets/placeholder.png', 
            price: 25000.0, 
            description: 'Menu spesial olahan ayam lezat dari resep internasional TheMealDB.', 
          );
        }).toList(); 
      }
      return [];
    } on DioException catch (e) { 
      print('Error fetching API with Dio: $e'); 
      return []; 
    } catch (e) {
      print('Unknown error fetching API: $e'); //
      return []; 
    }
  }
}