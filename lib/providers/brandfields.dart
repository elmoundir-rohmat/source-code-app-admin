import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BrandsFields with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String banner_for;
  final String banner_data;
  final String clickLink;
  Color boxbackcolor;
  Color boxsidecolor;
  Color textcolor;

  BrandsFields({
    @required this.id,
    this.title,
    this.description,
    this.price,
    @required this.imageUrl,
    this.banner_for,
    this.banner_data,
    this.clickLink,
    this.boxbackcolor,
    this.boxsidecolor,
    this.textcolor,
    Color featuredCategoryBColor,
  });
}