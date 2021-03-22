// VRUSHAKET PATWARDHAN

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as vrushaket_syspath;
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as vrushaket_path;

// This app will take some time to show photo to gallery ...Photos are saved in
// camera folder in DCIM
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Folder Storage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<bool> saveImage(String vru, PickedFile img) async {
    Directory directory;
    print(directory);
    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          directory = await vrushaket_syspath.getExternalStorageDirectory();
          String newPath = "";
          print(directory);
          List<String> paths = directory.path.split("/");
          for (int x = 1; x < paths.length; x++) {
            String folder = paths[x];
            if (folder != "Android") {
              newPath += "/" + folder;
            } else {
              break;
            }
          }
          newPath = newPath + "/DCIM" + "/Camera";
          directory = Directory(newPath);
          print(directory);
        } else {
          return false;
        }
      } else {
        if (await _requestPermission(Permission.photos)) {
          directory = await vrushaket_syspath.getTemporaryDirectory();
        } else {
          return false;
        }
      }
      final fileName = vrushaket_path.basename(vru);
      await File(img.path).copy(directory.path + "/$fileName");
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: ElevatedButton(
        onPressed: () async {
          final picker = ImagePicker();
          final img = await picker.getImage(source: ImageSource.camera);
          if (img == null) {
            return false;
          }
          await saveImage(img.path, img);
          setState(() {
            final snackBar =
                SnackBar(content: Text('Your Photo is Saved Successfully!'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          });
        },
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Text("Take Photo"),
        ),
      ),
    ));
  }
}
