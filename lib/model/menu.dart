class Menu {
  String _name;
  String _image;
  double _price;
  String _description;

  Menu({
    required String name,
    required String image,
    required double price,
    required String description,
  })  : _name = name,
        _image = image,
        _price = price,
        _description = description;

  String get name => _name;
  String get image => _image;
  String get description => _description;
  
  double get price => _price;

  set price(double value) {
    if (value < 0) {
      print("Error: Harga tidak boleh di bawah 0!");
    } else {
      _price = value;
    }
  }

  set name(String value) => _name = value;
  set image(String value) => _image = value;
  set description(String value) => _description = value;

  String getCategory() => 'Menu';

  factory Menu.placeholder() => Menu(
        name: 'Unknown',
        image: 'assets/placeholder.png',
        price: 0.0,
        description: '',
      );
}
class Makanan extends Menu {
  Makanan({
    required super.name,
    required super.image,
    required super.price,
    required super.description,
  });

  @override
  String getCategory() => 'Makanan';
}

class Minuman extends Menu {
  Minuman({
    required super.name,
    required super.image,
    required super.price,
    required super.description,
  });

  @override
  String getCategory() => 'Minuman';
}

class SnackMenu extends Menu {
  SnackMenu({
    required super.name,
    required super.image,
    required super.price,
    required super.description,
  });

  @override
  String getCategory() => 'Snack';
}