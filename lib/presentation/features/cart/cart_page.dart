import 'package:app_sale_khoapham_29092022/data/models/cart.dart';
import 'package:app_sale_khoapham_29092022/data/models/product.dart';
import 'package:app_sale_khoapham_29092022/presentation/features/cart/cart_event.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/bases/base_widget.dart';
import '../../../common/constants/api_constant.dart';
import '../../../common/utils/extension.dart';
import '../../../data/datasources/remote/api_request.dart';
import '../../../data/repositories/cart_reponsitory.dart';
import 'cart_bloc.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return PageContainer(
      providers: [
        Provider(create: (context) => ApiRequest()),
        ProxyProvider<ApiRequest, CartRepository>(
          create: (context) => CartRepository(),
          update: (context, request, repository) {
            repository?.updateApiRequest(request);
            return repository!;
          },
        ),
        ProxyProvider<CartRepository, CartBloc>(
          create: (context) => CartBloc(),
          update: (context, repository, bloc) {
            bloc?.updateCartRepo(repository);
            return bloc!;
          },
        )
      ],
      child: CartContainer(),
    );
  }
}

class CartContainer extends StatefulWidget {

  @override
  State<CartContainer> createState() => _CartContainerState();
}

class _CartContainerState extends State<CartContainer> {
  late CartBloc cartBloc;

  @override
  void initState() {
    super.initState();
    cartBloc = context.read();
    cartBloc.eventSink.add(FetchCartEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart Page'),
      ),
      body: Container(
        child: StreamBuilder<Cart>(
          initialData: null,
          stream: cartBloc.streamController.stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("Data is error");
            } else if (snapshot.hasData) {
              List ProductCart = snapshot.data?.products ?? [];
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemCount: ProductCart.length, // ?? 0
                        itemBuilder: (lstContext, index) =>
                            _buildItem(ProductCart[index], context)),
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Text(
                          "Tổng tiền : ${formatPrice(snapshot.data?.price ?? 0)} đ",
                          style: TextStyle(fontSize: 25, color: Colors.white))),
                  Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(Colors.deepOrange)),
                        child: Text("Order",
                            style: TextStyle(color: Colors.white, fontSize: 25)),
                      ))
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
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              cartBloc.eventSink.add(DecreaseCartItemEvent(product.id, 1));
                            },
                            child: Text("-"),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(product.quantity.toString(),
                                style: TextStyle(fontSize: 16)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              cartBloc.eventSink.add(IncreaseCartItemEvent(product.id, 1));
                            },
                            child: Text("+"),
                          ),
                        ],
                      )
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