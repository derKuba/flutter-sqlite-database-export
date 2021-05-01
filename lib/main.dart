import 'dart:io';
import 'dart:typed_data';

import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  runApp(MyApp());
}

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
  Future<File> _writeDBFileToDownloadFolder() async {
    // do not do this. this is just for creating a sqlite.db file
    // https://flutter.dev/docs/cookbook/persistence/sqlite
    // should create a doggie_database.db under
    // /data/data/com.example.flutter_sqlite_database_export/databases/doggie_database.db

    try {
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
    } catch (error) {}

    String dbName = "doggie_database.db";
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
            Text("SQlite Export Example"),
            TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: () async {
                var status = await Permission.storage.status;
                if (status.isDenied) {
                  await Permission.storage.request();
                  return;
                }

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
