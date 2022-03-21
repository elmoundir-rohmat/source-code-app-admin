import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/images.dart';
import '../constants/ColorCodes.dart';
import 'package:flutter_translate/flutter_translate.dart';


class OrderhistoryDisplay extends StatefulWidget {
  final String itemname;
  final String varname;
  final String price;
  final String qty;
  final String subtotal;
  final String itemImage;

  OrderhistoryDisplay(
      this.itemname,
      this.varname,
      this.price,
      this.qty,
      this.subtotal,
      this.itemImage,
      );

  @override
  _OrderhistoryDisplayState createState() => _OrderhistoryDisplayState();
}

class _OrderhistoryDisplayState extends State<OrderhistoryDisplay> {
  var currency_format = "";

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      debugPrint("variation"+widget.varname);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        currency_format = prefs.getString("currency_format");
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:5,vertical:5.0),
      child: Container(
        height: 90,
        width: MediaQuery.of(context).size.width,// - 20,
       /* decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(width: 0.5, color: ColorCodes.borderColor),
          color: Colors.white,
        ),*/
        child:

        Row(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(6),
             // alignment: Alignment.centerLeft,
                child: CachedNetworkImage(
                  imageUrl: widget.itemImage,
                  placeholder: (context, url) => Image.asset(Images.defaultProductImg,
                    width: 90,
                    height: 90,),
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                )
            ),
            /* SizedBox(width: 10,),*/
            Expanded(
              child: Text(
                widget.itemname,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,),),
            ),
            Container(

              child: Padding(
                padding: const EdgeInsets.only(right:10.0),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical:8.0),
                      child: Text(translate('forconvience.Qty')+": "+widget.qty+"x"+" "+ widget.varname, style: TextStyle(color: ColorCodes.closebtncolor,fontSize: 16),),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical:5.0),
                      child: Text( " " + widget.subtotal+currency_format ,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                    ),
                  ],
                ),
              ),
            ),

            // Spacer(),
          ],
        ),
      ),
    );
  }
}