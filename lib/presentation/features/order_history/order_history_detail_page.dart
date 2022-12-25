import 'package:app_sale_khoapham_29092022/common/bases/base_widget.dart';
import 'package:app_sale_khoapham_29092022/common/constants/api_constant.dart';
import 'package:app_sale_khoapham_29092022/common/utils/extension.dart';
import 'package:app_sale_khoapham_29092022/data/datasources/remote/api_request.dart';
import 'package:app_sale_khoapham_29092022/data/models/cart.dart';
import 'package:app_sale_khoapham_29092022/data/models/product.dart';
import 'package:app_sale_khoapham_29092022/data/repositories/order_history_repository.dart';
import 'package:app_sale_khoapham_29092022/presentation/features/order_history/order_history_bloc.dart';
import 'package:app_sale_khoapham_29092022/presentation/features/order_history/order_history_event.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({Key? key}) : super(key: key);

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  Widget build(BuildContext context) {
    return PageContainer(
      providers: [
        Provider(create: (context) => ApiRequest()),
        ProxyProvider<ApiRequest, OrderHistoryRepository>(
        create: (context)=>OrderHistoryRepository(),
        update: (context,apiRequest,orderRespository){
          orderRespository?.updateApiRequest(apiRequest);
          return orderRespository!;
      },),
      ProxyProvider<OrderHistoryRepository,OrderHistoryBloc>(
          create: (context)=>OrderHistoryBloc(),
          update: (context, orderRespository, orderBloc){
            orderBloc?.updateOrderHistoryRepository(orderRespository);
            return orderBloc!;
      },),
      ],
      child: OrderDetailContainer(),
    );
  }
}

class OrderDetailContainer extends StatefulWidget {

  @override
  State<OrderDetailContainer> createState() => _OrderDetailContainerState();
}

class _OrderDetailContainerState extends State<OrderDetailContainer> {
  late OrderHistoryBloc _blocHistory;

  @override
  void initState() {
    super.initState();
    _blocHistory = context.read();
    _blocHistory.eventSink.add(ShowOrderHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order detail'),
      ),
      body: Container(
        child: StreamBuilder<List<Cart>>(
          initialData: null,
          stream: _blocHistory.history.stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("Data is error");
            } else if (snapshot.hasData) {
              List CartDetail = snapshot.data?.toList() ?? [] ;
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemCount: CartDetail.length, // ?? 0
                        itemBuilder: (lstContext, index) =>
                            _buildItem(CartDetail[index], context)),
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(10),
                      child: Text(
                          "Tổng tiền : 200.000 đ",
                          style: TextStyle(fontSize: 25, color: Colors.white))),
                ],
              );
            } else {
              return Container();
            }
          }
        ),
      ),
    );
  }

  Widget _buildItem(Product product, BuildContext context) {
    return Container(
      height: 135,
      child: Card(
        elevation: 5,
        shadowColor: Colors.blueGrey,
        child: Container(
          padding: EdgeInsets.only(top: 5, bottom: 5),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.network(
                      ApiConstant.BASE_URL + (product.img).toString(),
                      width: 150,
                      height: 120,
                      fit: BoxFit.fill),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16)),
                      ),
                      Text("Giá : ${formatPrice(product.price)} đ",
                          style: TextStyle(fontSize: 12)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text("Số lượng: ${product.quantity.toString()}",
                            style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}