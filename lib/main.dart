// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text_google_dialog/speech_to_text_google_dialog.dart';
import 'package:translator/translator.dart';

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
      home: const NewHomePage(),
    );
  }
}

class NewHomePage extends StatefulWidget {
  const NewHomePage({super.key});

  @override
  State<NewHomePage> createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage> {
  double heightOfMiddleContainer = 50;

  // if userMode is true = first user, false = second user
  // first user bottom part of the screen and second user top part of the screen
  bool userMode = true;
  List<String> firstUserInputs = [];
  List<String> secondUserInputs = [];
  List<String> translatedFirstUserInputs = [];
  List<String> translatedSecondUserInputs = [];
  List<String> firstUserListView = [];
  List<String> secondUserListView = [];
  int userModeIndex = 0;
  int volume = 100;
  int pitch = 75;
  int rate = 50;
  bool isPlaying = false;
  FlutterTts flutterTts = FlutterTts();
  GoogleTranslator translator = GoogleTranslator();
  List<String> languages = <String>[
    'tr-TR',
    'en-US',
    'es-ES',
    'de-DE',
    'ru-RU'
  ];
  String firstUserLanguage = 'en-US';
  String secondUserLanguage = 'es-ES';
  final ScrollController _firstUserScrollController = ScrollController();
  final ScrollController _secondUserScrollController = ScrollController();
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    initTts();
    _alwaysOnSpeaking();
    translateAll();
  }

