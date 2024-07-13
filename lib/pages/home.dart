import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      // Menu
      drawer: const Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountEmail: Text("danielsantiago@gmail.com"),
              accountName: Text("Daniel Santiago"),
              currentAccountPicture: Icon(Icons.person),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("H O M E"),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("S E T T I N G S"),
            ),
          ],
        ),
      ),

      //Cuadro de texto y botones


    );
  }
}
