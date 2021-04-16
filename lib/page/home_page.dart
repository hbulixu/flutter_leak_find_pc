
import 'package:flutter/material.dart';
import 'package:flutter_leak_find_pc/flutter_leak_detector.dart';
import 'package:flutter_leak_find_pc/page/my_code_view.dart';
import 'package:flutter_leak_find_pc/utils/file_selector.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String dartPath;
  String dartContent;
  String retainPathJson;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
                onPressed:(){
                  IndexCallback onTap =(String filePath,String fileContent){
                    this.dartPath = filePath;
                    this.dartContent = fileContent;
                    setState(() {

                    });
                  };
                  openFile(onTap);
                },
                child: Text(dartPath??'请选择源码路径')),
            SizedBox(
              height: 20,
            ),
            TextField(
              keyboardType: TextInputType.multiline,
              maxLines: 10,
              maxLength: 50000,
              decoration: InputDecoration(
                  hintText: '输入引用链:',
                  labelText: '引用链:',
                  border: const OutlineInputBorder()
              ),
              onChanged: (text)=>this.retainPathJson = text,
            ),
            RaisedButton(
              onPressed: (){
                generate(this.dartContent,this.retainPathJson);
                // saveFile(content, '');
                Navigator.of(context).push(
                    new PageRouteBuilder(
                        pageBuilder: (BuildContext context, Animation<double> animation,
                            Animation<double> secondaryAnimation){
                          return new MyCodeView( fileContent: this.dartContent,finlePath: this.dartPath,);
                        }));
              },
              child: const Text('开始检测',
                style: TextStyle(
                    color: Colors.white
                ),
              ),
              color: Color(0xFFFF552E),
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

}
