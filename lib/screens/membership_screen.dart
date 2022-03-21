import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../providers/branditems.dart';
import '../utils/ResponsiveLayout.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../data/calculations.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../providers/membershipitems.dart';
import '../widgets/badge.dart';
import '../screens/cart_screen.dart';
import '../screens/category_screen.dart';
import '../screens/home_screen.dart';
import '../screens/shoppinglist_screen.dart';
import '../screens/wallet_screen.dart';
import '../screens/signup_selection_screen.dart';
import '../data/hiveDB.dart';
import '../main.dart';
import '../constants/images.dart';

class MembershipScreen extends StatefulWidget {
  static const routeName = '/membership-screen';

  @override
  _MembershipScreenState createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  Box<Product> productBox;
  var _currencyFormat = "";
  bool _checkmembership = false;
  var orderdate = "";
  var expirydate = "";
  var orderid = "";
  var ordertotal = "";
  var name = "";
  var duration = "";
  var paytype = "";
  var address = "";
  bool _loading = true;
  bool checkskip = false;
  bool memberMode = false;
  SharedPreferences prefs;
  bool _isWeb = false;
  var _address = "";
  MediaQueryData queryData;
  double wid;
  double maxwid;
  bool iphonex = false;

  @override
  void initState() {
    productBox = Hive.box<Product>(productBoxName);
    Future.delayed(Duration.zero, () async {
      try {
        if (Platform.isIOS) {
          setState(() {
            _isWeb = false;
            iphonex = MediaQuery.of(context).size.height >= 812.0;
          });
        } else {
          setState(() {
            _isWeb = false;
          });
        }
      } catch (e) {
        setState(() {
          _isWeb = true;
        });
      }
      prefs = await SharedPreferences.getInstance();
      _address = prefs.getString("restaurant_address");
      await Provider.of<BrandItemsList>(context,listen: false).userDetails().then((_) {
        setState(() {
          if (prefs.getString('skip') == "yes") {
            setState(() {
              checkskip = true;
            });
          } else {
            checkskip = false;
          }
          _currencyFormat = prefs.getString("currency_format");

          for (int i = 0; i < productBox.values.length; i++) {
            if (productBox.values.elementAt(i).mode == 1) {
              setState(() {
                memberMode = true;
              });
            }
          }

          if (memberMode) {
            setState(() {
              _loading = false;
              _checkmembership = false;
            });
          } else if (prefs.getString("membership") == "1") {
            _checkmembership = true;
            Provider.of<MembershipitemsList>(context,listen: false).Getmembershipdetails().then((_) async {
              setState(() {
                orderdate = prefs.getString("orderdate");
                expirydate = prefs.getString("expirydate");
                orderid = prefs.getString("orderid");
                ordertotal = prefs.getString("membershipprice");
                name = prefs.getString("membershipname");
                duration = prefs.getString("duration");
                paytype = prefs.getString("memebershippaytype");
                address = prefs.getString("membershipaddress");
                _loading = false;
              });
            });
          } else {
            setState(() {
              _loading = false;
              _checkmembership = false;
            });
          }
        });
      });
    });
    super.initState();
  }

  _addtocart(String membershipid, String duration, String discountprice, String price) async {
    prefs.setString("membership", "1");
    /*Item testItems =
    Item(
      item_id: 0,
      var_id: 0,
      var_name: duration,
      var_minitem: 1,
      var_maxitem: 1,
      var_stock: 1,
      var_mrp: -1,
      item_name: "Membership",
      item_qty: 1,
      item_price: double.parse(discountprice),
      item_memberprice: discountprice,
      item_actualprice: double.parse(price),
      item_image: Images.membershipImg,
      membership_id: int.parse(membershipid),
      mode: 1, // mode =1 for membership
    );
    await DBProvider.db.newItem(testItems);
    Provider.of<CartItems>(context, listen: false).fetchCartItems();*/

    Product products = Product(
        itemId: 0,
        varId: 0,
        varName: duration,
        varMinItem: 1,
        varMaxItem: 1,
        varStock: 1,
        varMrp: -1,
        itemName: "Membership",
        itemQty: 1,
        itemPrice: double.parse(discountprice),
        membershipPrice: discountprice,
        itemActualprice: double.parse(price),
        itemImage: Images.membershipImg,
        membershipId: int.parse(membershipid),
        mode: 1);

    productBox.add(products);
  }

