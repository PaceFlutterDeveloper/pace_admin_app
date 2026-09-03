import 'dart:developer';

import 'package:admin_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Top-level FCM background handler. Must be registered before [runApp].
///
/// Do not show a local notification here when the message includes a
/// `notification` payload — Android/iOS already display it.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  log(
    'FCM background: id=${message.messageId} data=${message.data} '
    'notification=${message.notification?.title}',
  );
}
