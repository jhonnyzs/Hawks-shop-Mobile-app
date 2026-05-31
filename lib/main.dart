import 'package:flutter/material.dart';
import 'theme.dart';
import 'api.dart';
import 'screens/connect_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.instance.load();
  runApp(const HawksApp());
}

class HawksApp extends StatelessWidget {
  const HawksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hawkstronix Shop',
      debugShowCheckedModeBanner: false,
      theme: hawksTheme(),
      home: ApiService.instance.isPaired
          ? const HomeScreen()
          : const ConnectScreen(),
    );
  }
}
