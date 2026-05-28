import 'package:flutter/material.dart';

class NavModelCustom extends StatelessWidget {
  const NavModelCustom({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height*0.087,
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            offset: Offset(0,10),
            blurRadius: 10
          )
        ]
      ),
    );
  }
}
