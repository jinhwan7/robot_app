import 'package:flutter/material.dart';

// import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/src/provider/bluetooth_provider.dart';
import 'package:robot_app/src/ui/home_body.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('나와라');

    return Scaffold(
        appBar: AppBar(
          title: Text('ROS Integration App'),
        ),
        body: HomeBodyWidget());
  }
}
