import 'package:app_sale_khoapham_29092022/data/datasources/remote/api_request.dart';

abstract class BaseRepository {
  late ApiRequest apiRequest;

  void updateRequest(ApiRequest apiRequest) {
    this.apiRequest = apiRequest;
  }
}