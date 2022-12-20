import 'dart:isolate';

import 'package:app_sale_khoapham_29092022/common/constants/api_constant.dart';
import 'package:app_sale_khoapham_29092022/data/datasources/remote/dio_client.dart';
import 'package:dio/dio.dart';

import '../../../common/constants/variable_constant.dart' show VariableConstant;
import '../local/cache/app_cache.dart';

class ApiRequest {
  late Dio _dio;

  ApiRequest() {
    _dio = DioClient.instance.dio;
  }

  Future signInRequest(String email, String password) {
    return _dio.post(ApiConstant.SIGN_IN, data: {
      "email": email,
      "password": password
    });
  }

  Future signUpRequest(
      String name,
      String email,
      String phone,
      String password,
      String address
  ) {
    return _dio.post(ApiConstant.SIGN_UP, data: {
      "name": name,
      "phone": phone,
      "address": address,
      "email": email,
      "password": password
    });
  }

  Future getProducts() async{
    ReceivePort receivePort = ReceivePort();
    Isolate.spawn((SendPort sendPort) {
      _dio.get(ApiConstant.PRODUCTS)
          .then((value) => sendPort.send(value))
          .catchError((error) => sendPort.send(error));
    }, receivePort.sendPort);
    
    return receivePort.first;
  }

  Future getCart() {
    return _dio.get(ApiConstant.CART,
        options: Options(
            validateStatus: (status) {
              return status! <= 500;
            },
            headers: {
              "authorization":
                  "Bearer ${AppCache.getString(VariableConstant.TOKEN)}",
            }));
  }

  Future addToCart(String idProduct) {
    return _dio.post(ApiConstant.ADD_CART,
        data: {"id_product": idProduct},
        options: Options(
            validateStatus: (status) {
              return status! <= 500;
            },
            headers: {
              "authorization":
                  "Bearer ${AppCache.getString(VariableConstant.TOKEN)}",
            }));
  }
}