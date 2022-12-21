import 'package:app_sale_khoapham_29092022/common/bases/base_widget.dart';
import 'package:app_sale_khoapham_29092022/common/utils/extension.dart';
import 'package:app_sale_khoapham_29092022/data/datasources/remote/api_request.dart';
import 'package:app_sale_khoapham_29092022/data/models/cart.dart';
import 'package:app_sale_khoapham_29092022/data/repositories/order_history_repository.dart';
import 'package:app_sale_khoapham_29092022/presentation/features/order_history/order_history_bloc.dart';
import 'package:app_sale_khoapham_29092022/presentation/features/order_history/order_history_event.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({Key? key}) : super(key: key);

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return PageContainer( 
    providers: [
      Provider<ApiRequest>(create: (context)=>ApiRequest(),),
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
          })
    ],
    child: _OrderHistoryContainer(),
    );
  }
}

class _OrderHistoryContainer extends StatefulWidget {
  const _OrderHistoryContainer({Key? key}) : super(key: key);

  @override
  State<_OrderHistoryContainer> createState() => _OrderHistoryContainerState();
}

class _OrderHistoryContainerState extends State<_OrderHistoryContainer> {
  late OrderHistoryBloc _bloc;
  @override
  void initState() {
    super.initState();
    _bloc = context.read();
    _bloc.eventSink.add(ShowOrderHistoryEvent());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order History"),
      ),
      body: SafeArea(
        child: Container(
          child:  StreamBuilder<List<Cart>>(
            stream: _bloc.history.stream,
            builder: (context,snapshot){
              if (snapshot.hasError) {
                return Container(
                  child: Center(child: Text("Data error")),
                );
              }
              if (snapshot.hasData && snapshot.data! == []) {
                return Center(
                  child: Center(child: Text("Data empty")),
                );
              }
              return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 15),

                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (context,index){
                    return Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: _orderItemWidget(context,snapshot.data![index]));
                  });
            },
          ),
        )
      )
    );
    
  }

  Widget _orderItemWidget(BuildContext context, Cart item){
    return InkWell(
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.black,
          ),
          borderRadius: BorderRadius.circular(20.0), //<-- SEE HERE
        ),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal:25,vertical: 10),
          width:  MediaQuery.of(context).size.width*0.8,
          height: 100,
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      item.dateCreated, 
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                      ),
                    )
                  ),
                  Flexible(
                    child: Text(
                      "Giá : ${formatPrice(item.price)}", 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 18,
                        color: Colors.black
                      ),
                    )
                  )
                ],
              ),
              Container(
                child: Text(
                  "Chi tiết",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.red
                  ),
                )
              ),
            ],
          )
        ),
      ),
      onTap: (){},
    );
  }
}