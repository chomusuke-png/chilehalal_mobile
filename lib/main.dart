import 'package:chilehalal_mobile/screens/main_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chilehalal_mobile/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Notificación recibida en background: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('Error inicializando Firebase: $e');
  }

  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint('Error inicializando notificaciones locales: $e');
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint("Notificación recibida en primer plano: ${message.messageId}");
    
    if (message.notification != null) {
      final title = message.notification!.title ?? 'Nueva Notificación';
      final body = message.notification!.body ?? '';
      
      final uniqueId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      NotificationService().showInboxNotification(
        id: uniqueId,
        title: title,
        body: body,
      );
    }
  });
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChileHalal App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF325CAD),
          primary: const Color(0xFF325CAD),
          secondary: const Color(0xFFE40318),
          surface: const Color(0xFFFFFFFF),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black87,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFFFF),
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: MainWrapper(),
    );
  }
}