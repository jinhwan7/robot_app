import 'dart:async';
import 'dart:ffi';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  //stt,tts관련
  bool _hasSpeech = false;
  final bool _logEvents = true;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = '';
  String lastError = '';
  String lastStatus = '';
  String _currentLocaleId = '';
  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();

  static const platform = MethodChannel('com.robotapp.robot_app/tmap');
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  late bool serviceEnabled;
  late LocationPermission permission;

  @override
  void initState() {
    super.initState();
    isLocationServiceEnabled();
    _startLocationStream();
    initSpeechState();
    // _initializeTMap(); // 여기서 초기화를 호출합니다.
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
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) async {
      _currentPosition = position;
      double longitude = position.longitude;
      double latitude = position.latitude;
      final String result = await platform.invokeMethod('markCurrentPosition',
          {'longitude': longitude, 'latitude': latitude});
    });
  }

  void stopLocationStream() {
    _positionStreamSubscription?.cancel();
  }

  // Future<void> _initializeTMap() async {
  //   try {
  //     final String result = await platform.invokeMethod('initializeTMap',
  //         {'apiKey': 'G47hiGFOOG1mZzstLLeHP342E38U3AT92zGGgq6Q'});
  //     print(result);
  //   } on PlatformException catch (e) {
  //     print("Failed to initialize TMap: '${e.message}'.");
  //   }
  // }

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

  void resultListener(SpeechRecognitionResult result) {
    _logEvent(
        'Result listener final: ${result.finalResult}, words: ${result.recognizedWords}');

    setState(() {
      lastWords = result.recognizedWords;
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
      listenFor: Duration(seconds: 30),
      pauseFor: Duration(seconds: 5),
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

  void _findPedestrianRoute() {}

  @override
  Widget build(BuildContext context) {
    const Map<String, dynamic> creationParams = <String, dynamic>{};

    return Scaffold(
      appBar: AppBar(
        title: Text('MapView'),
      ),
      body: Column(
        children: [
          Container(
              height: 100,
              color: Colors.white54,
              child: Column(children: [
                Text(lastWords == '' ? '화면의 하단을 누른 후 도착지를 말씀해 주세요' : lastWords,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.purple)),
                SizedBox(
                  width: 280,
                  child: TextField(
                    obscureText: true,
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
                      ..addOnPlatformViewCreatedListener(
                          params.onPlatformViewCreated)
                      ..create();
                return controller;
              },
            ),

            // ElevatedButton(
            //   onPressed: _findPedestrianRoute,
            //   child: Text('Find Pedestrian Route'),
            // ),
          ),
          Expanded(
            child: Container(
              child: Center(
                child: IconButton(
                  onPressed:
                      !_hasSpeech || speech.isListening ? null : startListening,
                  icon: const Icon(Icons.mic),
                  iconSize: 60,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
