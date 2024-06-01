import 'dart:math';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class Stt extends StatelessWidget {
  const Stt({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: SttPage(),
    );
  }
}

class SttPage extends StatefulWidget {
  const SttPage({super.key});

  @override
  _SttPageState createState() => _SttPageState();
}

class _SttPageState extends State<SttPage> {
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

  @override
  void initState() {
    super.initState();

    initSpeechState();
  }

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(children: [
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.only(top: 100.0),
              child: Column(
                children: <Widget>[
                  const Center(
                    child: Text(
                      '음성 인식 결과',
                      style: TextStyle(fontSize: 22.0),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          color: Theme.of(context).primaryColor,
                          child: Center(
                            child: Text(
                              lastWords,
                              style: const TextStyle(color: Colors.white, fontSize: 30),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.yellow,
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Column(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    IconButton(
                      onPressed: !_hasSpeech || speech.isListening
                          ? null
                          : startListening,
                      icon: Icon(Icons.mic),
                    ),
                    Container(
                        margin: const EdgeInsets.only(top: 0.0),
                        child: const Text("click",
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.blue)))
                  ],
                ),
              ],
            ),
          ),
        ]),
      ),
    );
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

  void resultListener(SpeechRecognitionResult result) {
    print('잘 나오나');
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

  void _logEvent(String eventDescription) {
    if (_logEvents) {
      var eventTime = DateTime.now().toIso8601String();
      print('LOG EVENT: $eventTime $eventDescription');
    }
  }
}
