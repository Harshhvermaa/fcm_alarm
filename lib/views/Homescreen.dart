import 'dart:async';
import 'dart:convert';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:fcm_alarm/providers/homescreenProvider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../widgets/alarmTile.dart';
import 'EditAlarm.dart';
import 'alarmRingScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeNoti();
    final homeProvider = Provider.of<HomescreeenProvider>(context, listen: false);
    homeProvider.loadAlarms();
    homeProvider.startSubscription(context);
  }
  // Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
  //   print("NAVIGATION");
  //   await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) =>
  //             AlarmRingScreen(alarmSettings: alarmSettings),
  //       ));
  //   Provider.of<HomescreeenProvider>(context,listen: false).loadAlarms();
  // }
  initializeNoti(){
    notificationServices.requestNotificationPermission();
    notificationServices.forgroundMessage();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.isTokenRefresh();
    notificationServices.getDeviceToken().then((value){
      if (kDebugMode) {
        print('device token');
        print(value);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('FCM ALARM APP'),
        // actions: [
        //   ElevatedButton(onPressed: () async{
        //     await Alarm.set(alarmSettings: AlarmSettings(
        //       // id: int.parse((DateTime.now().millisecondsSinceEpoch / 100).ceil().toString()),
        //       id: 235,
        //       dateTime: DateTime.now().add(Duration(minutes: 1)),
        //       assetAudioPath: "assets/nokia.mp3",
        //       notificationTitle: "fsdfsd",
        //       notificationBody: "sdfsdfs",
        //     ));
        //     Provider.of<HomescreeenProvider>(context,listen: false).loadAlarms();
        //   } , child: Text("Resetfresh")),
        // ],
      ),
      body: Consumer<HomescreeenProvider>(
        builder: (context, homeProvider, child) {
        return homeProvider.alarms.isNotEmpty
            ? Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: ListView.builder(
          itemCount: homeProvider.alarms.length,
          itemBuilder: (context, index) {
              return AlarmTile(
                key: Key(homeProvider.alarms[index].id.toString()),
                title: TimeOfDay(
                  hour: homeProvider.alarms[index].dateTime.hour,
                  minute: homeProvider.alarms[index].dateTime.minute,
                ).format(context),
                onPressed: () {},
                // onPressed: () => navigateToAlarmScreen(homeProvider.alarms[index] ,homeProvider),
                onDismissed: () {
                  Alarm.stop(homeProvider.alarms[index].id).then((_) => homeProvider.loadAlarms());
                  homeProvider.alarms.removeAt(index);
                  notificationServices.showNotification(RemoteMessage(
                        data: {
                          'type': 'msj',
                          'id': '123', // Replace with your desired data for the notification
                          // Other necessary data...
                        },
                        notification: RemoteNotification(
                          title: 'Alarm Dismiss',
                          body: 'Your ${index+1} alarm is disabled',
                          android: AndroidNotification(
                            channelId: 'channel_id', // Replace with your channel ID
                          ),
                        )));
                },
                // onPressed: () => navigateToAlarmScreen(homeProvider.alarms[index],homeProvider),
              );
          },
        ),
            )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
                Container(
                    height: 100,
                    width: 100,
                    child: Image(image: AssetImage("assets/notification.png"))),
                SizedBox(height: 30,),
                Text(
                  "No alarms",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                // ElevatedButton(onPressed: () {
                //   print(Alarm.getAlarms());
                //   print("H${homeProvider.alarms}");
                //   // setState(() {
                //   //
                //   // });
                // } , child: Text("Refresh")),
                // ElevatedButton(onPressed: () {
                //   Alarm.set(alarmSettings: AlarmSettings(
                //     id: int.parse((DateTime.now().millisecondsSinceEpoch / 1000).ceil().toString()),
                //     dateTime: DateTime.now().add(Duration(minutes: 1)),
                //     assetAudioPath: "assets/nokia.mp3",
                //     notificationTitle: "fsdfsd",
                //     notificationBody: "sdfsdfs",
                //   ));
                //   homeProvider.loadAlarms();
                // } , child: Text("Resetfresh")),
          ],
        ),
              ],
            );
      },
      )
    );
  }
}