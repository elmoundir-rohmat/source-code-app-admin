import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';


class BadgeOfStock extends StatelessWidget {
  const BadgeOfStock({
    Key key,
    @required this.child,
    @required this.value,
    @required this.singleproduct,
    this.item,
    this.color,
  }) : super(key: key);

  final Widget child;
  final String value;
  final Color color;
  final bool singleproduct;
  final bool item;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
          left: singleproduct ? 80 :item?20:5,
          top: singleproduct ? 70 :30,
          right: singleproduct ? 80: item?20:5,
         // bottom: singleproduct?0:20,
          child: Container(

            padding: EdgeInsets.all(2.0),
            // color: Theme.of(context).accentColor,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(3.0),
              color: Theme.of(context).buttonColor,
            ),
            constraints: BoxConstraints(
              //maxWidth: singleproduct ? 5.0 : 30.0,
              minHeight: 20,
            ),
            child: Center(
              child: Text(
                translate('forconvience.OUT OF STOCK'),//"OUT OF STOCK",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: singleproduct ? 16 : 9,
                    color: Colors.grey,
                    fontWeight: singleproduct ?FontWeight.w600:FontWeight.w500
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}