import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:translator/translator.dart';
import 'package:speech_to_text/speech_to_text.dart';

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            primary: Colors.deepPurple,
            secondary: Colors.deepPurpleAccent),
        scaffoldBackgroundColor: Colors.grey[900],
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> incomingText = [
    'Hello, how are you?',
    'I am fine, thank you.',
    'What are you doing?',
    'I am learning to use Text to Speech.',
    'That is great.'
  ];
  int incomingTextIndex = 0;
  List<String> outgoingText = [];
  int outgoingTextIndex = 0;
  int volume = 100;
  int pitch = 75;
  int rate = 50;
  bool isPlaying = false;
  TextEditingController textController = TextEditingController();
  FlutterTts flutterTts = FlutterTts();
  List<String> fromLanguages = <String>[
    'en-US',
    'es-ES',
    'fr-FR',
    'de-DE',
    'it-IT',
    'ja-JP',
    'ko-KR',
    'zh-CN',
    'ru-RU',
    'pt-PT',
    'ar-SA',
    'hi-IN',
    'tr-TR',
    'vi-VN',
    'th-TH',
    'nl-NL',
    'pl-PL',
    'sv-SE',
    'cs-CZ',
    'da-DK',
    'fi-FI',
    'el-GR',
    'hu-HU',
    'no-NO',
    'sk-SK',
    'uk-UA',
    'id-ID',
    'ms-MY',
    'fil-PH',
    'he-IL',
    'ro-RO',
    'sl-SI',
    'hr-HR',
    'ca-ES',
    'eu-ES',
    'gl-ES',
    'is-IS',
    'mk-MK',
    'mt-MT',
    'lv-LV',
    'et-EE',
  ];
  List<String> toLanguages = <String>[
    'en-US',
    'es-ES',
    'fr-FR',
    'de-DE',
    'it-IT',
    'ja-JP',
    'ko-KR',
    'zh-CN',
    'ru-RU',
    'pt-PT',
    'ar-SA',
    'hi-IN',
    'tr-TR',
    'vi-VN',
    'th-TH',
    'nl-NL',
    'pl-PL',
    'sv-SE',
    'cs-CZ',
    'da-DK',
    'fi-FI',
    'el-GR',
    'hu-HU',
    'no-NO',
    'sk-SK',
    'uk-UA',
    'id-ID',
    'ms-MY',
    'fil-PH',
    'he-IL',
    'ro-RO',
    'sl-SI',
    'hr-HR',
    'ca-ES',
    'eu-ES',
    'gl-ES',
    'is-IS',
    'mk-MK',
    'mt-MT',
    'lv-LV',
    'et-EE',
  ];
  String fromCode = 'en-US';
  String toCode = 'es-ES';
  final ScrollController _controller = ScrollController();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _speechEnabled = false;
    //play();
    _initSpeech();
    flutterTts.setLanguage(toCode);
    flutterTts.setVolume(volume / 100);
    flutterTts.setPitch(pitch / 100);
    flutterTts.setSpeechRate(rate / 100);
    translateTexts(incomingText, toCode);
  }

  void _initSpeech() async {
    bool hasSpeech = await _speechToText.initialize(
      onStatus: (status) {
        print('Status: $status');
      },
      onError: (error) {
        print('Error: $error');
      },
    );
    if (hasSpeech) {
      print('Speech is available');
    } else {
      print('Speech is not available');
    }
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _speechEnabled = false;
      incomingText.add(_lastWords);
      translateText(_lastWords, toCode);
    });
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _speechEnabled = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void translateTexts(List<String> text, String to) async {
    final translator = GoogleTranslator();
    for (int i = 0; i < text.length; i++) {
      final translation =
          await translator.translate(text[i], to: to.split('-')[0]);
      setState(() {
        outgoingText.add(translation.text);
      });
    }
  }

  void translateText(String text, String to) async {
    final translator = GoogleTranslator();
    final translation = await translator.translate(text, to: to.split('-')[0]);
    setState(() {
      outgoingText.add(translation.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBodyBehindAppBar: false,
        extendBody: false,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                onPressed: () async {
                  setState(() {
                    _speechEnabled = !_speechEnabled;
                  });
                  print('Speech: $_speechEnabled');
                  if (_speechEnabled) {
                    _startListening();
                  } else {
                    _stopListening();
                  }
                },
                child: (_speechEnabled)
                    ? const Icon(Icons.mic)
                    : const Icon(Icons.mic_off),
              ),
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    isPlaying = !isPlaying;
                  });
                },
                child: (isPlaying)
                    ? const Icon(Icons.stop)
                    : const Icon(Icons.play_arrow),
              ),
            ],
          ),
        ),
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 2 - 52,
                  child: ListView.builder(
                    controller: _controller,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: InkWell(
                          onTap: () {
                            setState(() {
                              outgoingTextIndex = index;
                              incomingTextIndex = index;
                            });
                          },
                          onLongPress: () {
                            setState(() {
                              incomingText.removeAt(index);
                              outgoingText.removeAt(index);
                              if (index >= outgoingTextIndex) {
                                outgoingTextIndex = 0;
                              }
                            });
                          },
                          child: SizedBox(
                            height: 48,
                            child: Center(
                              child: Text(
                                incomingText[index],
                                style: TextStyle(
                                    color: (index == incomingTextIndex - 1)
                                        ? Colors.yellow
                                        : Colors.white),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: incomingText.length,
                    shrinkWrap: true,
                  ),
                ),
                const Divider(
                  height: 10,
                  indent: 20,
                  endIndent: 20,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 2 - 52,
                  child: ListView.builder(
                    controller: _controller,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: InkWell(
                          onTap: () {
                            setState(() {
                              outgoingTextIndex = index;
                              incomingTextIndex = index;
                            });
                          },
                          onLongPress: () {
                            setState(() {
                              incomingText.removeAt(index);
                              outgoingText.removeAt(index);
                              if (index >= outgoingTextIndex) {
                                outgoingTextIndex = 0;
                              }
                            });
                          },
                          child: SizedBox(
                            height: 48,
                            child: Center(
                              child: Text(
                                outgoingText[index],
                                style: TextStyle(
                                    color: (index == outgoingTextIndex - 1)
                                        ? Colors.yellow
                                        : Colors.white),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: outgoingText.length,
                    shrinkWrap: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          title: const Text('Real Time Voice Translator'),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Settings'),
                        content: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: textController,
                                        decoration: InputDecoration(
                                          labelText: 'Enter Text',
                                          labelStyle: TextStyle(
                                              color: Colors.grey[800]),
                                          fillColor: Colors.white,
                                          focusColor: Colors.white,
                                          hoverColor: Colors.white,
                                          focusedBorder:
                                              const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15.0)),
                                          ),
                                          filled: true,
                                          border: const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            incomingText
                                                .add(textController.text);
                                          });
                                          translateText(
                                              textController.text, toCode);
                                          textController.clear();
                                        },
                                        child: const Text('Add')),
                                  ],
                                ),
                              ),
                              const Text(
                                'Speed',
                                style: TextStyle(color: Colors.white),
                              ),
                              Slider(
                                value: rate.toDouble(),
                                min: 0,
                                max: 100,
                                divisions: 100,
                                label: rate.round().toString(),
                                onChanged: (double value) {
                                  setState(() {
                                    rate = value.round();
                                  });
                                  flutterTts.setSpeechRate(rate / 100);
                                },
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text(
                                    'From',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  DropdownButton<String>(
                                    dropdownColor: Colors.grey[800],
                                    menuMaxHeight: 300,
                                    value: fromCode,
                                    items: fromLanguages
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value,
                                            style: const TextStyle(
                                                color: Colors.white)),
                                      );
                                    }).toList(),
                                    onChanged: (String? value) {
                                      setState(() {
                                        fromCode = value!;
                                      });
                                    },
                                  ),
                                  const Text(
                                    'To',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  DropdownButton<String>(
                                    dropdownColor: Colors.grey[800],
                                    menuMaxHeight: 300,
                                    value: toCode,
                                    items: fromLanguages
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value,
                                            style: const TextStyle(
                                                color: Colors.white)),
                                      );
                                    }).toList(),
                                    onChanged: (String? value) {
                                      setState(() {
                                        toCode = value!;
                                        outgoingText.clear();
                                        translateTexts(incomingText, toCode);
                                      });

                                      flutterTts.setLanguage(toCode);
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
      ),
    );
  }

  void play() {
    const oneSecond = Duration(seconds: 1);
    const hundredMilliseconds = Duration(milliseconds: 100);
    while (isPlaying) {
      if (incomingTextIndex == incomingText.length) {
        setState(() {
          incomingTextIndex = 0;
          outgoingTextIndex = 0;
        });
      }
      flutterTts.speak(outgoingText[outgoingTextIndex]);
      Timer.periodic(hundredMilliseconds, (Timer t) {});

      setState(() {
        incomingTextIndex++;
        outgoingTextIndex++;
      });
    }
    Timer.periodic(oneSecond, (Timer t) {play();});
  }
}
/**
 * Container(
    height: retracted ? 60 : 300,
    decoration: BoxDecoration(
    color: Colors.grey[800],
    borderRadius: const BorderRadius.only(
    topLeft: Radius.circular(20),
    topRight: Radius.circular(20),
    ),
    ),
    child: Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    IconButton(
    onPressed: () {
    setState(() {
    retracted = !retracted;
    });
    },
    icon: (retracted)
    ? const Icon(
    Icons.arrow_drop_up,
    color: Colors.white,
    )
    : const Icon(
    Icons.arrow_drop_down,
    color: Colors.white,
    ),
    ),
    (retracted)
    ? const SizedBox(
    height: 0,
    )
    : Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Row(
    children: [
    Expanded(
    child: TextField(
    controller: textController,
    decoration: InputDecoration(
    labelText: 'Enter Text',
    labelStyle:
    TextStyle(color: Colors.grey[800]),
    fillColor: Colors.white,
    focusColor: Colors.white,
    hoverColor: Colors.white,
    focusedBorder: const OutlineInputBorder(
    borderRadius:
    BorderRadius.all(Radius.circular(15.0)),
    ),
    filled: true,
    border: const OutlineInputBorder(
    borderRadius:
    BorderRadius.all(Radius.circular(10.0)),
    ),
    ),
    ),
    ),
    ElevatedButton(
    onPressed: () {
    setState(() {
    incomingText.add(textController.text);
    });
    translateText(textController.text, toCode);
    textController.clear();
    },
    child: const Text('Add')),
    ],
    ),
    ),
    (retracted)
    ? const SizedBox(
    height: 0,
    )
    : Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
    ElevatedButton(
    onPressed: () {
    if (incomingTextIndex == incomingText.length) {
    setState(() {
    incomingTextIndex = 0;
    outgoingTextIndex = 0;
    });
    }
    flutterTts.speak(outgoingText[outgoingTextIndex]);
    setState(() {
    incomingTextIndex++;
    outgoingTextIndex++;
    });
    },
    child: const Text('Start'),
    ),
    ElevatedButton(
    onPressed: () {
    flutterTts.stop();
    },
    child: const Text('Stop'),
    ),
    ],
    ),
    (retracted)
    ? const SizedBox(
    height: 0,
    )
    : const Text(
    'Speed',
    style: TextStyle(color: Colors.white),
    ),
    (retracted)
    ? const SizedBox(
    height: 0,
    )
    : Slider(
    value: rate.toDouble(),
    min: 0,
    max: 100,
    divisions: 100,
    label: rate.round().toString(),
    onChanged: (double value) {
    setState(() {
    rate = value.round();
    });
    flutterTts.setSpeechRate(rate / 100);
    },
    ),
    (retracted)
    ? const SizedBox(
    height: 0,
    )
    : Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
    const Text(
    'From',
    style: TextStyle(color: Colors.white),
    ),
    DropdownButton<String>(
    dropdownColor: Colors.grey[800],
    menuMaxHeight: 300,
    value: fromCode,
    items: fromLanguages
    .map<DropdownMenuItem<String>>((String value) {
    return DropdownMenuItem<String>(
    value: value,
    child: Text(value,
    style:
    const TextStyle(color: Colors.white)),
    );
    }).toList(),
    onChanged: (String? value) {
    setState(() {
    fromCode = value!;
    });
    },
    ),
    const Text(
    'To',
    style: TextStyle(color: Colors.white),
    ),
    DropdownButton<String>(
    dropdownColor: Colors.grey[800],
    menuMaxHeight: 300,
    value: toCode,
    items: fromLanguages
    .map<DropdownMenuItem<String>>((String value) {
    return DropdownMenuItem<String>(
    value: value,
    child: Text(value,
    style:
    const TextStyle(color: Colors.white)),
    );
    }).toList(),
    onChanged: (String? value) {
    setState(() {
    toCode = value!;
    outgoingText.clear();
    translateTexts(incomingText, toCode);
    });

    flutterTts.setLanguage(toCode);
    },
    ),
    ],
    )
    ],
    ),
    ),
    ),
 */