  _removefromcart() async {
    prefs.setString("membership", "0");
    Calculations.deleteMembershipItem();
    /*await DBProvider.db.deleteMembershipItem(1);
    Provider.of<CartItems>(context, listen: false).fetchCartItems();*/
  }

  _updatetocart(String membershipid, String duration, String discountprice, String price) async {
/*    await DBProvider.db.deleteMembershipItem(1);
    Item testItems =
    Item(
      item_id: 0,
      var_id: 0,
      var_name: duration,
      var_minitem: 1,
      var_maxitem: 1,
      var_stock: 1,
      var_mrp: -1,
      item_name: "Membership",
      item_qty: 1,
      item_price: double.parse(discountprice),
      item_memberprice: discountprice,
      item_actualprice: double.parse(price),
      item_image: Images.membershipImg,
      membership_id: int.parse(membershipid),
      mode: 1, // mode =1 for membership
    );
    await DBProvider.db.newItem(testItems);
    Provider.of<CartItems>(context, listen: false).fetchCartItems();*/

    Calculations.deleteMembershipItem();
    Product products = Product(
        itemId: 0,
        varId: 0,
        varName: duration,
        varMinItem: 1,
        varMaxItem: 1,
        varStock: 1,
        varMrp: -1,
        itemName: "Membership",
        itemQty: 1,
        itemPrice: double.parse(discountprice),
        membershipPrice: discountprice,
        itemActualprice: double.parse(price),
        itemImage: Images.membershipImg,
        membershipId: int.parse(membershipid),
        mode: 1);

    productBox.add(products);
  }

  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    queryData = MediaQuery.of(context);
    wid= queryData.size.width;
    maxwid=wid*0.90;
    bottomNavigationbar() {
      return SingleChildScrollView(
        child: Container(
          height: 60,
          color: Colors.white,
          child: Row(
            children: <Widget>[
              Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
                },
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 7.0,
                    ),
                    CircleAvatar(
                      radius: 11.0,
                      backgroundColor: Colors.transparent,
                      child: Image.asset(
                        Images.homeImg,
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text("Home",
                        style: TextStyle(
                          color: Color(0xffb1b1b1),
                          fontSize: 10.0,
                        )),
                  ],
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    CategoryScreen.routeName,
                  );
                },
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 7.0,
                    ),
                    CircleAvatar(
                      radius: 11.0,
                      backgroundColor: Colors.transparent,
                      child: Image.asset(Images.categoriesImg),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text("Categories",
                        style: TextStyle(
                            color: Color(0xffb1b1b1), fontSize: 10.0)),
                  ],
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  checkskip
                      ? Navigator.of(context).pushNamed(
                          SignupSelectionScreen.routeName,
                        )
                      : Navigator.of(context).pushNamed(WalletScreen.routeName,
                          arguments: {"type": "wallet"});
                },
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 7.0,
                    ),
                    CircleAvatar(
                      radius: 11.0,
                      backgroundColor: Colors.transparent,
                      child: Image.asset(Images.walletImg),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text("Wallet",
                        style: TextStyle(
                            color: Color(0xffb1b1b1), fontSize: 10.0)),
                  ],
                ),
              ),
              Spacer(),
              Column(
                children: <Widget>[
                  Container(
                    width: 25,
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(
                                width: 3.0,
                                color: Theme.of(context).primaryColor))),
                    child: SizedBox(
                      height: 7.0,
                    ),
                  ),
                  CircleAvatar(
                    maxRadius: 11.0,
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.transparent,
                    child: Image.asset(Images.bottomnavMembershipImg,
                        color: Theme.of(context).primaryColor),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text("Membership",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  checkskip
                      ? Navigator.of(context).pushNamed(
                          SignupSelectionScreen.routeName,
                        )
                      : Navigator.of(context).pushNamed(
                          ShoppinglistScreen.routeName,
                        );
                },
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 7.0,
                    ),
                    CircleAvatar(
                      radius: 11.0,
                      backgroundColor: Colors.transparent,
                      child: Image.asset(Images.shoppinglistsImg),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text("Shopping list",
                        style: TextStyle(
                            color: Color(0xffb1b1b1), fontSize: 10.0)),
                  ],
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar:  ResponsiveLayout.isSmallScreen(context)
          ? gradientappbarmobile()
          : null,
