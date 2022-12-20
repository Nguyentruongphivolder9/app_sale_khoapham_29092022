
import 'package:app_sale_khoapham_29092022/data/models/product.dart';

class Cart {
  String id = "";
  List<Product> products = [];
  String idUser = "";
  int price = 0;
  String dateCreated = "";

  Cart(String? id, List<Product>? products, String? iduser, int? price, String? datecreated) {
    this.id = id ?? "";
    this.products = products ?? [];
    this.idUser = iduser ?? "";
    this.price = price ?? 0;
    this.dateCreated = datecreated ?? "";
  }

  void updateCart(String? id, List<Product>? products, String? idUser, int? price, String? datacreated){
    this.id = id ?? "";
    this.products = products ?? [];
    this.idUser = idUser ?? "";
    this.price = price ?? 0;
    this.dateCreated = datacreated ?? "";
  }

  @override
  String toString() {
    return 'Cart{id: $id ,products: $products, id_user: $idUser, price: $price, date_created: $dateCreated }';
  }

  void clear() {
    this.products.clear();
    this.price = 0;
    this.dateCreated = "";
  }
}