import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.red,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List> _getData() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = "${documentsDirectory.path}/demo.db";
    bool exists = await new File(path).exists();
    // On first install, copy database out of assets and into documents dir

    if (!exists) {
      ByteData data = await rootBundle.load("assets/demo.db");
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await new File(path).writeAsBytes(bytes);
    }
    Database database = await openDatabase(path, version: 1);
    List<Map> list = await database.rawQuery('SELECT * FROM Test');
    print(list);
    return list;
  }

  @override
  Widget build(BuildContext context) {
    const List<Color> colors = const <Color>[
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ];
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('GridView example'),
      ),
      body: new FutureBuilder(
        future: _getData(),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (!snapshot.hasData) {
            return new Container();
          }
          List items = snapshot.data;
          return new GridView.builder(
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              Map item = items[index];
              return new Container(
                color: colors[index % colors.length],
                child: new Center(
                  child: new Text(
                    '${item['id']}: ${item['name']}',
                    style: new TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
