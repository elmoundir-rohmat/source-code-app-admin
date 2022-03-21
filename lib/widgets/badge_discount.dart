import 'package:flutter/material.dart';
import '../constants/ColorCodes.dart';
import 'package:flutter_translate/flutter_translate.dart';
class BadgeDiscount extends StatelessWidget {
  const BadgeDiscount({
    Key key,
    @required this.child,
    @required this.value,

    this.color,
  }) : super(key: key);

  final Widget child;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {

    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
          left: 0,
          top: 0,
          child: Container(
//height:20,
            padding: EdgeInsets.all(3.0),
            // color: Theme.of(context).accentColor,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(5.0),
              ),
              color: ColorCodes.badgeColor,
            ),
            constraints: BoxConstraints(
              minWidth: 26,
              minHeight: 16,
            ),
            child: Text(
              translate('forconvience.OFF')+" "+value + "% ",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).buttonColor,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
        )
      ],
    );
  }
}