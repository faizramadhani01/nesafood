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

// DATA KANTIN (UPDATE: GAMBAR SUASANA TOKO/WARUNG REAL)
List<Kantin> kantinList = [
  Kantin(
    id: '1',
    name: 'Kantin 1 (Spesialis Ayam)',
    // Warung Makan Lesehan / Tenda
    image: 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?auto=format&fit=crop&w=600&q=80', 
    rating: 4.5,
    menus: [],
    categoryApi: 'Chicken',
    qrisUrl: 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=Bayar%20ke%20Kantin%201',
  ),
  Kantin(
    id: '2',
    name: 'Kantin 2 (Seafood Segar)',
    // UPDATE: Gambar Pasar Ikan / Kedai Seafood
    image: 'assets/kantin2.jpg',
    rating: 4.8,
    menus: [],
    categoryApi: 'Seafood',
    qrisUrl: 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=Bayar%20ke%20Kantin%202',
  ),
  Kantin(
    id: '3',
    name: 'Kantin 3 (Western Food)',
    // Cafe Modern
    image: 'https://images.unsplash.com/photo-1559339352-11d035aa65de?auto=format&fit=crop&w=600&q=80',
    rating: 4.3,
    menus: [],
    categoryApi: 'Pasta',
    qrisUrl: 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=Bayar%20ke%20Kantin%203',
  ),
  Kantin(
    id: '4',
    name: 'Kantin 4 (Aneka Sarapan)',
    // Coffee Shop / Bakery Pagi
    image: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=600&q=80',
    rating: 4.6,
    menus: [],
    categoryApi: 'Breakfast',
    qrisUrl: 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=Bayar%20ke%20Kantin%204',
  ),
  Kantin(
    id: '5',
    name: 'Kantin 5 (Dessert)',
    // UPDATE: Gambar Toko Kue / Etalase Bakery
    image: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80',
    rating: 4.7,
    menus: [],
    categoryApi: 'Dessert',
    qrisUrl: 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=Bayar%20ke%20Kantin%205',
  ),
  Kantin(
    id: '6',
    name: 'Kantin 6 (Vegetarian)',
    // UPDATE: Gambar Rak Sayur / Pasar Buah
    image: 'assets/kantin6.jpg',
    rating: 4.4,
    menus: [],
    categoryApi: 'Vegetarian',
    qrisUrl: 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=Bayar%20ke%20Kantin%206',
  ),
  Kantin(
    id: '7',
    name: 'Kantin 7 (Daging Sapi)',
    // Steak House
    image: 'assets/kantin7.jpg',
    rating: 4.9,
    menus: [],
    categoryApi: 'Beef',
    qrisUrl: 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=Bayar%20ke%20Kantin%207',
  ),
];