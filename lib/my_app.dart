import 'package:cloud_task/widget/upload_files.dart';
import 'package:flutter/material.dart';

import 'widget/home.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(),
        UploadFiles.routeName: (context) => const UploadFiles(),
      },
    );
  }
}
