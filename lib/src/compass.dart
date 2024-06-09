// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_compass/flutter_compass.dart';
// import 'package:get/get.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class INFOCLASS extends GetxController {
//   RxBool hasPermissions = false.obs;
//   RxDouble heading = 0.0.obs;
//   RxDouble latitude = 0.0.obs; //위도
//   RxDouble longitude = 0.0.obs; //경도
//
//   sethasperrmission(var result) {
//     hasPermissions(result);
//   }
//
//   setheading() {
//     FlutterCompass.events!.listen((event) {
//       heading(event.heading);
//       setlalo();
//     });
//   }
//
//   setlalo() async {
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     longitude(position.longitude);
//     latitude(position.latitude);
//   }
// }
//
// Map newsdic = {
//   0: 'North', //0, //북
//   1: 'North East', //45, //북동
//   2: 'East', //90, //동
//   3: 'South East', //135, //남동
//   4: 'South', //180, //남
//   5: 'South West', //225, //남서
//   6: 'West', //270, //서
//   7: 'North West', //315, //북서
//   8: 'North', //360, //북
// };
//
// class CompassWidget extends StatefulWidget {
//   const CompassWidget({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   CompassWidgetState createState() => CompassWidgetState();
// }
//
// class CompassWidgetState extends State<CompassWidget> {
//   late final INFOCLASS getinfo;
//
//   @override
//   void initState() {
//     getinfo = Get.put(INFOCLASS());
//     _fetchPermissionStatus();
//     getinfo.setheading();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() => (!getinfo.hasPermissions.value
//         ? MaterialApp(
//             debugShowCheckedModeBanner: false,
//             home: Scaffold(
//               backgroundColor: Colors.black,
//               appBar: AppBar(
//                 title: const Text('Setting'),
//                 backgroundColor: Colors.grey[800],
//                 centerTitle: true,
//               ),
//               body: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Text("\nCheck LOCATION Permission.",
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold)),
//                 ],
//               ),
//             ),
//           )
//         : MaterialApp(
//             debugShowCheckedModeBanner: false,
//             home: Scaffold(
//               backgroundColor: Colors.black,
//               appBar: AppBar(
//                 title: const Text('Compass'),
//                 backgroundColor: Colors.grey[800],
//                 centerTitle: true,
//               ),
//               body: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(
//                           "위도(la) : " +
//                               getinfo.latitude.toString() +
//                               "\n"
//                                   "경도(lo) : " +
//                               getinfo.longitude.toString(),
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold)),
//                     ],
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(
//                           getNews(getinfo.heading.value > 0
//                               ? getinfo.heading.value
//                               : getinfo.heading.value + 360),
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 26,
//                               fontWeight: FontWeight.bold)),
//                     ],
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(
//                           (getinfo.heading.value > 0
//                                       ? getinfo.heading.value
//                                       : getinfo.heading.value + 360)
//                                   .toInt()
//                                   .toString() +
//                               "°",
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 26,
//                               fontWeight: FontWeight.bold)),
//                     ],
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(18.0),
//                     child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         Image.asset('assets/images/compass.png'),
//                         Transform.rotate(
//                           angle: ((getinfo.heading.value) * (pi / 180) * -1),
//                           child: Image.asset('assets/images/cadrant.png'),
//                         ),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           )));
//   }
//
//   String getNews(double news) {
//     List<double> list = List<double>.filled(9, 360);
//     List<double> templist = List<double>.filled(9, 360);
//     list[0] = (0 - news).abs(); //n
//     list[1] = (45 - news).abs();
//     list[2] = (90 - news).abs(); //e
//     list[3] = (135 - news).abs();
//     list[4] = (180 - news).abs();
//     list[5] = (225 - news).abs(); //w
//     list[6] = (270 - news).abs();
//     list[7] = (315 - news).abs(); //s
//     list[8] = (360 - news).abs(); //n
//
//     templist.setAll(0, list);
//     templist.sort();
//
//     return newsdic[list.indexOf(templist[0])];
//   }
//
//   void _fetchPermissionStatus() {
//     //권한 확인
//     Permission.locationWhenInUse.status.then((status) {
//       if (mounted) {
//         setState(() =>
//             getinfo.sethasperrmission(status == PermissionStatus.granted));
//         Permission.locationWhenInUse.request().then((status) {
//           getinfo.sethasperrmission(status == PermissionStatus.granted);
//         });
//       }
//     });
//   }
// }
