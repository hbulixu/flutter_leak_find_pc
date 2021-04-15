import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './syntax_highlighter.dart';
import 'flutter_leak_detector.dart';

class MyCodeView extends StatefulWidget {
  final String fileContent;
  final ReportLint reportLint;

  MyCodeView({@required this.fileContent,this.reportLint});

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
                      DartSyntaxHighlighter(style).format(codeContent,widget.reportLint)
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
            title:Text('')
        ),
        body:  Padding(
          padding: EdgeInsets.all(4.0),
          child: _getCodeView(widget.fileContent, context),
        ),
      );

  }
}
