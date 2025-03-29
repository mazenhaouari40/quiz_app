import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/firebase_options.dart';
import 'package:quiz_app/start_page.dart';
import 'package:quiz_app/widget_tree.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());

  /*WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['apiKey'] ?? '',
      authDomain: dotenv.env['authDomain'] ?? '',
      projectId: dotenv.env['projectId'] ?? '',
      storageBucket: dotenv.env['storageBucket'] ?? '',
      messagingSenderId: dotenv.env['messagingSenderId'] ?? '',
      appId: dotenv.env['appId'] ?? '',
      measurementId: dotenv.env['measurementId'] ?? '',
    ),
  );
  runApp(MyApp());*/
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const WidgetTree(),
    );
  }
}