  void alwaysOnListening() async {
    if (!isListening) return;

    bool isServiceAvailable =
        await SpeechToTextGoogleDialog.getInstance().showGoogleDialog(
      onTextReceived: (data) {
        setState(() {
          if (userMode) {
            firstUserInputs.add(data);
            translatedFirstUserInputs.add('');
            translateFirstUserInput(data, firstUserInputs.length - 1);
          } else {
            secondUserInputs.add(data);
            translatedSecondUserInputs.add('');
            translateSecondUserInput(data, secondUserInputs.length - 1);
          }
        });

        alwaysOnListening();
      },
      locale: userMode ? firstUserLanguage : secondUserLanguage,
    );

    if (!isServiceAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Service is not available'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 16,
          right: 16,
        ),
      ));
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> initTts() async {
    await flutterTts.setVolume(volume / 100);
    await flutterTts.setSpeechRate(rate / 100);
    await flutterTts.setPitch(pitch / 100);
    await flutterTts.setLanguage(secondUserLanguage);
  }

  Future _alwaysOnSpeaking() async {
    while (true) {
      if (isPlaying) {
        if (userMode) {
          if (translatedFirstUserInputs.isEmpty) {
            await Future.delayed(const Duration(seconds: 2));
          } else {
            print(translatedFirstUserInputs[userModeIndex]);
            await flutterTts.speak(translatedFirstUserInputs[userModeIndex]);
            await Future.delayed(Duration(
                seconds:
                    ((translatedFirstUserInputs[userModeIndex].length ~/ 7))));
            setState(() {
              userModeIndex++;
              if (userModeIndex >= translatedFirstUserInputs.length) {
                setState(() {
                  userModeIndex = 0;
                });
              }
            });
          }
        } else {
          if (translatedSecondUserInputs.isEmpty) {
            await Future.delayed(const Duration(seconds: 2));
          } else {
            print(translatedSecondUserInputs[userModeIndex]);
            await flutterTts.speak(translatedSecondUserInputs[userModeIndex]);
            await Future.delayed(Duration(
                seconds:
                    ((translatedSecondUserInputs[userModeIndex].length ~/ 7))));
            setState(() {
              userModeIndex++;
              if (userModeIndex >= translatedSecondUserInputs.length) {
                setState(() {
                  userModeIndex = 0;
                });
              }
            });
          }
        }
      } else {
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  void changeTTSLanguage(String language) async {
    await flutterTts.setLanguage(language);
  }

  void changeSecondUserLanguage(String language) {
    setState(() {
      secondUserLanguage = language;
    });
  }

  void changeFirstUserLanguage(String language) {
    setState(() {
      firstUserLanguage = language;
    });
  }

  void translateAll() {
    translateAllFirstUserInputs();
    translateAllSecondUserInputs();
    setState(() {
      if (userMode) {
        firstUserListView = firstUserInputs;
        secondUserListView = translatedFirstUserInputs;
      } else {
        secondUserListView = secondUserInputs;
        firstUserListView = translatedSecondUserInputs;
      }
    });
  }

  void changeUserMode() {
    setState(() {
      userMode = !userMode;
    });
  }

  void translateAllFirstUserInputs() {
    clearTranslatedFirstUserInputs();
    for (int i = 0; i < firstUserInputs.length; i++) {
      translatedFirstUserInputs.add('');
    }
    for (int i = 0; i < firstUserInputs.length; i++) {
      translateFirstUserInput(firstUserInputs[i], i);
    }
  }

  void translateAllSecondUserInputs() {
    clearTranslatedSecondUserInputs();
    for (int i = 0; i < secondUserInputs.length; i++) {
      translatedSecondUserInputs.add('');
    }
    for (int i = 0; i < secondUserInputs.length; i++) {
      translateSecondUserInput(secondUserInputs[i], i);
    }
  }

  void clearTranslatedFirstUserInputs() {
    setState(() {
      translatedFirstUserInputs.clear();
    });
  }

  void clearTranslatedSecondUserInputs() {
    setState(() {
      translatedSecondUserInputs.clear();
    });
  }

  void translateFirstUserInput(String input, int index) async {
    Translation translation =
        await translator.translate(input, to: secondUserLanguage.split('-')[0]);
    addTranslatedFirstUserInput(translation.text, index);
    print("First User Input: $input");
    print("First User Translation: ${translation.text}");
  }

  void translateSecondUserInput(String input, int index) async {
    Translation translation =
        await translator.translate(input, to: firstUserLanguage.split('-')[0]);
    addTranslatedSecondUserInput(translation.text, index);
  }

  void addTranslatedFirstUserInput(String input, int index) {
    setState(() {
      translatedFirstUserInputs[index] = input;
    });
  }

  void addTranslatedSecondUserInput(String input, int index) {
    setState(() {
      translatedSecondUserInputs[index] = input;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            SizedBox(
              height: (MediaQuery.of(context).size.height -
                          3 * heightOfMiddleContainer) /
                      2 -
                  20,
              width: MediaQuery.of(context).size.width,
              child: Transform.flip(
                flipY: true,
                flipX: true,
                child: ListView.builder(
                    itemCount: secondUserListView.length,
                    shrinkWrap: true,
                    controller: _secondUserScrollController,
                    itemBuilder: (context, index) {
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              userModeIndex = index;
                            });
                          },
                          onLongPress: () {
                            // delete that line from the list
                            setState(() {
                              if (userMode) {
                                firstUserInputs.removeAt(index);
                                translatedFirstUserInputs.removeAt(index);
                              } else {
                                secondUserInputs.removeAt(index);
                                translatedSecondUserInputs.removeAt(index);
                              }
                              translateAll();
                            });
                          },
                          child: SizedBox(
                            height: 48,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Text(
                                secondUserListView[index],
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: (userModeIndex == index)
                                      ? Colors.grey[300]
                                      : Colors.grey[500],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: SizedBox(
                height: heightOfMiddleContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<String>(
                      dropdownColor: Colors.grey[800],
                      menuMaxHeight: 300,
                      value: secondUserLanguage,
                      items: languages
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Transform.rotate(
                            angle: 3.14159,
                            child: Text(value,
                                style: const TextStyle(color: Colors.white)),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        changeSecondUserLanguage(value!);
                        if (userMode) {
                          changeTTSLanguage(value);
                        }
                        if (!userMode) {
                          secondUserInputs.clear();
                          translatedSecondUserInputs.clear();
                        }
                        translateAll();
                      },
                    ),
                    Transform.rotate(
                        angle: 3.14159,
                        child: Text(
                          (userMode) ? 'To:' : 'From:',
                          style: const TextStyle(color: Colors.white),
                        )),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: heightOfMiddleContainer,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isListening = !isListening;
                      });
                      if (isListening) {
                        alwaysOnListening();
                      }
                    },
                    child: Icon((isListening) ? Icons.mic : Icons.mic_off),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        changeUserMode();
                        if (userMode) {
                          setState(() {
                            userModeIndex = 0;
                            firstUserListView = firstUserInputs;
                            secondUserListView = translatedFirstUserInputs;
                            isPlaying = false;
                          });
                        } else {
                          setState(() {
                            userModeIndex = 0;
                            secondUserListView = secondUserInputs;
                            firstUserListView = translatedSecondUserInputs;
                            isPlaying = false;
                          });
                        }

                        if (userMode) {
                          changeTTSLanguage(secondUserLanguage);
                        } else {
                          changeTTSLanguage(firstUserLanguage);
                        }
                      },
                      child: const Icon(Icons.swap_vert)),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isPlaying = !isPlaying;
                        });
                      },
                      child:
                          Icon((isPlaying) ? Icons.pause : Icons.play_arrow)),
                  ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return Container(
                                    height: 300,
                                    decoration: BoxDecoration(
                                        color: Colors.grey[900],
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20))),
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 10),
                                        const Text(
                                          'Settings',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        const SizedBox(height: 30),
                                        const Text(
                                          'Volume',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Slider(
                                          value: volume.toDouble(),
                                          min: 0,
                                          max: 100,
                                          onChanged: (double value) {
                                            setState(() {
                                              volume = value.toInt();
                                            });
                                            flutterTts.setVolume(value / 100);
                                          },
                                        ),
                                        const Text(
                                          'Pitch',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Slider(
                                          value: pitch.toDouble(),
                                          min: 0,
                                          max: 100,
                                          onChanged: (double value) {
                                            setState(() {
                                              pitch = value.toInt();
                                            });
                                            flutterTts.setPitch(value / 100);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            });
                      },
                      child: const Icon(Icons.settings))
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: SizedBox(
                height: heightOfMiddleContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      (userMode) ? 'From:' : 'To:',
                      style: const TextStyle(color: Colors.white),
                    ),
                    DropdownButton<String>(
                      dropdownColor: Colors.grey[800],
                      menuMaxHeight: 300,
                      value: firstUserLanguage,
                      items: languages
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        changeFirstUserLanguage(value!);
                        if (!userMode) {
                          changeTTSLanguage(value);
                        }
                        if (userMode) {
                          firstUserInputs.clear();
                          translatedFirstUserInputs.clear();
                        }
                        translateAll();
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: (MediaQuery.of(context).size.height -
                          3 * heightOfMiddleContainer) /
                      2 -
                  20,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                  itemCount: firstUserListView.length,
                  shrinkWrap: true,
                  controller: _firstUserScrollController,
                  itemBuilder: (context, index) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            isPlaying = false;
                            userModeIndex = index;
                          });
                        },
                        onLongPress: () {
                          //isListening = false;
                          isPlaying = false;
                          setState(() {
                            if (userMode) {
                              firstUserInputs.removeAt(index);
                              translatedFirstUserInputs.removeAt(index);
                            } else {
                              secondUserInputs.removeAt(index);
                              translatedSecondUserInputs.removeAt(index);
                            }
                            translateAll();
                          });
                        },
                        child: SizedBox(
                          height: 48,
                          child: Center(
                            child: Text(
                              firstUserListView[index],
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                color: (userModeIndex == index)
                                    ? Colors.grey[300]
                                    : Colors.grey[500],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
