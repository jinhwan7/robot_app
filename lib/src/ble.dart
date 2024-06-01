// import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';
// import 'package:robot_app/src/device_screen.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// Future<void> requestPermissions() async {
//   await Permission.bluetoothScan.request();
//   await Permission.bluetoothConnect.request();
// }
//
//
// class BleScan extends StatefulWidget {
//   const BleScan({super.key});
//
//   @override
//   State<BleScan> createState() => _BleScanState();
// }
//
// class _BleScanState extends State<BleScan> {
//   FlutterBlue flutterBlue = FlutterBlue.instance;
//   List<ScanResult> scanResultList = [];
//   bool _isScanning = false;
//
//   @override
//   void initState() {
//     super.initState();
//     initBle();
//   }
//
//   void initBle() {
//     print('flutterBlue Init');
//     // BLE 스캔 상태 얻기 위한 리스너
//     flutterBlue.isScanning.listen((isScanning) {
//       _isScanning = isScanning;
//       setState(() {});
//     });
//   }
//
//   /*
//   스캔 시작/정지 함수
//   */
//   scan() async {
//     requestPermissions();
//
//     if (!_isScanning) {
//       // 스캔 중이 아니라면
//       // 기존에 스캔된 리스트 삭제
//       scanResultList.clear();
//       // 스캔 시작, 제한 시간 4초
//       flutterBlue.startScan(
//           timeout: const Duration(seconds: 5), scanMode: ScanMode.lowLatency);
//       // 스캔 결과 리스너
//       flutterBlue.scanResults.listen((results) {
//         // List<ScanResult> 형태의 results 값을 scanResultList에 복사
//
//         scanResultList = results;
//         // UI 갱신
//         setState(() {});
//       });
//     } else {
//       // 스캔 중이라면 스캔 정지
//       flutterBlue.stopScan();
//     }
//   }
//
//   /*
//    여기서 부터는 장치별 출력용 함수들
//   */
//   /*  장치의 신호값 위젯  */
//   Widget deviceSignal(ScanResult r) {
//     return Text(r.rssi.toString());
//   }
//
//   /* 장치의 MAC 주소 위젯  */
//   Widget deviceMacAddress(ScanResult r) {
//     return Text(r.device.id.id);
//   }
//
//   /* 장치의 명 위젯  */
//   Widget deviceName(ScanResult r) {
//     String name = '';
//
//     if (r.device.name.isNotEmpty) {
//       // device.name 에 값이 있다면
//       name = r.device.name;
//     } else if (r.advertisementData.localName.isNotEmpty) {
//       // advertisementData.localName에 값이 있다면
//       name = r.advertisementData.localName;
//     } else {
//       print(r.device);
//       // 둘다 없다면 이름 알 수 없음...
//       name = 'N/A';
//     }
//     print('name:$name');
//     return Text(name);
//   }
//
//   /* BLE 아이콘 위젯 */
//   Widget leading(ScanResult r) {
//     return CircleAvatar(
//       child: Icon(
//         Icons.bluetooth,
//         color: Colors.white,
//       ),
//       backgroundColor: Colors.cyan,
//     );
//   }
//
//   /* 장치 아이템을 탭 했을때 호출 되는 함수 */
//   void onTap(ScanResult r) {
//     // 단순히 이름만 출력
//     print('${r.device.id}');
//     print('${r.device.state}');
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => DeviceScreen(device: r.device)),
//     );
//   }
//
//   /* 장치 아이템 위젯 */
//   Widget listItem(ScanResult r) {
//     return ListTile(
//       onTap: () => onTap(r),
//       leading: leading(r),
//       title: deviceName(r),
//       subtitle: deviceMacAddress(r),
//       trailing: deviceSignal(r),
//     );
//   }
//
//   /* UI */
//   @override
//   Widget build(BuildContext context) {
//     // var a = Provider.of<BlueToothProvider>(context);
//     // print('bleScan까지 빌드됨 $a');
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('BlueTooth scan'),
//       ),
//       body: Center(
//         /* 장치 리스트 출력 */
//         child: ListView.separated(
//           itemCount: scanResultList.length,
//           itemBuilder: (context, index) {
//             return listItem(scanResultList[index]);
//           },
//           separatorBuilder: (BuildContext context, int index) {
//             return Divider();
//           },
//         ),
//       ),
//       /* 장치 검색 or 검색 중지  */
//       floatingActionButton: FloatingActionButton(
//         onPressed: scan,
//         // 스캔 중이라면 stop 아이콘을, 정지상태라면 search 아이콘으로 표시
//         child: Icon(_isScanning ? Icons.stop : Icons.search),
//       ),
//     );
//   }
// }
