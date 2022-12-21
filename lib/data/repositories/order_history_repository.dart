import 'dart:async';

import 'package:app_sale_khoapham_29092022/data/datasources/remote/api_request.dart';
import 'package:app_sale_khoapham_29092022/data/datasources/remote/dto/app_resource.dart';
import 'package:app_sale_khoapham_29092022/data/datasources/remote/dto/cart_dto.dart';
import 'package:dio/dio.dart';

class OrderHistoryRepository {
  late ApiRequest _apiRequest;

  void updateApiRequest(ApiRequest apiRequest) {
    _apiRequest = apiRequest;
  }

  Future<AppResource<List<CartDTO>>> orderHistory() async {
    Completer<AppResource<List<CartDTO>>> completer = Completer();
    try {
      Response<dynamic> response = await _apiRequest.orderHistory();
      AppResource<List<CartDTO>> resource =
          AppResource.fromJson(response.data, CartDTO.parserListCartDTO);
      completer.complete(resource);
    } catch (e) {
      completer.completeError(e.toString());
    }
    return completer.future;
  }
}