import 'package:flutter/foundation.dart';

class Advertise1Fields with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String bannerFor;
  final String bannerData;
  final String clickLink;
  final String displayFor;

  Advertise1Fields({
    this.id,
    this.title,
    this.description,
    this.price,
    this.imageUrl,
    this.bannerFor,
    this.bannerData,
    this.clickLink,
    this.displayFor,
  });
}