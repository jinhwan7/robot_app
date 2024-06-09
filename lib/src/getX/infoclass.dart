import 'package:get/get.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

class INFOCLASS extends GetxController {
  RxBool hasPermissions = false.obs;
  RxDouble heading = 0.0.obs;
  RxDouble latitude = 0.0.obs; //위도
  RxDouble longitude = 0.0.obs; //경도

  sethasperrmission(var result) {
    hasPermissions(result);
  }

  setheading() {
    FlutterCompass.events!.listen((event) {
      heading(event.heading);
      setlalo();
    });
  }

  setlalo() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    longitude(position.longitude);
    latitude(position.latitude);
  }
}