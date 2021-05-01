import 'dart:io';

import 'package:flutter/material.dart';

import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  runApp(MyApp());
}

// https://flutter.dev/docs/cookbook/persistence/sqlite
//

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  initState() async {
    super.initState();

    final Future<Database> database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'doggie_database.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)",
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }

  _writeDBFileToDownloadFolder(){
     String dbName = "databaseName.db";

    // storage permission ask
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    } else {
      var databasesPath = await getDatabasesPath();
      var innerPath = join(databasesPath, dbName);
      print(innerPath);

      var dbFile = File(innerPath);

      Directory tempDir = await DownloadsPathProvider.downloadsDirectory;
      String tempPath = tempDir.path;

      var filePath = tempPath + '/$dbName';
      var dbFileBytes = dbFile.readAsBytesSync();
      var bytes = ByteData.view(dbFileBytes.buffer);
      final buffer = bytes.buffer;

      return File(filePath).writeAsBytes(buffer.asUint8List(
          dbFileBytes.offsetInBytes, dbFileBytes.lengthInBytes));
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("SQlite Export Example"),
            TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: () async {
                  File file = await _writeDBFileToDownloadFolder();
                  if (await file.length() > 0) {
                    print("success");
                  }
              },
              child: Text('IMPORT'),
            )
          ],
        ),
      ),
    );
  }
}
