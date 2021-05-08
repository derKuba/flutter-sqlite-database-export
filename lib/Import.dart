import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Import extends StatefulWidget {
  final Directory downloadDirectory;

  Import({Key key, this.downloadDirectory}) : super(key: key);

  @override
  _ImportState createState() => _ImportState();
}

class _ImportState extends State<Import> {
  String selectedFile = "";

  _importDB(BuildContext context) async {
    print(selectedFile);
    if (selectedFile == "") return;
    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      } else {
        var srcFile = File(selectedFile);
        var dbFileBytes = srcFile.readAsBytesSync();
        var bytes = ByteData.view(dbFileBytes.buffer);
        final buffer = bytes.buffer;

        var databasesPath = await getDatabasesPath();
        var distPath = join(databasesPath, 'doggy__${DateTime.now()}.db');

        await File(distPath).writeAsBytes(buffer.asUint8List(
            dbFileBytes.offsetInBytes, dbFileBytes.lengthInBytes));
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Import"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<FileSystemEntity>>(
          future: widget.downloadDirectory.list().toList(),
          builder: (BuildContext context,
              AsyncSnapshot<List<FileSystemEntity>> snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 0),
                children: snapshot.data
                    .where((fileName) => fileName.path.endsWith(".db"))
                    .toList()
                    .map((fileName) {
                  return RadioListTile<String>(
                    title: Text(fileName.path ?? ""),
                    value: fileName.path,
                    groupValue: selectedFile,
                    onChanged: (String value) {
                      print(value);
                      setState(() {
                        selectedFile = value;
                      });
                    },
                  );
                }).toList(),
              );
            } else {
              return Center(
                  child: Column(children: <Widget>[
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('Error: ${snapshot.error}'),
                )
              ]));
            }
          }),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add),
        label: Text('Auswahl importieren'),
        onPressed: () => _importDB(context),
        foregroundColor: Colors.black,
        backgroundColor: Colors.greenAccent,
        elevation: 0.0,
      ),
    );
  }
}
