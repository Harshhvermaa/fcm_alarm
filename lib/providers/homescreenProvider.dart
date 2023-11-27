import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../views/alarmRingScreen.dart';

class HomescreeenProvider with ChangeNotifier{
  late List<AlarmSettings> alarms;
  StreamSubscription<AlarmSettings>? subscription;

  startTimer(){

  }
  void loadAlarms() {
      alarms = Alarm.getAlarms();
      alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
      Future.delayed(Duration(milliseconds: 100)).then((value) {
        notifyListeners();
      });
  }
  void startSubscription(BuildContext context) {
    try {
      print("START NAVIGATION 1");
      subscription ??= Alarm.ringStream.stream.listen((alarmSettings) {
        print("START NAVIGATION 2");
        navigateToRingScreen(alarmSettings, context);
        notifyListeners();
      });
      print("Subscription started successfully ${subscription!.isPaused}");
    } catch (e) {
      print("Error during subscription: $e");
    }
  }

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings, BuildContext context) async {
    try {
      print("Navigating to AlarmRingScreen");
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AlarmRingScreen(alarmSettings: alarmSettings),
        ),
      );
      loadAlarms();
    } catch (e) {
      print("Error during navigation: $e");
    }
  }


}