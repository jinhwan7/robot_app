import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/src/provider/bluetooth_provider.dart';
import 'package:robot_app/src/ui/home_body.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<BluetoothService> bleService = [];
  Color color = Colors.red;
  bool isConnected = false;

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
    bleService = Provider.of<BlueToothProvider>(context).connectedService;
    print('나와라 $bleService');
    if (bleService.isNotEmpty) {
      color = Colors.green;
    }
    return Scaffold(
        appBar: AppBar(
          title: Text('ROS Integration App'),
          actions: <Widget>[
            // 연결 상태에 따른 인디케이터 추가
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            )
          ],
        ),
        body: HomeBodyWidget());
  }
}
