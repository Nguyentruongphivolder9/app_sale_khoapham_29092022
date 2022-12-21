import 'dart:async';

import 'package:app_sale_khoapham_29092022/common/bases/base_bloc.dart';
import 'package:app_sale_khoapham_29092022/common/bases/base_event.dart';
import 'package:app_sale_khoapham_29092022/data/datasources/remote/dto/app_resource.dart';
import 'package:app_sale_khoapham_29092022/data/datasources/remote/dto/cart_dto.dart';
import 'package:app_sale_khoapham_29092022/data/datasources/remote/dto/product_dto.dart';
import 'package:app_sale_khoapham_29092022/data/models/cart.dart';
import 'package:app_sale_khoapham_29092022/data/models/product.dart';
import 'package:app_sale_khoapham_29092022/data/repositories/order_history_repository.dart';
import 'package:app_sale_khoapham_29092022/presentation/features/order_history/order_history_event.dart';

class OrderHistoryBloc extends BaseBloc {
  StreamController<List<Cart>> _streamController = StreamController.broadcast();
  StreamController<List<Cart>> get history => _streamController;

  late OrderHistoryRepository _orderHistoryRespository;

  void updateOrderHistoryRepository(OrderHistoryRepository orderHistoryRespository) {
    _orderHistoryRespository = orderHistoryRespository;
  }
  
  @override
  void dispatch(BaseEvent event) {
    switch (event.runtimeType) {
      case ShowOrderHistoryEvent:
        handleOrderHistoryEvent(event as ShowOrderHistoryEvent);
        break;
    }
  }

  void handleOrderHistoryEvent(ShowOrderHistoryEvent event) async{
    loadingSink.add(true);
    try{
      AppResource<List<CartDTO>> resourceDTO = await _orderHistoryRespository.orderHistory();
      if(resourceDTO.data == null) return;
      
      List<CartDTO> listCartDTO = resourceDTO.data!;
      print("listCartDTO length = ${listCartDTO.length}");
      List<Cart> listCart = [];
      listCartDTO.forEach((element) {
        List<dynamic> listProductResponse = element.products!;
        List<ProductDTO> listProductDTO = ProductDTO.parserListProducts(listProductResponse);
        List<Product> listProduct = listProductDTO.map((e){
          return Product(e.id, e.name, e.address, e.price, e.img, e.quantity, e.gallery);
        }).toList();

        print("order bloc : dataCreated = ${element.dateCreated}");
        listCart.add(Cart(element.id, listProduct, element.idUser, element.price, element.dateCreated));
      });

      listCart.forEach((element) {
        print("element ${element.toString()}");
      });
      _streamController.sink.add(listCart);
      loadingSink.add(false);
    } catch (e) {
      messageSink.add(e.toString());
      loadingSink.add(false);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _streamController.close();
  }
}