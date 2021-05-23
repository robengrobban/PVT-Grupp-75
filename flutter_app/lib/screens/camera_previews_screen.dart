import 'dart:io';
import 'dart:typed_data';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:flutter_app/theme.dart' as Theme;

class PreviewScreen extends StatefulWidget {
  final String imgPath;

  PreviewScreen({this.imgPath});

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(centerTitle: true, title: Text("Camera")),
        backgroundColor: Colors.white,
        body: Container(
          padding: const EdgeInsets.only(left: 32.0, right: 32.0),
          decoration: BoxDecoration(gradient: Theme.appGradiant),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Image.file(
                    File(widget.imgPath),
                    fit: BoxFit.cover,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    height: 60.0,
                    color: Colors.white38,
                    child: Center(
                      child: ElevatedButton(
                        style: ButtonStyle(
                            minimumSize:
                                MaterialStateProperty.all<Size>(Size(42, 42)),
                            elevation: MaterialStateProperty.all<double>(0),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.transparent),
                            shape: MaterialStateProperty.all<CircleBorder>(
                                CircleBorder()),
                            side: MaterialStateProperty.all<BorderSide>(
                              BorderSide(
                                  width: 3,
                                  color: Theme.AppColors.brandPink[400]),
                            )),
                        child: Icon(
                          Icons.share,
                          color: Theme.AppColors.brandPink[400],
                          size: 30,
                        ),
                        onPressed: () {
                          getBytesFromFile().then((bytes) {
                            Share.file('Share via', basename(widget.imgPath),
                                bytes.buffer.asUint8List(), 'image/path');
                          });
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Future<ByteData> getBytesFromFile() async {
    Uint8List bytes = File(widget.imgPath).readAsBytesSync();
    return ByteData.view(bytes.buffer);
  }
}
