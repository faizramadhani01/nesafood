import 'menu.dart';

class Kantin {
  final String id;
  final String name;
  final String image;
  double rating;
  final List<Menu> menus;
  final String categoryApi;
  final String qrisUrl;

  Kantin({
    required this.id,
    required this.name,
    required this.image,
    required this.rating,
    required this.menus,
    required this.categoryApi,
    required this.qrisUrl,
  });
}

// DATA KANTIN YANG BARU (Link Gambar Sudah Diganti)
List<Kantin> kantinList = [
  Kantin(
    id: '1',
    name: 'Kantin 1 (Spesialis Ayam)',
    // GANTI LINK INI (Ini server yang sama dengan Kantin 2, pasti jalan)
    image: 'https://www.themealdb.com/images/category/Chicken.png', 
    rating: 4.5,
    menus: [],
    categoryApi: 'Chicken',
    qrisUrl: 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=Bayar%20ke%20Kantin%201',
  ),
  Kantin(
    id: '2',
    name: 'Kantin 2 (Seafood Segar)',
    image: 'https://www.themealdb.com/images/category/Seafood.png',
    rating: 4.8,
    menus: [],
    categoryApi: 'Seafood',
    qrisUrl: 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=Bayar%20ke%20Kantin%202',
  ),
  Kantin(
    id: '3',
    name: 'Kantin 3 (Western Food)',
    image: 'https://www.themealdb.com/images/category/Pasta.png',
    rating: 4.3,
    menus: [],
    categoryApi: 'Pasta',
    qrisUrl: 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=Bayar%20ke%20Kantin%203',
  ),
  Kantin(
    id: '4',
    name: 'Kantin 4 (Aneka Sarapan)',
    image: 'https://www.themealdb.com/images/category/Breakfast.png',
    rating: 4.6,
    menus: [],
    categoryApi: 'Breakfast',
    qrisUrl: 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=Bayar%20ke%20Kantin%204',
  ),
  Kantin(
    id: '5',
    name: 'Kantin 5 (Dessert)',
    image: 'https://www.themealdb.com/images/category/Dessert.png',
    rating: 4.7,
    menus: [],
    categoryApi: 'Dessert',
    qrisUrl: 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=Bayar%20ke%20Kantin%205',
  ),
  Kantin(
    id: '6',
    name: 'Kantin 6 (Vegetarian)',
    image: 'https://www.themealdb.com/images/category/Vegetarian.png',
    rating: 4.4,
    menus: [],
    categoryApi: 'Vegetarian',
    qrisUrl: 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=Bayar%20ke%20Kantin%206',
  ),
  Kantin(
    id: '7',
    name: 'Kantin 7 (Daging Sapi)',
    image: 'https://www.themealdb.com/images/category/Beef.png',
    rating: 4.9,
    menus: [],
    categoryApi: 'Beef',
    qrisUrl: 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=Bayar%20ke%20Kantin%207',
  ),
];