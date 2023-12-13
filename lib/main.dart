import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterSoundRecorder? _mRecorderToFile = FlutterSoundRecorder();
  FlutterSoundRecorder? _mRecorderToFile2 = FlutterSoundRecorder();
  File? recordedfile;
  final String _mPath = 'Recording${DateTime.now().millisecondsSinceEpoch}.aac';
  final String _mPath2 =
      'Recording${DateTime.now().millisecondsSinceEpoch}2.aac';
  bool isRecording = false;
  final FlutterTts textToSpeech = FlutterTts();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  Future<void> startRecorder() async {
    try {
      await textToSpeech
          .setIosAudioCategory(IosTextToSpeechAudioCategory.playAndRecord, [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers
      ]);
      var session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.allowBluetoothA2dp,
        avAudioSessionMode: AVAudioSessionMode.spokenAudio,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.voiceCommunication,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ));
      recordedfile = File(_mPath);
      if (_mRecorderToFile == null) {
        _mRecorderToFile = FlutterSoundRecorder();
      } else {
        _mRecorderToFile = null;
        _mRecorderToFile = FlutterSoundRecorder();
      }
      await _mRecorderToFile!.openRecorder();
      await _mRecorderToFile!.startRecorder(
        codec: Codec.aacMP4,
        toFile: _mPath,
      );
      if (_mRecorderToFile2 == null) {
        _mRecorderToFile2 = FlutterSoundRecorder();
      } else {
        _mRecorderToFile2 = null;
        _mRecorderToFile2 = FlutterSoundRecorder();
      }
      await _mRecorderToFile2!.openRecorder();
      await _mRecorderToFile2!.startRecorder(
        codec: Codec.aacMP4,
        toFile: _mPath2,
      );
      setState(() {
        isRecording = true;
      });
    } catch (e) {
      print(" ------- oooofff ${e.toString()}");
    }
  }

  Future<void> stopRecording() async {
    try {
      await _mRecorderToFile?.stopRecorder().then((value) async {
        setState(() {
          recordedfile = File(value!);
          print("recordedfile $recordedfile");
        });
        await _mRecorderToFile?.closeRecorder();
      });
      await _mRecorderToFile2?.stopRecorder().then((value) async {
        setState(() {
          recordedfile = File(value!);
          print("recordedfile $recordedfile");
          isRecording = false;
        });
        await _mRecorderToFile2?.closeRecorder();
      });
    } catch (e) {
      print("error in stopRecordingGoogle : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (_, orientation) {
     if (orientation == Orientation.landscape ) print("land here");
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'recorded file: ${recordedfile?.path}',
              ),
              Row(
                children: [
                  Text(
                    'recorder status => ',
                  ),
                  InkWell(
                    onTap: () => startRecorder(),
                    child: Text(
                      'Change',
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
