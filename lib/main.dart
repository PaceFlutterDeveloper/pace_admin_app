import 'package:admin_app/UI/notification/services/firebase_service.dart';
import 'package:admin_app/UI/notification/services/notification_service.dart';
import 'package:admin_app/app.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();
  FirebaseService.initialize();

  await serviceLocators();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MyApp());
  });
}

var logger = Logger();
