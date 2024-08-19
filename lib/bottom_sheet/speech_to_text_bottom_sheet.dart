import 'package:avatar_glow/avatar_glow.dart';
import 'package:bromine_browser/constants/size_manager.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextBottomSheet extends StatefulWidget {
  SpeechToTextBottomSheet(this.returnText);
  final void Function(String) returnText;
  @override
  _SpeechToTextBottomSheetState createState() =>
      _SpeechToTextBottomSheetState();
}

class _SpeechToTextBottomSheetState extends State<SpeechToTextBottomSheet> {
  stt.SpeechToText _speech;
  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    String _text = '';
    String _status = 'Tap to Speak';

    return Container(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
            color: Colors.white),
        child: StatefulBuilder(builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: SingleChildScrollView(
                  reverse: true,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      _text,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
              Text(_speech.isListening ? 'Listening...' : _status),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    backgroundColor: Colors.black,
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: SizeManager(context).iconSize,
                    ),
                    onPressed: () {
                      _text = '';
                      Navigator.pop(context);
                      setState(() {
                        if (_speech.isListening) {
                          _speech.stop();
                        }
                      });
                    },
                  ),
                  AvatarGlow(
                    animate: _speech.isListening,
                    glowColor: Theme.of(context).primaryColor,
                    endRadius: 75.0,
                    duration: const Duration(milliseconds: 2000),
                    repeatPauseDuration: const Duration(milliseconds: 100),
                    repeat: true,
                    child: FloatingActionButton(
                      backgroundColor: Colors.blue,
                      onPressed: () async {
                        if (!_speech.isListening) {
                          bool available = await _speech.initialize(
                            onStatus: (val) => print('onStatus: $val'),
                            onError: (val) => print('onError: $val'),
                          );
                          if (available) {
                            setState(() {
                              _speech.listen(
                                onResult: (val) => setState(() {
                                  _text = val.recognizedWords;
                                }),
                              );
                            });
                          }
                        } else {
                          setState(() {
                            _speech.stop();
                          });
                        }
                      },
                      child: Icon(
                        _speech.isListening ? Icons.mic : Icons.mic_none,
                        size: SizeManager(context).iconSize,
                      ),
                    ),
                  ),
                  FloatingActionButton(
                    backgroundColor: Colors.red,
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: SizeManager(context).iconSize,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        if (_speech.isListening) {
                          _speech.stop();
                        }
                      });
                      widget.returnText(_text);
                    },
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}
