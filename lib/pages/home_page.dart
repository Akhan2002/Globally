import 'package:flutter/material.dart';
import 'package:globally/components/my_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              "Home",
              textAlign: TextAlign.center,
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: MyDrawer(),
    );
  }
}