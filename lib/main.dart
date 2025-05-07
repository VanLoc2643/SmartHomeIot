import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vanlocapp/viewmodels/home_viewmodel.dart';
import 'package:vanlocapp/viewmodels/theme_viewmodel.dart';
import 'package:vanlocapp/views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeViewModel = Provider.of<ThemeViewModel>(context);

    return MaterialApp(
      title: 'Smart Home IoT',
      debugShowCheckedModeBanner: false,
      theme:
          themeViewModel.isDarkMode
              ? ThemeData.dark()
              : ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(),
    );
  }
}
