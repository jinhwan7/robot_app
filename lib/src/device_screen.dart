// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';
// import 'package:provider/provider.dart';
// import 'package:robot_app/src/provider/bluetooth_provider.dart';
//
// class DeviceScreen extends StatefulWidget {
//   DeviceScreen({Key? key, required this.device}) : super(key: key);
//
//   // 장치 정보 전달 받기
//   final BluetoothDevice device;
//
//   @override
//   _DeviceScreenState createState() => _DeviceScreenState();
// }
//
// class _DeviceScreenState extends State<DeviceScreen> {
//   late BlueToothProvider _bleProvider;
//   // flutterBlue
//   FlutterBlue flutterBlue = FlutterBlue.instance;
//
//   // 연결 상태 표시 문자열
//   String stateText = 'Connecting';
//
//   // 연결 버튼 문자열
//   String connectButtonText = 'Disconnect';
//
//   // 현재 연결 상태 저장용
//   BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;
//
//   // 연결 상태 리스너 핸들 화면 종료시 리스너 해제를 위함
//   StreamSubscription<BluetoothDeviceState>? _stateListener;
//
//   List<BluetoothService> bluetoothService = [];
//
//   @override
//   initState() {
//     super.initState();
//     // 상태 연결 리스너 등록
//     _stateListener = widget.device.state.listen((event) {
//       debugPrint('deviceState : $deviceState');
//       debugPrint('event :  $event');
//
//       if (deviceState == event) {
//         // 상태가 동일하다면 무시
//         return;
//       }
//       // 연결 상태 정보 변경
//       setBleConnectionState(event);
//     });
//     // 연결 시작
//
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   @override
//   void setState(VoidCallback fn) {
//     if (mounted) {
//       // 화면이 mounted 되었을때만 업데이트 되게 함
//       super.setState(fn);
//     }
//   }
//
//   /* 연결 상태 갱신 */
//   setBleConnectionState(BluetoothDeviceState event) {
//     switch (event) {
//       case BluetoothDeviceState.disconnected:
//         stateText = 'Disconnected';
//         // 버튼 상태 변경
//         connectButtonText = 'Connect';
//         break;
//       case BluetoothDeviceState.disconnecting:
//         stateText = 'Disconnecting';
//         break;
//       case BluetoothDeviceState.connected:
//         stateText = 'Connected';
//         // 버튼 상태 변경
//         connectButtonText = 'Disconnect';
//         break;
//       case BluetoothDeviceState.connecting:
//         stateText = 'Connecting';
//         break;
//     }
//     //이전 상태 이벤트 저장
//     deviceState = event;
//     setState(() {});
//   }
//
//   /* 연결 시작 */
//   Future<bool> connect() async {
//     Future<bool>? returnValue;
//     setState(() {
//       /* 상태 표시를 Connecting으로 변경 */
//       stateText = 'Connecting';
//     });
//
//     /*
//       타임 아웃을 5초(5000ms)로 설정 및 autoConnect 해제
//        참고로 autoConnect 가 true 되어 있으면 연결이 지연 되는 경우가 있음.
//      */
//     await widget.device
//         .connect(autoConnect: false)
//         .timeout(Duration(milliseconds: 8000), onTimeout: () {
//       //타임 아웃 발생
//       //returnValue 를 false 로 설정
//       returnValue = Future.value(false);
//       debugPrint('timeout failed');
//
//       //연결 상태 disConnected로 변경
//       setBleConnectionState(BluetoothDeviceState.disconnected);
//     }).then((data) async {
//       bluetoothService.clear();
//       if (returnValue == null) {
//         //returnValue가 null이면 timeout이 발생한 것이 아니므로 연결 성공
//         debugPrint('connection successful');
//         print('start discover service');
//         List<BluetoothService> bleServices =
//             await widget.device.discoverServices();
//         setState(() {
//           bluetoothService = bleServices;
//         });
//         //bluetoothService 이걸 provider로 넘겨주자
//         Provider.of<BlueToothProvider>(context,listen: false).add(bleServices);
//         for (BluetoothService service in bleServices) {
//           print('============================================');
//           print('Service UUID: ${service.uuid}');
//           for (BluetoothCharacteristic c in service.characteristics) {
//             print('\tcharacteristic UUID: ${c.uuid.toString()}');
//             print('\t\twrite: ${c.properties.write}');
//             print('\t\tread: ${c.properties.read}');
//             print('\t\tnotify: ${c.properties.notify}');
//             print('\t\tisNotifying: ${c.isNotifying}');
//             print(
//                 '\t\twriteWithoutResponse: ${c.properties.writeWithoutResponse}');
//             print('\t\tindicate: ${c.properties.indicate}');
//           }
//         }
//
//         //returnValue가 null이면 timeout이 발생한 것이 아니므로 연결 성공
//         debugPrint('connection successful');
//         returnValue = Future.value(true);
//       }
//     });
//
//     return returnValue ?? Future.value(false);
//   }
//
//   /* 연결 해제 */
//   void disconnect() {
//     try {
//       setState(() {
//         stateText = 'Disconnecting';
//       });
//       widget.device.disconnect();
//     } catch (e) {
//       debugPrint('$e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     _bleProvider = Provider.of<BlueToothProvider>(context);
//
//     return Scaffold(
//       appBar: AppBar(
//         /* 장치명 */
//         title: Text(widget.device.name),
//       ),
//       body: Center(
//           child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           /* 연결 상태 */
//           Text(
//             stateText,
//             style: const TextStyle(fontSize: 25),
//           ),
//           /* 연결 및 해제 버튼 */
//           OutlinedButton(
//               onPressed: () {
//                 if (deviceState == BluetoothDeviceState.connected) {
//                   /* 연결된 상태 라면 연결 해제 */
//                   disconnect();
//                 } else if (deviceState == BluetoothDeviceState.disconnected) {
//                   /* 연결 해재된 상태 라면 연결 */
//                   connect();
//                 } else {}
//               },
//               child: Text(connectButtonText)),
//           Expanded(
//             child: ListView.separated(
//               itemCount: bluetoothService.length,
//               itemBuilder: (context, index) {
//                 return listItem(bluetoothService[index]);
//               },
//               separatorBuilder: (BuildContext context, int index) {
//                 return Divider();
//               },
//             ),
//           ),
//         ],
//       )),
//     );
//   }
//
//   /* 각 캐릭터리스틱 정보 표시 위젯 */
//   Widget characteristicInfo(BluetoothService r) {
//     String name = '';
//     String properties = '';
//     // characteristic 을 한개씩 꺼내서 표시
//     for (BluetoothCharacteristic c in r.characteristics) {
//       properties = '';
//       name += '\t\tcharacteristicId : ${c.uuid}\n';
//       if (c.properties.write) {
//         properties += 'Write ';
//       }
//       if (c.properties.read) {
//         properties += 'Read ';
//       }
//       if (c.properties.notify) {
//         properties += 'Notify ';
//       }
//       if (c.properties.writeWithoutResponse) {
//         properties += 'WriteWR ';
//       }
//       if (c.properties.indicate) {
//         properties += 'Indicate ';
//       }
//       name += '\t\t\tProperties: $properties\n\n';
//     }
//     return Text(name);
//   }
//
//   /* Service UUID 위젯  */
//   Widget serviceUUID(BluetoothService r) {
//     String name = '';
//     name = r.uuid.toString();
//     return Text('ServiceId : $name');
//   }
//
//   /* Service 정보 아이템 위젯 */
//   Widget listItem(BluetoothService r) {
//     return ListTile(
//       onTap: () {
//         print('clicked');
//       },
//       title: serviceUUID(r),
//       subtitle: characteristicInfo(r),
//     );
//   }
// }
