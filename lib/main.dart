import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/*
KULLANILAN MAİL : 07flutteregitim@gmail.com
paket ismi : com.ramzey.flutterandroidiosfcm2024
server key : AAAAAIVOT7A:APA91bGkjxpdjpiZz_dmRC5jF42Mqhse-l01XHg92480TklKx3_Ss9-YVwDqUTZ8JKWQfbSA7Zb8A7n6o7xNz_zKrvDDA0j5frg6d0lck_wDHRQf6-euaxw7_--wntCHXYvlgCqdyayo

https://fcm.googleapis.com/fcm/send
{
   "to": "fD4xmi6cT523WjCo--6VFx:APA91bHKZoS6_0O501B9tdwUGuxy9DB4kSvgvEAtE71AF2HlGWEJ9pcIIueePFnTjoEtGO91neeepyeHXkJKOaoG43HCkuHuLOmmci7JICTCeD6b1IlTRMbaaaKZzgYBFbKpRqhteyjJ",
   "notification": {
    "body": "Hello2",
    "title": "This is test message.2",
    "content_available" : true,
    "priority" : "high"
   }
}

Authorization
key=AAAAAIVOT7A:APA91bGkjxpdjpiZz_dmRC5jF42Mqhse-l01XHg92480TklKx3_Ss9-YVwDqUTZ8JKWQfbSA7Zb8A7n6o7xNz_zKrvDDA0j5frg6d0lck_wDHRQf6-euaxw7_--wntCHXYvlgCqdyayo
 */
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('onBackgroundMessage received: $message');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  notificationDetails() {
    return NotificationDetails(
        android: AndroidNotificationDetails('kanalid', 'kanalisim',
            importance: Importance.max),
        iOS: DarwinNotificationDetails());
  }

  Future showNotification(
      {int id = 0, String? title, String? body, String? payLoad}) async {
    return flutterLocalNotificationsPlugin.show(
        id, title, body, await notificationDetails());
  }

  String? gelenToken = "";

  Future<void> fcmBaslat() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // iOS için izin isteme
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }

    AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Token almak için
    gelenToken = await _firebaseMessaging.getToken();
    print('Token: $gelenToken');
    await Clipboard.setData(ClipboardData(text: gelenToken));

    // mesaj gelince burası çalışır
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('onMessage received: $message');

      final title = message.notification!.title;
      final body = message.notification!.body;
      showNotification(title: title, body: body);
    });

    // uygulama kapalı iken veya arkaplanda iken Bildirime tıklanınca çalışır
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('onMessageOpenedApp received: $message');
    });

    FirebaseMessaging.instance
        .subscribeToTopic("all")
        .then((value) => print("topic all olarak eklendi"));

    setState(() {

    });
  }

  @override
  void initState() {
    super.initState();
    fcmBaslat();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: gelenToken == ""
          ? Scaffold(
              body: Center(
              child: CircularProgressIndicator(),
            ))
          : MyHomePage(
              token: gelenToken!,
            ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  String token = "";

  MyHomePage({required this.token});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController txtController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    txtController = new TextEditingController();
    txtController.text = widget.token;
    print(widget.token + "--");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("FCM 2024"),
        ),
        body: Container(
            child: TextFormField(
          controller: txtController,  keyboardType: TextInputType.multiline,
              maxLines: null,

        )));
  }
}
