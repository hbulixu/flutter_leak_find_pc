

import 'dart:convert';
import 'flutter_leak_detector.dart';

String genLeakHtml(ReportLint reportLint,String fileContent)  {
    List<String> lines = LineSplitter().convert(fileContent);
    List<String> outLines = [];
    String srcPath = './';
    outLines.add(
        '''<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="zh">
<head>
    <meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>
    <link rel="stylesheet" href="${srcPath}jacoco-resources/report.css" type="text/css"/>
    <link rel="shortcut icon" href="${srcPath}jacoco-resources/report.gif" type="image/gif"/>
    <link rel="stylesheet" href="${srcPath}jacoco-resources/prettify.css" type="text/css"/>
    <script type="text/javascript" src="${srcPath}jacoco-resources/prettify.js"></script>
</head>
<body onload="window['PR_TAB_WIDTH']=4;prettyPrint()">
<div class="breadcrumb" id="breadcrumb">
<h1></h1>
<pre class="source lang-java linenums">''');
    for(int i=0;i<lines.length;i++){
      int lineNum = i+1;
      String lineCode ='';
      if(reportLint.reportLineMap.containsKey(lineNum)){
        ReportNodeInfo nodeInfo = reportLint.reportLineMap[lineNum];
        var classStr = '';
         if(nodeInfo.score < 2) {
           classStr = 'nc';
         }else{
           classStr = 'diff_nc';
         }

        lineCode = '<span class="${classStr}" id="L${lineNum}">${lines[i]}</span>';
      }else{
        lineCode = lines[i];
      }
      lineCode = lineCode + '\n';
      outLines.add(lineCode);
    }
    outLines.add(
        '''</pre>
          </body>
        </html>''');

    String ret ='';
    for(int i=0; i<outLines.length; i++){
      String lin = outLines[i];
      if(lin != null){
        ret +=lin;
      }

    }
    return ret;
}