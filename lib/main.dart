import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/src/getX/infoclass.dart';
import 'package:robot_app/src/home.dart';
import 'package:robot_app/src/provider/bluetooth_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(INFOCLASS());
    return ChangeNotifierProvider(
      create: (BuildContext context) {
        return BlueToothProvider();
      },
      child: MaterialApp(
          title: 'ROS Integration App',
          home: HomeScreen()),
    );
  }
}
