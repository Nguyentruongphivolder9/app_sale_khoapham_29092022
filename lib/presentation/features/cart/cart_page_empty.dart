import 'package:flutter/material.dart';

class CartEmptyPage extends StatefulWidget {
  const CartEmptyPage({Key? key}) : super(key: key);

  @override
  State<CartEmptyPage> createState() => _CartEmptyPageState();
}

class _CartEmptyPageState extends State<CartEmptyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart Empty Page'),
      ),
      body: Container(
        color: Colors.white,
        child: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Đơn hàng hiện tại đang trống",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 20,),
                Container(
                  height: 250,
                  width: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: Colors.black)
                  ),
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}