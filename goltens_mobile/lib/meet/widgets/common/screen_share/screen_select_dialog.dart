import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:videosdk/videosdk.dart';
import '../../../constants/colors.dart';
import 'thumbnail_widget.dart';

// ignore: must_be_immutable
class ScreenSelectDialog extends Dialog {
  ScreenSelectDialog({super.key, required this.meeting}) {
    meeting.getScreenShareSources().then((value) => _setSources([]));
  }

  void _setSources(List<dynamic> source) {
    _sources = source;
    _stateSetter?.call(() {});
  }

  List<dynamic> _sources = [];
  // SourceType _sourceType = SourceType.Screen;
  dynamic? _selected_source;
  StateSetter? _stateSetter;
  final Room meeting;

  void _ok(context) async {
    Navigator.pop<dynamic>(context, _selected_source);
  }

  void _cancel(context) async {
    Navigator.pop<dynamic>(context, null);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
          child: Container(
        width: 640,
        height: 560,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: black700,
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10),
              child: Stack(
                children: <Widget>[
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Choose what to share',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      child: const Icon(Icons.close),
                      onTap: () => _cancel(context),
                    ),
                  ),
                ],
              ),
            ),
              Expanded(
              child: Center(
                child: Text(
                  'Screen sharing feature is currently being updated',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OverflowBar(
                children: <Widget>[
                  MaterialButton(
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      _cancel(context);
                    },
                  ),
                  MaterialButton(
                    color: purple,
                    child: const Text(
                      'Share',
                    ),
                    onPressed: () {
                      _ok(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}
