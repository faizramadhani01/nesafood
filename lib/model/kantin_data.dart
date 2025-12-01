import 'menu.dart';

class Kantin {
  final String id; // <--- WAJIB: ID Unik untuk membedakan kantin
  final String name;
  final String image;
  double rating;
  final List<Menu> menus;
  final String categoryApi; 

  Kantin({
    required this.id, // Wajib diisi
    required this.name,
    required this.image,
    required this.rating,
    required this.menus,
    required this.categoryApi, 
  });
}

// DATA KANTIN (Pastikan ID ini sama dengan 'kantinId' di akun Admin Firebase Anda)
List<Kantin> kantinList = [
  Kantin(
    id: '1', // KANTIN 1
    name: 'Kantin 1 (Spesialis Ayam)',
    image: 'https://www.themealdb.com/images/category/Chicken.png',
    rating: 4.5,
    menus: [], 
    categoryApi: 'Chicken',
  ),
  Kantin(
    id: '2', // KANTIN 2
    name: 'Kantin 2 (Seafood Segar)',
    image: 'https://www.themealdb.com/images/category/Seafood.png',
    rating: 4.8,
    menus: [],
    categoryApi: 'Seafood',
  ),
  Kantin(
    id: '3',
    name: 'Kantin 3 (Western Food)',
    image: 'https://www.themealdb.com/images/category/Pasta.png',
    rating: 4.3,
    menus: [],
    categoryApi: 'Pasta', 
  ),
  Kantin(
    id: '4',
    name: 'Kantin 4 (Aneka Sarapan)',
    image: 'https://www.themealdb.com/images/category/Breakfast.png',
    rating: 4.6,
    menus: [],
    categoryApi: 'Breakfast', 
  ),
  Kantin(
    id: '5',
    name: 'Kantin 5 (Dessert)',
    image: 'https://www.themealdb.com/images/category/Dessert.png',
    rating: 4.7,
    menus: [],
    categoryApi: 'Dessert', 
  ),
  Kantin(
    id: '6',
    name: 'Kantin 6 (Vegetarian)',
    image: 'https://www.themealdb.com/images/category/Vegetarian.png',
    rating: 4.4,
    menus: [],
    categoryApi: 'Vegetarian', 
  ),
   Kantin(
    id: '7',
    name: 'Kantin 7 (Daging Sapi)',
    image: 'https://www.themealdb.com/images/category/Beef.png',
    rating: 4.9,
    menus: [],
    categoryApi: 'Beef', 
  ),
];