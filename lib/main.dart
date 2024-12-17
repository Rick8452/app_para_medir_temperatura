import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'pushNotificationManager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      darkTheme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _dataController = TextEditingController();
  final databaseReference =
  FirebaseDatabase.instance.ref("test").child("relay");
  final Future<FirebaseApp> _future = Firebase.initializeApp();
  String data = "";
  String dataHumedad = "";
  PushNotificationManager manager = PushNotificationManager();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  void addData(String data) {
    databaseReference.set(data);
  }

  String printFromDatabase() {
    DatabaseReference _relayreference =
    FirebaseDatabase.instance.ref("test").child("temperatura");
    _relayreference.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value.toString();
      setState(() {
        this.data = data;
      });
    });
    return data;
  }

  String getHumidity() {
    DatabaseReference _relayreference =
    FirebaseDatabase.instance.ref("test").child("humedad");
    _relayreference.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value.toString();
      setState(() {
        this.dataHumedad = data;
      });
    });
    return dataHumedad;
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      print("Message received");
      print(message.notification!.body);
      print(message.notification!.title);
      _showNotificationAlertDialog(
          message.notification!.title, message.notification!.body);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      print(notification?.body.toString());
      print(notification?.title.toString());
    });
    printFromDatabase();
    getHumidity();
    manager.init();
  }

  void _showNotificationAlertDialog(String? title, String? body) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? ''), // Proporciona un valor predeterminado si title es null
          content: Text(body ?? ''), // Proporciona un valor predeterminado si body es null
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    PushNotificationManager manager = PushNotificationManager();
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    var color_on = Colors.green;
    var color_off = Colors.red;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase Database"),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            return Column(
              children: [
                const SizedBox(
                  height: 70,
                ),
                Text(
                  "Temperatura: $data" + "°C",
                  style: TextStyle(fontSize: 20, color: Colors.green),
                ),
                const SizedBox(
                  height: 70,
                ),
                Text(
                  "Humedad: $dataHumedad" + " %",
                  style: TextStyle(fontSize: 20, color: Colors.green),
                ),
                const SizedBox(
                  height: 50,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      addData("1");
                    },
                    child: Text("on"),
                    style: ElevatedButton.styleFrom(
                      primary: color_on,
                      onPrimary: Colors.black,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      addData("0");
                    },
                    child: Text("off"),
                    style: ElevatedButton.styleFrom(
                      primary: color_off,
                      onPrimary: Colors.black,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
