// import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/material.dart';
import 'package:goltens_mobile/meet/constants/colors.dart';
import 'package:videosdk/videosdk.dart';
import 'thumbnail_widget.dart';

// ignore: must_be_immutable
class ScreenSelectDialog extends Dialog {
  ScreenSelectDialog({Key? key, required this.meeting}) : super(key: key) {
    // meeting.getScreenShareSources().then((value) => _setSources([]));
    _setSources([]); // Empty sources for now
  }

  void _setSources(List<dynamic> source) { // Changed from DesktopCapturerSource
    _sources = source;
    _stateSetter?.call(() {});
  }

  List<dynamic> _sources = []; // Changed type
  // SourceType _sourceType = SourceType.Screen; // Comment out
  dynamic _selected_source; // Changed type
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
                      'Screen sharing temporarily disabled',
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
              child: ButtonBar(
                children: <Widget>[
                  MaterialButton(
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => _cancel(context),
                  ),
                  MaterialButton(
                    color: purple,
                    child: const Text('OK'),
                    onPressed: () => _ok(context),
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