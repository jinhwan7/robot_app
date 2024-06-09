import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:robot_app/src/getX/infoclass.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final infoClass = Get.find<INFOCLASS>();
  final FlutterTts tts = FlutterTts();

  //stt,tts관련
  bool _hasSpeech = false;
  final bool _logEvents = true;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = '';
  String lastError = '';
  String lastStatus = '';
  bool sttFinal = false;
  String _currentLocaleId = '';
  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();

  final TextEditingController _controller = TextEditingController();

  //지도관련 멤버변수
  static const platform = MethodChannel('com.robotapp.robot_app/tmap');
  Map<String, String> tmapReqHeaders = {
    'appKey': 'G47hiGFOOG1mZzstLLeHP342E38U3AT92zGGgq6Q'
  };
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  late bool serviceEnabled;
  late LocationPermission permission;

  Map<String, dynamic> destinationInfo = {};
  List<dynamic> pointFeatures = [];
  int distance = 0;
  double direction = 0.0;
  List<double> pointCoordi = [0.0, 0.0];
  String errorString = '';

  @override
  void initState() {
    super.initState();
    _fetchPermissionStatus();
    tts.setLanguage('ko-KR');
    tts.setSpeechRate(0.5);
    infoClass.setheading();
    isLocationServiceEnabled();
    _startLocationStream();
    initSpeechState();
  }

  @override
  void dispose() {
    // 위젯이 dispose될 때 스트림 구독 취소
    super.dispose();
    stopLocationStream();
  }

  //////////////////geolocator
  void isLocationServiceEnabled() async {
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      print('Location services are disabled.');

      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  void _startLocationStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) async {
      _currentPosition = position;
      double longitude = position.longitude;
      double latitude = position.latitude;
      final String result = await platform.invokeMethod('markCurrentPosition',
          {'longitude': longitude, 'latitude': latitude});
      setState(() {});
    });
  }

  void stopLocationStream() {
    _positionStreamSubscription?.cancel();
  }

  // 도착지 이름으로 좌표찾기ß
  Future<Map<String, dynamic>> _findCoordinateByPoi(String lastWords) async {
    try {
      var url = Uri.https('apis.openapi.sk.com', '/tmap/pois', {
        'searchKeyword': lastWords,
        'searchtypeCd': 'R',
        'centerLat': '${_currentPosition?.latitude}',
        'centerLon': '${_currentPosition?.longitude}',
        // 'centerLat': '37.4722393',
        // 'centerLon': '126.9371915',
        'radius': '5',
        'version': '1',
        'format': 'json'
      });

      var response = await http.get(url, headers: tmapReqHeaders);

      // print('respons status ${response.statusCode}');
      if (response.statusCode == 204) throw '결과 없음';

      var parsedRes = json.decode(utf8.decode(response.bodyBytes));

      var searchedPoi = parsedRes['searchPoiInfo']['pois']['poi'][0];
      var searchedPoiName = searchedPoi['name'];
      tts.speak('$searchedPoiName 으로 경로 탐색');
      Map<String, dynamic> searchedCoordi = {
        'lat': searchedPoi['frontLat'],
        'lon': searchedPoi['frontLon'],
      };

      return searchedCoordi;
    } catch (e) {
      if (e == '결과 없음') {
        tts.speak('결과 없음');
      }

      return Future.error(e);
    }
  }

  double _calculateBearing(var startPoint, var endPoint) {
    final double startLatRad = _degreeToRadian(startPoint.latitude);
    final double startLngRad = _degreeToRadian(startPoint.longitude);
    final double endLatRad = _degreeToRadian(endPoint[1]);
    final double endLngRad = _degreeToRadian(endPoint[0]);

    final double dLng = endLngRad - startLngRad;
    final double y = sin(dLng) * cos(endLatRad);
    final double x = cos(startLatRad) * sin(endLatRad) -
        sin(startLatRad) * cos(endLatRad) * cos(dLng);

    final double bearingRad = atan2(y, x);
    final double bearingDeg = _radianToDegree(bearingRad);
    return (bearingDeg + 360) % 360;
  }

  double _degreeToRadian(double degree) {
    return degree * pi / 180;
  }

  double _radianToDegree(double radian) {
    return radian * 180 / pi;
  }

  Future<void> _findPedestrianRoute(Map<String, dynamic> searchedCoordi) async {
    var url = Uri.https('apis.openapi.sk.com', '/tmap/routes/pedestrian',
        {'version': '1', 'format': 'json', 'callback': 'result'});
    var response = await http.post(url,
        body: {
          'startX': _currentPosition?.longitude.toString(),
          'startY': _currentPosition?.latitude.toString(),
          'endX': searchedCoordi['lon'].toString(),
          'endY': searchedCoordi['lat'].toString(),
          // "startX": "126.9371915",
          // "startY": "37.4722393",
          // "endX": "126.9356517",
          // "endY": "37.4722775",
          "reqCoordType": "WGS84GEO",
          "resCoordType": "WGS84GEO",
          "startName": "출발지",
          "endName": "도착지"
        },
        headers: tmapReqHeaders);

    Map<String, dynamic> parsedRes =
        json.decode(utf8.decode(response.bodyBytes));

    print('Response status: ${response.statusCode}');
    destinationInfo = parsedRes;

    //경로 그려주기 //도착지 마크찍기, 선그려주기

    pointFeatures = destinationInfo['features'].where((feature) {
      return feature['geometry']['type'] == 'Point';
    }).toList();

    await platform.invokeMethod('drawDestinationPath', {
      'longitude': pointFeatures.last['geometry']['coordinates'][0],
      'latitude': pointFeatures.last['geometry']['coordinates'][1]
    });

    startGuidance(pointFeatures);
  }

  Future<dynamic> carcDistance(var point) async {
    try {
      var url = Uri.https('apis.openapi.sk.com', '/tmap/routes/distance', {
        "startX": "${_currentPosition?.longitude}",
        "startY": "${_currentPosition?.latitude}",
        "endX": "${point['geometry']['coordinates'][0]}",
        "endY": "${point['geometry']['coordinates'][1]}",
        'version': '1',
        'format': 'json',
        'callback': 'result'
      });
      var response = await http.get(url, headers: tmapReqHeaders);

      Map<String, dynamic> parsedRes =
          json.decode(utf8.decode(response.bodyBytes));
      return parsedRes['distanceInfo']['distance'];
    } catch (e) {
      return Future.error(e);
    }
  }

  void startGuidance(List<dynamic> points) {
    int index = 0;
    Timer.periodic(Duration(seconds: 2), (timer) {
      if (index >= points.length) {
        timer.cancel();
        return;
      }

      var routePoint = points[index];

      pointCoordi[0] = routePoint['geometry']['coordinates'][0];
      pointCoordi[1] = routePoint['geometry']['coordinates'][1];
      double angleToPoint = 0.0;
      angleToPoint = _calculateBearing(_currentPosition, pointCoordi);
      direction = angleToPoint;
      setState(() {});
      // 비동기로 각 함수 호출
      carcDistance(routePoint).then((result) {
        distance = result;

        // tts.speak(distance.toString());

        var angle = infoClass.heading.value;
        int angleInt = angle > 0 ? angle.toInt() : (360 + angle).toInt();
        if (angleInt > angleToPoint + 20) {
          tts.speak(' 약간 좌회전');
        }

        if (angleInt < angleToPoint - 20) {
          tts.speak(' 약간 우회전');
        }
        ;

        // 거리 값이 1이 되면 다음 포인트로 이동
        if (distance <= 1) {
          tts.speak('${index + 1} 지점 도착');
          index++;
        }
        if (index == points.length - 1 && distance <= 1) {
          tts.speak('목적지에 도착');
          index++;
        }
        setState(() {});
      }).catchError((err) {
        errorString = '$err';
        setState(() {});
      });
    });
  }

  /////////////////////Sst
  Future<void> initSpeechState() async {
    _logEvent('Initialize');
    var hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        debugLogging: true,
        finalTimeout: Duration(milliseconds: 0));

    if (hasSpeech) {
      _localeNames = await speech.locales();

      var systemLocale = await speech.systemLocale();
      _currentLocaleId = 'ko_KR';
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  void resultListener(SpeechRecognitionResult result) async {
    _logEvent(
        'Result listener final: ${result.finalResult}, words: ${result.recognizedWords}');
    lastWords = result.recognizedWords;
    sttFinal = result.finalResult;
    _controller.text = lastWords;

    if (result.finalResult) {
      var searchedCoordi = await _findCoordinateByPoi(lastWords);
      await _findPedestrianRoute(searchedCoordi);
    }

    setState(() {
      // lastWords = result.recognizedWords;
    });
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // _logEvent('sound level $level: $minSoundLevel - $maxSoundLevel ');
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    _logEvent(
        'Received error status: $error, listening: ${speech.isListening}');
    setState(() {
      lastError = '${error.errorMsg} - ${error.permanent}';
    });
  }

  void statusListener(String status) {
    _logEvent(
        'Received listener status: $status, listening: ${speech.isListening}');
    setState(() {
      lastStatus = status;
    });
  }

  void startListening() {
    _logEvent('start listening');
    lastWords = '';
    lastError = '';
    final options = SpeechListenOptions(
        listenMode: ListenMode.confirmation,
        cancelOnError: true,
        partialResults: true,
        autoPunctuation: true,
        enableHapticFeedback: true);
    speech.listen(
      onResult: resultListener,
      listenFor: Duration(seconds: 7),
      pauseFor: Duration(seconds: 3),
      localeId: _currentLocaleId,
      onSoundLevelChange: soundLevelListener,
      listenOptions: options,
    );
  }

  void _logEvent(String eventDescription) {
    if (_logEvents) {
      var eventTime = DateTime.now().toIso8601String();
      print('LOG EVENT: $eventTime $eventDescription');
    }
  }

  void _onPlatformViewCreated(int id) {
    // PlatformView가 생성된 후 호출되는 콜백
    setState(() {});

    // 특정 로직 실행
    tts.speak('화면의 하단을 누른 후 도착지를 말씀해 주세요');
  }

  String getNewAngle(double angle) {
    return angle > 0
        ? angle.toInt().toString()
        : (360 + angle).toInt().toString();
  }

  void _fetchPermissionStatus() {
    //권한 확인
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() =>
            infoClass.sethasperrmission(status == PermissionStatus.granted));
        Permission.locationWhenInUse.request().then((status) {
          infoClass.sethasperrmission(status == PermissionStatus.granted);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const Map<String, dynamic> creationParams = <String, dynamic>{};

    return Scaffold(
      appBar: AppBar(
        title: Text('MapView'),
      ),
      body: Column(
        children: [
          Text(sttFinal ? 'true' : 'false'),
          Container(
              height: 100,
              color: Colors.white54,
              child: Column(children: [
                SizedBox(
                  width: 280,
                  child: TextField(
                    controller: _controller,
                    obscureText: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '도착지',
                    ),
                  ),
                )
              ])),
          Container(
            height: 400,
            child: PlatformViewLink(
              viewType: 'tmap-view',
              surfaceFactory: (context, controller) {
                return AndroidViewSurface(
                  controller: controller as AndroidViewController,
                  gestureRecognizers: const <Factory<
                      OneSequenceGestureRecognizer>>{},
                  hitTestBehavior: PlatformViewHitTestBehavior.opaque,
                );
              },
              onCreatePlatformView: (PlatformViewCreationParams params) {
                final AndroidViewController controller =
                    PlatformViewsService.initExpensiveAndroidView(
                        id: params.id,
                        viewType: 'tmap-view',
                        layoutDirection: TextDirection.ltr,
                        creationParams: creationParams,
                        creationParamsCodec: const StandardMessageCodec(),
                        onFocus: () {
                          params.onFocusChanged(true);
                        })
                      ..addOnPlatformViewCreatedListener((int id) {
                        params.onPlatformViewCreated(id);
                        _onPlatformViewCreated(id);
                      })
                      ..create();
                return controller;
              },
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: !_hasSpeech || speech.isListening ? null : startListening,
              child: Container(
                child: Center(
                  child: Icon(
                    Icons.mic,
                    size: 60,
                  ),
                ),
              ),
            ),
          ),
          Container(
            child: Column(
              children: [
                Obx(() => Text(getNewAngle(infoClass.heading.value))),
                Text('angleToPoint ${direction}'),
                Text(errorString != ''
                    ? errorString
                    : 'point까지 남은 거리: ${distance}'),
                Text('point의 좌표: ${pointCoordi[0]},${pointCoordi[1]}'),
                Text(_currentPosition != null
                    ? '현재위치 ${_currentPosition?.latitude}, ${_currentPosition?.longitude}'
                    : 'null')
              ],
            ),
          )
        ],
      ),
    );
  }
}