//        drawer: AppDrawer(),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Header(false),
          _body(),
        ],
      ),
      bottomNavigationBar: _isWeb ? SizedBox.shrink() : Padding(
        padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
        child: bottomNavigationbar(),
      ),
    );
  }
  Widget _body(){
     final membershipData = Provider.of<MembershipitemsList>(context,listen: false);
    return _checkmembership
          ?  Expanded(
                   child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                         _loading
                         ? Container(
                           height: 100,
                           child: Center(
                             child: CircularProgressIndicator(
                               valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                             ),
                            ),
                         )
                         :
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,
                            child: Column(
                              children: <Widget>[
                          SizedBox(
                            height: 50.0,
                          ),
                          Divider(
                            color: Color(0xFFC2E7F9),
                            thickness: 2,
                            endIndent: 20,
                            indent: 20,
                          ),
                          SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.star,
                                color: Color(0xFFF2BF40),
                              ),
                              SizedBox(width: 10.0),
                              Text(
                                "Plan:",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 80,
                              ),
                              Text(
                                 " " + ordertotal+_currencyFormat ,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 20.0),
                          Divider(
                            color: Color(0xFFC2E7F9),
                            thickness: 2,
                            endIndent: 20,
                            indent: 20,
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              SizedBox(width: 45.0),
                              Icon(
                                Icons.star,
                                color: Color(0xFFF2BF40),
                              ),
                              SizedBox(width: 10.0),
                              Text(
                                "Renewal and Next Payment",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(80, 5, 40, 10),
                            child: Text(
                              'Your membership will expire on ' +
                                  expirydate +
                                  '. You will be informed via email or SMS and can renew only after expiry.',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          SizedBox(height: 50),
                          RaisedButton(
                            onPressed: () {},
                            color: Color(0xFFF2BF40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'View Order Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            padding: EdgeInsets.fromLTRB(30, 15, 30, 15),
                          ),
                              ],
                   ),

                          ),
                        ),
                        /* Container(
                          margin: EdgeInsets.all(10.0),
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3.0),
                              border: Border(
                                top: BorderSide(width: 1.0, color: Colors.grey),
                                bottom:
                                    BorderSide(width: 1.0, color: Colors.grey),
                                left: BorderSide(width: 1.0, color: Colors.grey),
                                right: BorderSide(width: 1.0, color: Colors.grey),
                              )),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                      child: Text(
                                    "Order date",
                                    style: TextStyle(fontSize: 14.0),
                                  )),
                                  Expanded(
                                      child: Text(
                                    orderdate,
                                    style: TextStyle(fontSize: 14.0),
                                  )),
                                ],
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                      child: Text(
                                    "Order id",
                                    style: TextStyle(fontSize: 14.0),
                                  )),
                                  Expanded(
                                      child: Text(
                                    orderid,
                                    style: TextStyle(fontSize: 14.0),
                                  )),
                                ],
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                      child: Text(
                                    "Order total",
                                    style: TextStyle(fontSize: 14.0),
                                  )),
                                  Expanded(
                                      child: Text(
                                    _currencyFormat + ordertotal + " ( 1 item )",
                                    style: TextStyle(fontSize: 14.0),
                                  )),
                                ],
                              ),
                            ],
                          ),
                        ),*/

                        /* Row(
                          children: <Widget>[
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              "Purchase Details",
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),*/
                        /* Container(
                          margin: EdgeInsets.all(10.0),
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3.0),
                              border: Border(
                                top: BorderSide(width: 1.0, color: Colors.grey),
                                bottom:
                                    BorderSide(width: 1.0, color: Colors.grey),
                                left: BorderSide(width: 1.0, color: Colors.grey),
                                right: BorderSide(width: 1.0, color: Colors.grey),
                              )),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 50.0,
                                height: 50.0,
                                child: Image.asset(
                                  Images.membershipImg,
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      name + " (" + duration + " Months)",
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Text(
                                      "Qty: 1",
                                      style: TextStyle(fontSize: 14.0),
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              Text(
                                _currencyFormat + " " + ordertotal,
                                style: TextStyle(fontSize: 14.0),
                              ),
                            ],
                          ),
                        ),*/
                        /* Row(
                          children: <Widget>[
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              "Payment information",
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),*/
                        /* Container(
                          margin: EdgeInsets.all(10.0),
                          padding: EdgeInsets.all(10.0),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3.0),
                              border: Border(
                                top: BorderSide(width: 1.0, color: Colors.grey),
                                bottom:
                                    BorderSide(width: 1.0, color: Colors.grey),
                                left: BorderSide(width: 1.0, color: Colors.grey),
                                right: BorderSide(width: 1.0, color: Colors.grey),
                              )),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Payment Method",
                                style: TextStyle(
                                    fontSize: 14.0, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                paytype,
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Divider(),
                              SizedBox(
                                height: 5.0,
                              ),
                              Text(
                                "Billing Address",
                                style: TextStyle(
                                    fontSize: 14.0, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                address,
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ),
                        ),*/
                        SizedBox(height: 40,),
                        if (_isWeb && !ResponsiveLayout.isSmallScreen(context))
                      Footer(address: _address),
                      ],
                    ),
                  ),
              )
          : Expanded(
                child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _loading
                    ? Container(
                      height: 100,
                      child: Center(
                       child: CircularProgressIndicator(
                         valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                       ),
                       ),
                    )
                     :
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,
                        child: Column(
                          children: <Widget>[
                      Image.network(
                        membershipData.items[0].avator,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 20.0),
                      Container(
                        height: 400,
                        padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                        color: Color(0xFF006395),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                                child: Text(
                                  "Select the membership plan which suits your needs",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 24.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.0),
                            Container(
                              width: 300,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount:
                                  membershipData.typesitems.length,
                                  itemBuilder: (ctx, i) {
                                    return ValueListenableBuilder(
                                        valueListenable: Hive.box<Product>(productBoxName).listenable(),
                                        builder: (context, Box<Product> box, index) {
                                          for (int j = 0; j < membershipData.typesitems.length; j++) {
                                            if (Calculations.checkmembershipItem == 0) {
                                              membershipData.typesitems[j].text = "Select";
                                              membershipData.typesitems[j]
                                                  .backgroundcolor =
                                                  Color(0xFFF2BF40);
                                              membershipData.typesitems[j]
                                                  .textcolor =
                                                  Colors.black;
                                            } else {
                                              for (int k = 0; k < productBox.length; k++) {
                                                if (productBox.values.elementAt(k).membershipId.toString() == membershipData.typesitems[j].typesid) {
                                                  membershipData.typesitems[j].text = "Remove";
                                                  membershipData.typesitems[j].backgroundcolor = Colors.green;
                                                  membershipData.typesitems[j].textcolor = Colors.white;
                                                } else {
                                                  membershipData.typesitems[j].text = "Update";
                                                  membershipData.typesitems[j].backgroundcolor = Color(0xFFF2BF40);
                                                  membershipData.typesitems[j].textcolor = Colors.black;
                                                }
                                              }
                                            }
                                          }
                                          return GestureDetector(
                                            onTap: () {
                                              if(prefs.getString("membership") == "0" || memberMode || prefs.getString("membership") == "1") {
                                                if (membershipData.typesitems[i]
                                                    .text == "Select") {
                                                  _addtocart(
                                                    membershipData.typesitems[i].typesid,
                                                    membershipData.typesitems[i].typesduration,
                                                    membershipData.typesitems[i].typesdiscountprice,
                                                    membershipData.typesitems[i].typesprice,
                                                  );
                                                } else
                                                if (membershipData.typesitems[i].text == "Remove") {
                                                  _removefromcart();
                                                } else {
                                                  _updatetocart(
                                                    membershipData.typesitems[i].typesid,
                                                    membershipData.typesitems[i].typesduration,
                                                    membershipData.typesitems[i].typesdiscountprice,
                                                    membershipData.typesitems[i].typesprice,
                                                  );
                                                }
                                              } else {
                                                Fluttertoast.showToast(msg: "Your order with Membership is processing!", backgroundColor: Colors.black87, textColor: Colors.white);
                                              }
                                            },
                                            child: Container(
                                              width: 250,
                                              height: 50,
                                              //padding: EdgeInsets.all(10),
                                              margin:
                                              EdgeInsets.symmetric(
                                                  vertical: 10,
                                                  horizontal: 20),
                                              decoration: BoxDecoration(
                                                color: membershipData.typesitems[i].backgroundcolor,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                    width: 1.0,
                                                    color: Colors.white),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                       " " + membershipData.typesitems[i].typesdiscountprice+_currencyFormat ,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: membershipData
                                                            .typesitems[i]
                                                            .textcolor,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      membershipData.typesitems[i].typesduration + " month",
                                                      style: TextStyle(
                                                          color: membershipData.typesitems[i].textcolor,
                                                          fontSize: 18.0,
                                                          fontWeight: FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                                  }),
                            ),
                            /* new Row(
                        children: <Widget>[
                          Expanded(
                              child: SizedBox(
                                height: 220.0,
                                child: new ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: membershipData.typesitems.length,
                                  itemBuilder: (_, i) => Expanded(
                                    child: Container(
                                      width: 170.0,
                                      child: Container(
                                        margin: EdgeInsets.only(left: 10.0, right: 10.0),
                                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3.0),
                                            border: Border(
                                              top: BorderSide(width: 1.0, color: Colors.white),
                                              bottom: BorderSide(width: 1.0, color: Colors.white),
                                              left: BorderSide(width: 1.0, color: Colors.white),
                                              right: BorderSide(width: 1.0, color: Colors.white),
                                            )),
                                        child: Column(
                                          children: <Widget>[
                                            SizedBox(
                                              height: 10.0,
                                            ),
                                            Text(
                                              membershipData.typesitems[i].typesduration + " month",
                                              style: TextStyle(color: Color(0xff48b9c6), fontSize: 18.0),
                                            ),
                                            Divider(),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  _currencyFormat + " " + membershipData.typesitems[i].typesdiscountprice,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: <Widget>[
                                                  Divider(),
                                                  ValueListenableBuilder(
                                                    valueListenable: Hive.box<Product>(productBoxName).listenable(),
                                                    builder: (context, Box<Product> box, index) {
                                                      for(int j = 0; j < membershipData.typesitems.length; j++) {
                                                        if (Calculations.checkmembershipItem == 0) {
                                                          membershipData.typesitems[j].text = "Select";
                                                          membershipData.typesitems[j].backgroundcolor = Color(0xff35a2df);
                                                          membershipData.typesitems[j].textcolor = Colors.white;
                                                        } else {
                                                          for(int k = 0; k < productBox.length; k++) {
                                                            if(productBox.values.elementAt(k).membershipId.toString() == membershipData.typesitems[j].typesid) {
                                                              membershipData.typesitems[j].text = "Remove";
                                                              membershipData.typesitems[j].backgroundcolor = Colors.white;
                                                              membershipData.typesitems[j].textcolor = Color(0xff35a2df);
                                                            } else {
                                                              membershipData.typesitems[j].text = "Update";
                                                              membershipData.typesitems[j].backgroundcolor = Color(0xff35a2df);
                                                              membershipData.typesitems[j].textcolor = Colors.white;
                                                            }
                                                          }
                                                        }
                                                      }

                                                      return GestureDetector(
                                                        onTap: () {
                                                          if (membershipData.typesitems[i].text == "Select") {
                                                            _addtocart(
                                                              membershipData.typesitems[i].typesid,
                                                              membershipData.typesitems[i].typesduration,
                                                              membershipData.typesitems[i].typesdiscountprice,
                                                              membershipData.typesitems[i].typesprice,
                                                            );
                                                          } else if(membershipData.typesitems[i].text == "Remove") {
                                                            _removefromcart();
                                                          } else {
                                                            _updatetocart(
                                                              membershipData.typesitems[i].typesid,
                                                              membershipData.typesitems[i].typesduration,
                                                              membershipData.typesitems[i].typesdiscountprice,
                                                              membershipData.typesitems[i].typesprice,
                                                            );
                                                          }
                                                        },
                                                        child: Container(
                                                          width: MediaQuery.of(context).size.width,
                                                          height: 40.0,
                                                          margin: EdgeInsets.all(10.0),
                                                          decoration: BoxDecoration(color: membershipData.typesitems[i].backgroundcolor, borderRadius: BorderRadius.circular(3.0),
                                                              border: Border(
                                                                top: BorderSide(width: 1.0, color: Theme.of(context).accentColor,),
                                                                bottom: BorderSide(width: 1.0, color: Theme.of(context).accentColor,),
                                                                left: BorderSide(width: 1.0, color: Theme.of(context).accentColor,),
                                                                right: BorderSide(width: 1.0, color: Theme.of(context).accentColor,),
                                                              )),
                                                          child: Center(
                                                              child: Text(membershipData.typesitems[i].text,
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                    fontSize: 18,
                                                                    color: membershipData.typesitems[i].textcolor),
                                                              )),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                          ),
                        ],
                      ),
                      */
                          ],
                        ),
                      ),
                ],
                        ),
                      ),
                    ),
                    if (_isWeb && !ResponsiveLayout.isSmallScreen(context))
                      Footer(address: _address),
                  ],
                ),
              ),
          );
  }
  gradientappbarmobile() {
      return AppBar(
        brightness: Brightness.dark,
        toolbarHeight: 60.0,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop()),
        title: Text(
          'Membership',
        ),
        titleSpacing: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                Theme.of(context).accentColor,
                Theme.of(context).primaryColor
              ])),
        ),
         actions: <Widget>[
          Container(
          //  margin: EdgeInsets.only(top: 2.0, bottom: 2.0),
            child: ValueListenableBuilder(
              valueListenable: Hive.box<Product>(productBoxName).listenable(),
              builder: (context, Box<Product> box, index) {
                if (box.values.isEmpty)
                  return Container(

                    width: 30,
                    height: 30,
                    margin: EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Theme.of(context).buttonColor),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(CartScreen.routeName);
                      },
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        size: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  );

                int cartCount = 0;
                for (int i = 0;
                    i < Hive.box<Product>(productBoxName).length;
                    i++) {
                  cartCount = cartCount +
                      Hive.box<Product>(productBoxName)
                          .values
                          .elementAt(i)
                          .itemQty;
                }
                return Consumer<Calculations>(
                  builder: (_, cart, ch) => Badge(
                    child: ch,
                    color: Colors.green,
                    value: cartCount.toString(),
                  ),
                  child: Container(
                    margin: EdgeInsets.only(top: 6, right: 10, bottom: 10),
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Theme.of(context).buttonColor),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(CartScreen.routeName);
                      },
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        size: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      );
    }
}
