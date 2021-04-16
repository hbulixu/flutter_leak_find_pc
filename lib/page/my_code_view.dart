import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/syntax_highlighter.dart';
import '../flutter_leak_detector.dart';
import '../report/report_leak.dart';

class MyCodeView extends StatefulWidget {
  final String fileContent;
  final String finlePath;
  MyCodeView({@required this.fileContent,this.finlePath});

  @override
  MyCodeViewState createState() {
    return MyCodeViewState();
  }
}

class MyCodeViewState extends State<MyCodeView> {
  double _textScaleFactor = 1.0;

  Widget _getCodeView(String codeContent, BuildContext context) {
    final SyntaxHighlighterStyle style =
        Theme.of(context).brightness == Brightness.dark
            ? SyntaxHighlighterStyle.darkThemeStyle()
            : SyntaxHighlighterStyle.lightThemeStyle();
    // TODO: try out CustomScrollView and SliverAppbar (appbar auto hides when scroll).
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: <Widget>[
        Container(
          constraints: BoxConstraints.expand(),
          child: Scrollbar(
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: RichText(
                  textScaleFactor: this._textScaleFactor,
                  text: TextSpan(
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12.0),
                    children: <TextSpan>[
                      DartSyntaxHighlighter(style).format(codeContent)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.zoom_out),
              onPressed: () => setState(() {
                    this._textScaleFactor =
                        max(0.8, this._textScaleFactor - 0.1);
                  }),
            ),
            IconButton(
              icon: Icon(Icons.zoom_in),
              onPressed: () => setState(() {
                    this._textScaleFactor += 0.1;
                  }),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

      return Scaffold(
        appBar: AppBar(
            title:Text(widget.finlePath)
        ),
        body:  Padding(
          padding: EdgeInsets.all(4.0),
          child: _getCodeView(widget.fileContent, context),
        ),
      );

  }
}
