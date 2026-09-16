import 'package:flutter/material.dart';
import 'package:campus_care/app/config.dart';
import 'package:campus_care/app/router.dart';
import 'package:campus_care/app/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CampusCareApp());
}

class CampusCareApp extends StatelessWidget {
  const CampusCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
