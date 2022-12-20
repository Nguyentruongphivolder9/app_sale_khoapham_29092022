import 'dart:async';

import 'package:app_sale_khoapham_29092022/data/models/cart.dart';
import 'package:app_sale_khoapham_29092022/data/models/product.dart';

import '../../../common/bases/base_bloc.dart';
import '../../../common/bases/base_event.dart';
import '../../../common/constants/variable_constant.dart';
import '../../../data/datasources/local/cache/app_cache.dart';
import '../../../data/datasources/remote/dto/app_resource.dart';
import '../../../data/datasources/remote/dto/cart_dto.dart';
import '../../../data/datasources/remote/dto/product_dto.dart';
import '../../../data/repositories/cart_reponsitory.dart';
import 'cart_event.dart';

class CartBloc extends BaseBloc {
  StreamController<Cart> _streamController = StreamController.broadcast();
  StreamController<Cart> get streamController => _streamController;
  Cart? _cartModel ;

  late CartRepository _cartRepository;
  late List<Product> listProduct;
  
  void updateCartRepo(CartRepository cartRepository){
    _cartRepository = cartRepository;
  }

  @override
  void dispatch(BaseEvent event) {
    switch (event.runtimeType) {
      case FetchCartEvent:
        handleFetchCartEvent();
        break;
      case AddCartEvent:
        handleAddCartEvent(event as AddCartEvent);
        break;
      case IncreaseCartItemEvent:
        handleIncreaseCartEvent(event as IncreaseCartItemEvent);
        break;
    }
  }

  void handleAddCartEvent(AddCartEvent event) async{
    loadingSink.add(true);
    try{
      AppResource<CartDTO> appResourceDTO = await _cartRepository.addToCart(event.idProduct);
      if (appResourceDTO.data == null) return;
      handleFetchCartEvent();
    }catch (e){
      messageSink.add(e.toString());
      loadingSink.add(false);
    }
  }

  void handleFetchCartEvent() async{
    loadingSink.add(true);
    try{
      AppResource<CartDTO> resourceCartDTO = await _cartRepository.getCart();
      if(resourceCartDTO.data == null) return;

      CartDTO cartDTO = resourceCartDTO.data!;

      if(cartDTO.products != null) {
        List<dynamic> listProductResponse= cartDTO.products!;
        List<ProductDTO> listProductDTO = ProductDTO.parserListProducts(listProductResponse);
        listProduct = listProductDTO.map((e){
          return Product(e.id, e.name, e.address, e.price, e.img, e.quantity, e.gallery);
        }).toList();
      }

      _cartModel = Cart(cartDTO.id, listProduct, cartDTO.idUser, cartDTO.price, cartDTO.dateCreated);
      AppCache.setString(key: VariableConstant.CART_ID,value: _cartModel!.id.toString());
      _streamController.sink.add(_cartModel!);
      loadingSink.add(false);
    } catch (e) {
      messageSink.add(e.toString());
      loadingSink.add(false);
    }
  }

  int getQuantityFromIdProduct(String id){
    int quantity = 0;
    if(_cartModel == null) {
      return 0;
    }

    for(int i = 0; i<_cartModel!.products.length;i++){
      if(_cartModel!.products[i].id == id){
        quantity = _cartModel!.products[i].quantity;
      }
    }
    return quantity;
  }

  void handleIncreaseCartEvent(IncreaseCartItemEvent event) async{
    loadingSink.add(true);
    try{
      int quantity = getQuantityFromIdProduct(event.idProduct);
      AppResource<CartDTO> resourceDTO;
      if(quantity == 0) {
        quantity = event.quantity;
        resourceDTO = await _cartRepository.addToCart(event.idProduct);
      } else {
        quantity += event.quantity;
        resourceDTO = await _cartRepository.updateCart(event.idProduct, quantity);
      }
      if (resourceDTO.data == null) return;
      handleFetchCartEvent();
    } catch (e) {
      messageSink.add(e.toString());
      loadingSink.add(false);
    }
  }

  void handleDecreaseCartEvent(DecreaseCartItemEvent event) async{
    loadingSink.add(true);
    try{
      int quantity = getQuantityFromIdProduct(event.idProduct);
      quantity -= event.quantity;
      AppResource<CartDTO> resourceDTO = await _cartRepository.updateCart(event.idProduct, quantity);
      
      if (resourceDTO.data == null) return;
      handleFetchCartEvent();
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