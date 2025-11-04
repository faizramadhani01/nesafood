import 'menu.dart';

class Kantin {
  final String name;
  final String image;
  final List<Menu> menus;

  const Kantin({required this.name, required this.image, required this.menus});
}

// Gunakan asset placeholder jika tidak ada gambar spesifik
const _ph = 'assets/placeholder_food.png';

// --- Kantin A (pertahankan image & beberapa menu awal) ---
final List<Menu> _kantinA = [
  Makanan(
    name: 'Nasi Goreng Spesial',
    image: 'assets/Nasi Goreng (Indonesian Fried Rice).jpg',
    price: 15000,
    description: 'Nasi goreng ala Kantin A, lengkap dengan telur dan ayam.',
  ),
  Makanan(
    name: 'Mie Ayam Pangsit',
    image: 'assets/Mie Ayam Pangsit.jpg',
    price: 14000,
    description: 'Mie ayam lezat disajikan dengan pangsit.',
  ),
  Makanan(
    name: 'Ayam Geprek Sambal Matah',
    image: 'assets/Ayam Geprek.jpg',
    price: 18000,
    description: 'Ayam geprek pedas sambal matah.',
  ),
  Makanan(
    name: 'Sate Ayam Madura',
    image: 'assets/Sate Ayam.jpg',
    price: 20000,
    description: 'Sate bumbu kacang, porsinya pas.',
  ),
  Makanan(
    name: 'Ikan Bakar Rica',
    image: 'assets/ikan bakar.jpg',
    price: 22000,
    description: 'Ikan bakar pedas rica-rica.',
  ),
  Minuman(
    name: 'Es Teh Manis',
    image: 'assets/es teh.jpg',
    price: 5000,
    description: 'Teh manis dingin.',
  ),
  Minuman(
    name: 'Kopi Susu Kekinian',
    image: 'assets/kopi susu.jpg',
    price: 12000,
    description: 'Kopi susu creamy.',
  ),
  Minuman(
    name: 'Jus Alpukat',
    image: 'assets/Jus Alpukat.jpg',
    price: 13000,
    description: 'Alpukat segar dilumat.',
  ),
  SnackMenu(
    name: 'Donat Gulung',
    image: 'assets/Donat Gulung.jpg',
    price: 6000,
    description: 'Donat lembut.',
  ),
  SnackMenu(
    name: 'Pisang Goreng Keju',
    image: 'assets/pisang goreng keju.jpg',
    price: 7000,
    description: 'Pisang goreng manis dengan keju.',
  ),
];

// --- Kantin B (10 menu random) ---
final List<Menu> _kantinB = [
  Makanan(
    name: 'Nasi Campur Spesial',
    image: _ph,
    price: 17000,
    description: 'Pilihan lauk beragam.',
  ),
  Makanan(
    name: 'Mie Goreng Jawa',
    image: _ph,
    price: 14000,
    description: 'Mie goreng bumbu Jawa.',
  ),
  Makanan(
    name: 'Ayam Bakar Taliwang',
    image: _ph,
    price: 20000,
    description: 'Ayam bakar pedas khas Lombok.',
  ),
  Minuman(
    name: 'Teh Tubruk',
    image: _ph,
    price: 6000,
    description: 'Teh tubruk hangat.',
  ),
  Minuman(
    name: 'Es Jeruk Segar',
    image: _ph,
    price: 9000,
    description: 'Jeruk peras dingin.',
  ),
  Minuman(
    name: 'Air Mineral',
    image: _ph,
    price: 4000,
    description: 'Air mineral kemasan.',
  ),
  SnackMenu(
    name: 'Pisang Goreng Original',
    image: _ph,
    price: 6000,
    description: 'Pisang goreng klasik.',
  ),
  SnackMenu(
    name: 'Kue Cubit',
    image: _ph,
    price: 7000,
    description: 'Kue cubit manis lembut.',
  ),
  Makanan(
    name: 'Nasi Pecel',
    image: _ph,
    price: 12000,
    description: 'Nasi dengan pecel sedap.',
  ),
  SnackMenu(
    name: 'Croissant Isi Cokelat',
    image: _ph,
    price: 15000,
    description: 'Croissant renyah.',
  ),
];

