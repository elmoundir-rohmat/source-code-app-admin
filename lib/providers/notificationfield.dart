import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NotificationFields with ChangeNotifier {
  final String id;
  final String title;
  final String status;
  final String date;
  final String notificationFor;
  final String dateTime;
  final String data;
  final String message;
  final int unreadcount;
  final String statusUpdate;

  NotificationFields({
    this.id,
    this.title,
    this.status,
    this.date,
    this.notificationFor,
    this.dateTime,
    this.data,
    this.message,
    this.unreadcount,
    this.statusUpdate,
  });
}
