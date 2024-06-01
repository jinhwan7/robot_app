// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
//
// class BluetoothSereial extends StatefulWidget {
//   @override
//   _BluetoothPageState createState() => _BluetoothPageState();
// }
//
// class _BluetoothPageState extends State<BluetoothSereial> {
//   FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
//   List<BluetoothDiscoveryResult> results = [];
//   bool _isScanning = false;
//
//   @override
//   void initState() {
//     super.initState();
//     initializeBluetooth();
//   }
//
//   void initializeBluetooth() async {
//     // 블루투스 활성화
//     await bluetooth.requestEnable();
//
//     // 블루투스 상태 확인
//     BluetoothState state = await bluetooth.state;
//     print("Bluetooth state: $state");
//
//     // 장치 스캔 시작
//     startDiscovery();
//   }
//
//   void startDiscovery() {
//     results.clear();
//     bluetooth.startDiscovery().listen((r) {
//       setState(() {
//         results.add(r);
//       });
//       print('Discovered device: ${r.device.name} (${r.device.address})');
//     }).onDone(() {
//       print('Discovery completed');
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Bluetooth Example'),
//       ),
//       body: Center(
//         child: ListView.builder(
//           itemCount: results.length,
//           itemBuilder: (context, index) {
//             BluetoothDiscoveryResult result = results[index];
//             return ListTile(
//               title: Text(result.device.name ?? 'Unknown device'),
//               subtitle: Text(result.device.address),
//             );
//           },
//         ),
//
//         // child: ElevatedButton(
//         //   onPressed: () {
//         //     // 블루투스 장치 검색 및 연결 함수 호출
//         //     scanAndConnect();
//         //   },
//         //   child: Text('Scan & Connect'),
//         // ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: startDiscovery,
//         // 스캔 중이라면 stop 아이콘을, 정지상태라면 search 아이콘으로 표시
//         child: Icon(Icons.search),
//       ),
//     );
//   }
//
//   // void scanAndConnect() async {
//   //   // 검색 시작
//   //   bluetooth.startDiscovery().listen((r) {
//   //     // 검색된 장치 출력
//   //     print('Discovered device: ${r.device.name} (${r.device.address})');
//   //   }).onDone(() {
//   //     print('Discovery completed');
//   //   });
//   //
//   //   // 연결할 장치 선택 (예제에서는 하드코딩된 MAC 주소 사용)
//   //   String address = "00:11:22:33:44:55";
//   //   BluetoothConnection connection =
//   //       await BluetoothConnection.toAddress(address);
//   //   print('Connected to the device');
//   // }
// }
