import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:message_app/provider/message_provider.dart';
import 'package:message_app/theme/darktheme.dart';
import 'package:message_app/theme/lighttheme.dart';
import 'package:provider/provider.dart';

import 'bridge/splashscreen.dart';
import 'constant/snakbar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MessageProvider()),
        // Add more providers if needed
        // ChangeNotifierProvider(create: (context) => AnotherProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        scaffoldMessengerKey: SnackBarUtil.messengerKey,
        title: 'Chat App',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        home: SplashScreen());
  }
}
