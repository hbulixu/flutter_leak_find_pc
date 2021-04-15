

import 'package:flutter/foundation.dart';

class ReportNodeInfo{
  final int score;
  final int lineNum;
  final String tips;
  final int begin;
  final int end;
  ReportNodeInfo(this.score, this.lineNum, this.tips,this.begin,this.end);
}


class ReportLeak{

  Map <int,ReportNodeInfo> reportLineMap ={};

  static  ReportLeak _instance;
  ReportLeak._internal();
  factory ReportLeak.getInstance() => _getInstance();

  static _getInstance(){
    if (_instance == null) {
      _instance = ReportLeak._internal();
    }
    return _instance;
  }

  static void clean(){
    ReportLeak.getInstance().reportLineMap ={};
  }


  static void add(int key,ReportNodeInfo newValue){

    var reportLineMap =   ReportLeak.getInstance().reportLineMap;

    if(reportLineMap.containsKey(key)){

      var oldValue =  reportLineMap[key];

      if(newValue.score > oldValue.score){

        reportLineMap.update(key, (value) => newValue);
      }

    }else{
      reportLineMap.putIfAbsent(key, () => newValue);
    }
  }
}