// --- Kantin C (10 menu random) ---
final List<Menu> _kantinC = [
  Makanan(
    name: 'Nasi Goreng Seafood',
    image: _ph,
    price: 20000,
    description: 'Nasi goreng campur seafood.',
  ),
  Makanan(
    name: 'Mie Rebus Spesial',
    image: _ph,
    price: 15000,
    description: 'Mie rebus dengan kuah kaya rasa.',
  ),
  Makanan(
    name: 'Tongseng Daging',
    image: _ph,
    price: 22000,
    description: 'Tongseng daging empuk.',
  ),
  Minuman(
    name: 'Es Cincau',
    image: _ph,
    price: 8000,
    description: 'Es cincau penyegar.',
  ),
  Minuman(
    name: 'Jus Mangga',
    image: _ph,
    price: 13000,
    description: 'Mangga segar.',
  ),
  Minuman(
    name: 'Kopi Hitam',
    image: _ph,
    price: 7000,
    description: 'Kopi hitam pekat.',
  ),
  SnackMenu(
    name: 'Poffertjes Mini',
    image: _ph,
    price: 9000,
    description: 'Poffertjes manis.',
  ),
  SnackMenu(
    name: 'Risoles Sayur',
    image: _ph,
    price: 7000,
    description: 'Risoles isi sayur.',
  ),
  SnackMenu(
    name: 'Donat Isi Selai',
    image: _ph,
    price: 8000,
    description: 'Donat dengan selai.',
  ),
  Makanan(
    name: 'Soto Betawi',
    image: _ph,
    price: 16000,
    description: 'Soto daging santan.',
  ),
];

// --- Kantin D (10 menu random) ---
final List<Menu> _kantinD = [
  Makanan(
    name: 'Nasi Timbel',
    image: _ph,
    price: 16000,
    description: 'Nasi timbel lengkap.',
  ),
  Makanan(
    name: 'Ayam Kecap',
    image: _ph,
    price: 17000,
    description: 'Ayam masak kecap manis.',
  ),
  Makanan(
    name: 'Sop Buntut',
    image: _ph,
    price: 28000,
    description: 'Sop buntut gurih.',
  ),
  Minuman(
    name: 'Es Soda Gembira',
    image: _ph,
    price: 10000,
    description: 'Soda manis dan segar.',
  ),
  Minuman(
    name: 'Teh Panas',
    image: _ph,
    price: 5000,
    description: 'Teh panas sederhana.',
  ),
  SnackMenu(
    name: 'Pisang Cokelat',
    image: _ph,
    price: 8000,
    description: 'Pisang goreng isi cokelat.',
  ),
  SnackMenu(
    name: 'Kroket Kentang',
    image: _ph,
    price: 9000,
    description: 'Kroket kentang renyah.',
  ),
  Makanan(
    name: 'Ikan Goreng Sambal Matah',
    image: _ph,
    price: 20000,
    description: 'Ikan goreng + sambal matah.',
  ),
  SnackMenu(
    name: 'Roti Bakar Cokelat',
    image: _ph,
    price: 10000,
    description: 'Roti bakar manis.',
  ),
  SnackMenu(
    name: 'Kue Putu',
    image: _ph,
    price: 7000,
    description: 'Kue putu wangi.',
  ),
];

// --- Kantin E (10 menu random) ---
final List<Menu> _kantinE = [
  Makanan(
    name: 'Nasi Padang Mini',
    image: _ph,
    price: 20000,
    description: 'Porsi kecil berbagai lauk padang.',
  ),
  Makanan(
    name: 'Gulai Ayam',
    image: _ph,
    price: 19000,
    description: 'Gulai ayam berempah.',
  ),
  Makanan(
    name: 'Ikan Gulai',
    image: _ph,
    price: 23000,
    description: 'Ikan dengan kuah gulai.',
  ),
  Minuman(
    name: 'Teh Tarik',
    image: _ph,
    price: 10000,
    description: 'Teh tarik manis.',
  ),
  Minuman(
    name: 'Kopi Tubruk',
    image: _ph,
    price: 8000,
    description: 'Kopi tubruk pekat.',
  ),
  Minuman(
    name: 'Es Cendol',
    image: _ph,
    price: 12000,
    description: 'Cendol manis legit.',
  ),
  SnackMenu(
    name: 'Onde-onde',
    image: _ph,
    price: 8000,
    description: 'Onde-onde isi kacang hijau.',
  ),
  SnackMenu(
    name: 'Pisang Keju Cokelat',
    image: _ph,
    price: 9000,
    description: 'Pisang goreng double topping.',
  ),
  SnackMenu(
    name: 'Kue Nastar',
    image: _ph,
    price: 10000,
    description: 'Kue kering manis.',
  ),
  SnackMenu(
    name: 'Tahu Crispy',
    image: _ph,
    price: 8000,
    description: 'Tahu goreng renyah.',
  ),
];

// Gabungkan menjadi list kantin (hanya 5 kantin)
final List<Kantin> kantinList = [
  Kantin(name: 'Kantin Bu Dar', image: 'assets/foodcourt.jpg', menus: _kantinA),
  Kantin(
    name: 'Kantin Bu Slamet',
    image: 'assets/kantin1.jpg',
    menus: _kantinB,
  ),
  Kantin(
    name: 'Kantin Pak Harjo',
    image: 'assets/kantin2.jpg',
    menus: _kantinC,
  ),
  Kantin(name: 'Kantin Dina', image: 'assets/kantin3.jpg', menus: _kantinD),
  Kantin(name: 'Kantin Paijo', image: 'assets/kantin4.jpg', menus: _kantinE),
];
