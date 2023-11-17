// import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

class UploadFiles extends StatefulWidget {
  const UploadFiles({super.key});

  static const String routeName = 'file';

  @override
  State<UploadFiles> createState() => _UploadFilesState();
}

class _UploadFilesState extends State<UploadFiles> {
  PlatformFile? pickedFile;
  bool uploading = false;
  UploadTask? uploadTask;
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments;
    return Container(
      color: Colors.cyan,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (pickedFile != null)
            Container(
              alignment: Alignment.topCenter,
              width: MediaQuery.of(context).size.width * .8,
              color: Colors.cyanAccent,
              child: Center(
                child: Image.file(
                  File(pickedFile!.path!),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: selectFile,
            child: const Text(
              "Select File",
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              uploadFile(data);
            },
            child: const Text("Upload File"),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: CircularPercentIndicator(
              radius: 60.0,
              lineWidth: 5.0,
              percent: progress,
              center: Text("${progress * 100}%"),
              progressColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Future selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
    } else {
      return;
    }
    setState(() {
      pickedFile = result.files.first;
    });
  }

  Future uploadFile(data) async {
    try {
      final path = '${data["name"]}/${p.basename(pickedFile!.path!)}';
      final file = File(pickedFile!.path!);
      print(pickedFile!.path!);

      final ref = FirebaseStorage.instance.ref().child(path);

      ref.putFile(file).snapshotEvents.listen((taskSnapshot) async {
        switch (taskSnapshot.state) {
          case TaskState.running:
            progress = taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
            setState(() {});
            break;
          case TaskState.paused:
            // ...
            break;
          case TaskState.success:
            // ...
            Fluttertoast.showToast(
                msg: "Successfully upload",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);

            break;
          case TaskState.canceled:
            // ...
            break;
          case TaskState.error:
            // ...
            break;
        }
      });


      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc().set({
        'name': data["name"],
        'url': url,
      });

      // uploading = true;
      print('url $url');
    } catch (ex) {
      return AlertDialog(
        title: const Text('Please try again !'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    }
  }
}
