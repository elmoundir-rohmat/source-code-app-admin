import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../screens/brands_screen.dart';
import '../constants/images.dart';


class BrandsItems extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  final int indexvalue;

  BrandsItems(this.id, this.title, this.imageUrl, this.indexvalue);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
                BrandsScreen.routeName,
                arguments: {
                  'brandId' : id,
                  'indexvalue' : indexvalue.toString(),
                }
            );
          },
          child: Column(
              children: <Widget>[
              Spacer(),
              Container(
                padding: EdgeInsets.all(10.0),
                width: 70.0,
                height: 40.0,
                margin: EdgeInsets.only(right: 10.0),
                decoration: new BoxDecoration(
                  color: Colors.white,
                  /*image: new DecorationImage(
                    image: new NetworkImage(imageUrl),
                  ),*/
                  borderRadius: new BorderRadius.all(new Radius.circular(2.0)),
                  border: new Border.all(
                    color: Colors.grey.shade300,
                    //width: 4.0,
                  ),
                ),
                child: CachedNetworkImage(
                  imageUrl:imageUrl,
                  width: 150.0, height: 50.0,
                  fit:BoxFit.fitWidth,
                  placeholder: (context, url) => Image.asset(Images.defaultBrandImg,
                    width: 80.0, height: 80.0,
                    fit:BoxFit.fitWidth,
                  ),
                ),


              ),
              Spacer(),
            ],
          ),
        ),
      )
    //),
    );
  }
}