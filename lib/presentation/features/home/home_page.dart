import 'package:app_sale_khoapham_29092022/common/bases/base_widget.dart';
import 'package:app_sale_khoapham_29092022/common/constants/api_constant.dart';
import 'package:app_sale_khoapham_29092022/common/utils/extension.dart';
import 'package:app_sale_khoapham_29092022/common/widgets/loading_widget.dart';
import 'package:app_sale_khoapham_29092022/data/datasources/remote/api_request.dart';
import 'package:app_sale_khoapham_29092022/data/models/cart.dart';
import 'package:app_sale_khoapham_29092022/data/models/product.dart';
import 'package:app_sale_khoapham_29092022/data/repositories/cart_reponsitory.dart';
import 'package:app_sale_khoapham_29092022/data/repositories/product_repository.dart';
import 'package:app_sale_khoapham_29092022/presentation/features/cart/cart_bloc.dart';
import 'package:app_sale_khoapham_29092022/presentation/features/cart/cart_event.dart';
import 'package:app_sale_khoapham_29092022/presentation/features/home/home_bloc.dart';
import 'package:app_sale_khoapham_29092022/presentation/features/home/home_event.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return PageContainer(
      providers: [
        Provider(create: (context) => ApiRequest()),
        ProxyProvider<ApiRequest, ProductRepository>(
          create: (context) => ProductRepository(),
          update: (context, request, repository) {
            repository?.updateApiRequest(request);
            return repository!;
          },
        ),
        ProxyProvider<ProductRepository, ProductBloc>(
          create: (context) => ProductBloc(),
          update: (context, repository, bloc) {
            bloc?.updateProductRepo(repository);
            return bloc!;
          },
        ),
        ProxyProvider<ApiRequest, CartRepository>(
          create: (context) => CartRepository(),
          update: (context, request, repository) {
            repository?.updateApiRequest(request);
            return repository!;
          },
        ),
        ProxyProvider<CartRepository, CartBloc>(
          create: (context) => CartBloc(),
          update: (context, repository, cartBloc) {
            cartBloc?.updateCartRepo(repository);
            return cartBloc!;
          },
        )
      ],
      child: HomeContainer(),
    );
  }
}

class HomeContainer extends StatefulWidget {
  @override
  State<HomeContainer> createState() => _HomeContainerState();
}

class _HomeContainerState extends State<HomeContainer> {
  late ProductBloc bloc;
  late CartBloc cartBloc;

  @override
  void initState() {
    super.initState();
    bloc = context.read();
    cartBloc = context.read();
    bloc.eventSink.add(FetchProductEvent());
    cartBloc.eventSink.add(FetchCartEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          const Expanded(
            flex: 1,
            child: Center(
              child: Text(
                "FOOD",
                style: TextStyle(
                  color: Colors.pink,
                  fontWeight: FontWeight.bold,
                  fontSize: 25
                ),
              ),
            )
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context,"order-history");
                  }, 
                  icon: Icon(
                    Icons.history_outlined,
                    color: Colors.black,
                  )
                ),
                Consumer<CartBloc>(
                  builder: (context, bloc, child){
                    return StreamBuilder<Cart>(
                    initialData: null,
                    stream: bloc.streamController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError || snapshot.data == null || snapshot.data?.products.isEmpty == true) {
                        return IconButton(
                            icon: Icon(Icons.shopping_cart),
                            onPressed: () {
                              Navigator.pushNamed(context, "cart_empty");
                            }
                        );
                      }
                      int count = snapshot.data?.products.length ?? 0;

                      return Container(
                        margin: EdgeInsets.only(right: 10, top: 5),
                        child: Badge(
                            padding: EdgeInsets.all(10),
                            badgeContent: Text(count.toString(),
                                style: TextStyle(fontSize: 15, color: Colors.white)),
                            child: IconButton(
                                icon: Icon(Icons.shopping_cart),
                                onPressed: () {
                                  Navigator.pushNamed(context, "cart" );
                                })),
                      );
                    });
                  }
                ),
              ]
            ),
          )
        ],
      ),
      body: Stack(children: [
        StreamBuilder<List<Product>>(
            initialData: [],
            stream: bloc.products,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("Data is error");
              } else if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      return _buildItemFood(snapshot.data?[index]);
                    });
              } else {
                return Container();
              }
            }),
        LoadingWidget(child: Container(), bloc: bloc),
      ])
    );
  }
  Widget _buildItemFood(Product? product) {
    if (product == null) return Container();
    return Container(
      height: 135,
      child: Card(
        elevation: 5,
        shadowColor: Colors.blueGrey,
        child: Container(
          padding: EdgeInsets.only(top: 5, bottom: 5),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(ApiConstant.BASE_URL + product.img,
                    width: 150, height: 120, fit: BoxFit.fill),
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
                        child: Text(product.name.toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16)),
                      ),
                      Text("Gi?? : ${formatPrice(product.price)} ??",
                          style: TextStyle(fontSize: 12)),
                      ElevatedButton(
                        onPressed: () {
                          cartBloc.eventSink.add(AddCartEvent(product.id));
                        },
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Color.fromARGB(200, 240, 102, 61);
                              } else {
                                return Color.fromARGB(230, 240, 102, 61);
                              }
                            }),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10))))),
                        child:
                            Text("Add To Cart", style: TextStyle(fontSize: 14)),
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