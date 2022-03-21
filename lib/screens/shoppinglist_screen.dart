import 'dart:io';

import 'package:fellahi_e/constants/ColorCodes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import '../utils/ResponsiveLayout.dart';
import '../widgets/app_drawer.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../providers/branditems.dart';
import '../screens/shoppinglistitems_screen.dart';
import '../screens/category_screen.dart';
import '../screens/home_screen.dart';
import '../screens/membership_screen.dart';
import '../screens/wallet_screen.dart';
import '../screens/signup_selection_screen.dart';
import '../constants/images.dart';
import 'customer_support_screen.dart';

enum FilterOptions {
  Remove,
}

class ShoppinglistScreen extends StatefulWidget {
  static const routeName = '/shoppinglist-screen';
  @override
  _ShoppinglistScreenState createState() => _ShoppinglistScreenState();

}

class _ShoppinglistScreenState extends State<ShoppinglistScreen> {
  bool _isshoplistdata = false;
  bool checkskip = false;
  bool _isWeb = false;
  bool _isLoading = true;
  SharedPreferences prefs;
   var _address = "";
  MediaQueryData queryData;
  double wid;
  double maxwid;
  var name = "", email = "", photourl = "", phone = "",mobile="",countrycode="";
  bool iphonex = false;

  @override
  void initState() {
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
      setState(() {
        _isLoading=false;
        if (prefs.getString('FirstName') != null) {
          if (prefs.getString('LastName') != null) {
            name = prefs.getString('FirstName') +
                " " +
                prefs.getString('LastName');
          } else {
            name = prefs.getString('FirstName');
          }
        } else {
          name = "";
        }

        if (prefs.getString('Email') != null) {
          email = prefs.getString('Email');
        } else {
          email = "";
        }

        if (mobile != null) {
          phone = mobile;//prefs.getString('mobile');
        } else {
          phone = "";
        }
        if (prefs.getString('photoUrl') != null) {
          photourl = prefs.getString('photoUrl');
        } else {
          photourl = "";
        }

        if (prefs.getString('skip') == "yes") {
          checkskip = true;
        } else {
          checkskip = false;
        }
      });
    });
    super.initState();
  }

  void removelist(String listid) {
    Provider.of<BrandItemsList>(context,listen: false).removeShoppinglist(listid).then((_) {
      Provider.of<BrandItemsList>(context,listen: false).fetchShoppinglist().then((_) {
        Navigator.of(context).pop();
      });
    });
  }

  _dialogforRemoving(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                  height: 100.0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                      ),
                      SizedBox(
                        width: 40.0,
                      ),
                      Text("Removing List..."),
                    ],
                  )),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: ResponsiveLayout.isSmallScreen(context) ?
      gradientappbarmobile() : null,
      backgroundColor: Colors.white,//Theme.of(context).backgroundColor,
      body:  Column(
          children: <Widget>[
            if(_isWeb && !ResponsiveLayout.isSmallScreen(context))
              Header(false),
            _body(),
          ]
      ),
      bottomNavigationBar: _isWeb ? SizedBox.shrink() : Padding(
        padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
        child: bottomNavigationbar(),
      ),
    );
  }


  bottomNavigationbar() {
    return SingleChildScrollView(
      child: Container(
        height: 60,
        color: Colors.white,
        child:Column(
          children: [
            Container(
              height: 50,
              //width: 200,
              margin: EdgeInsets.only(left: 80, right: 80),
              child: RaisedButton(
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'START SHOPPING',
                      style: TextStyle(
                        color: Color(0xffFFFFFF),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).popAndPushNamed(
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
                      Text("Category",
                          style: TextStyle(
                              color: ColorCodes.grey, fontSize: 10.0)),
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
                        : Navigator.of(context).popAndPushNamed(
                        WalletScreen.routeName,
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
                              color: ColorCodes.grey, fontSize: 10.0)),
                    ],
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(
                      true
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
                        child: Image.asset(Images.homeImg),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text("Home",
                          style: TextStyle(
                              color: ColorCodes.grey, fontSize: 10.0)),
                    ],
                  ),
                ),
                Spacer(),
                /* Spacer(),
                 GestureDetector(
                    onTap: () {
                      checkskip
                          ? Navigator.of(context).pushNamed(
                        SignupSelectionScreen.routeName,
                      )
                          : Navigator.of(context).pushNamed(
                        MembershipScreen.routeName,
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
                          child: Image.asset(
                            Images.bottomnavMembershipImg,
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text("Membership",
                            style: TextStyle(
                                color: ColorCodes.grey, fontSize: 10.0)),
                      ],
                    ),
                  ),
                  Spacer(flex: 1),*/
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: 7.0,
                    ),
                    CircleAvatar(
                      maxRadius: 11.0,
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.transparent,
                      child: Image.asset(Images.shoppinglistsImg,
                          color: Theme.of(context).primaryColor),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text("My Order",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                Spacer(
                  flex: 1,
                ),
                GestureDetector(
                  onTap: () {
                    checkskip
                        ? Navigator.of(context).pushNamed(
                      SignupSelectionScreen.routeName,
                    )
                        : Navigator.of(context)
                        .popAndPushNamed(CustomerSupportScreen.routeName, arguments: {
                      'name': name,
                      'email': email,
                      'photourl': photourl,
                      'phone': phone,
                    });
                  },
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 7.0,
                      ),
                      /*CircleAvatar(
                          radius: 11.0,
                          backgroundColor: Colors.transparent,
                          child: Image.asset(Images.shoppinglistsImg),
                        ),*/
                      Icon(Icons.chat,color: Colors.black12,),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text("Chat",
                          style: TextStyle(
                              color: ColorCodes.grey, fontSize: 10.0)),
                    ],
                  ),
                ),
                Spacer(
                  flex: 1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _body(){
    queryData = MediaQuery.of(context);
    wid= queryData.size.width;
    maxwid=wid*0.90;
    final shoplistData = Provider.of<BrandItemsList>(context, listen: false);
    if (shoplistData.itemsshoplist.length <= 0) {
      _isshoplistdata = false;
    } else {
      _isshoplistdata = true;
    }
    return  Expanded(
      child: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
        ),
      ) :
       SingleChildScrollView(
            child: Column(
                children: <Widget>[
                  _isshoplistdata ?
                  SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 20.0,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,

                            child: new ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: shoplistData.itemsshoplist.length,
                              itemBuilder: (_, i) =>
                                  MouseRegion(
                                   cursor: SystemMouseCursors.click,
                                     child: GestureDetector(
                                      onTap: () {
                                        if (int.parse(shoplistData.itemsshoplist[i].totalitemcount) <= 0) {
                                          Fluttertoast.showToast(
                                              msg: "No items found!",
                                              backgroundColor: Colors.black87,
                                              textColor: Colors.white);
                                        } else {
                                          Navigator.of(context).popAndPushNamed(
                                              ShoppinglistitemsScreen.routeName,
                                              arguments: {
                                                'shoppinglistid':
                                                shoplistData.itemsshoplist[i].listid,
                                                'shoppinglistname':
                                                shoplistData.itemsshoplist[i].listname,
                                              });
                                        }
                            },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            left: 10.0, bottom: 10.0, right: 10.0),
                                        padding: EdgeInsets.all(10.0),
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width,
                                        height: 80.0,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(3.0),
                                        ),
                                        child: Row(
                                          children: [
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(shoplistData.itemsshoplist[i].listname,
                                                    style: TextStyle(fontSize: 18.0)),
                                                Text(
                                                    shoplistData
                                                        .itemsshoplist[i].totalitemcount +
                                                        " Items",
                                                    style: TextStyle(fontSize: 12.0)),
                                              ],
                                            ),
                                            Spacer(),
                                            PopupMenuButton(
                                              onSelected: (FilterOptions selectedValue) {
                                                _dialogforRemoving(context);
                                                removelist(
                                                    shoplistData.itemsshoplist[i].listid);
                                              },
                                              icon: Icon(
                                                Icons.more_vert,
                                              ),
                                              itemBuilder: (_) =>
                                              [
                                                PopupMenuItem(
                                                  child: Text('Remove'),
                                                  value: FilterOptions.Remove,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      :
                  (MediaQuery.of(context).size.width <= 600) ?
                  Container(
                    constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,

                    child: Column(
                  children: <Widget>[
                    Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.55,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            Images.emptyShoppingImg,
                            width: 159,
                            height: 157,
                          ),
                          Text(
                            'Your shopping list is empty',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Color(0xff616060),
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 10)),
                          Text(
                            'Add items to continue shopping',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Color(0xff616060),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      //width: 200,
                      margin: EdgeInsets.only(left: 80, right: 80),
                      child: RaisedButton(
                       color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'START SHOPPING',
                              style: TextStyle(
                                color: Color(0xffFFFFFF),
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                    ),
                  )
                  : Container(
                    constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.40,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                Images.emptyShoppingImg,
                                width: 159,
                                height: 157,
                              ),
                              Text(
                                'Your shopping list is empty',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Color(0xff616060),
                                ),
                              ),
                              Padding(padding: EdgeInsets.only(top: 10)),
                              Text(
                                'Add items to continue shopping',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: Color(0xff616060),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 300,
                          height: 35,
                          margin: EdgeInsets.only(left: 80, right: 80),
                          child: RaisedButton(
                            color: Color(0xff2966A2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'START SHOPPING',
                                  style: TextStyle(
                                    color: Color(0xffFFFFFF),
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Footer(address:  _address),
                ]
            )
        )
    );
  }

  _buildBottomNavigationBar() {
    queryData = MediaQuery.of(context);
    wid= queryData.size.width;
    maxwid=wid*0.60;
    return SingleChildScrollView(
      child: Container(
        width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.20:MediaQuery.of(context).size.width,
        color: Theme.of(context).primaryColor,
        height: 50.0,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
              onTap: () {
               // Navigator.of(context).pushReplacementNamed(MyorderScreen.routeName);
              },
              child: Align(
                  alignment: Alignment.center,
                  child: Text("START SHOPPING", style: TextStyle(color: ColorCodes.whiteColor,fontWeight: FontWeight.bold),))),
        ),
      ),
    );
  }


  gradientappbarmobile() {
    return  AppBar(
      brightness: Brightness.dark,
      toolbarHeight: 60.0,
      elevation: 1,
      automaticallyImplyLeading: false,
      leading: IconButton(icon: Icon(Icons.arrow_back, color: ColorCodes.blackColor),onPressed: ()=>Navigator.of(context).pop()),
      title: Text('Shopping Lists',
      ),
      titleSpacing: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                 ColorCodes.whiteColor,
                  ColorCodes.whiteColor

                ]
            )
        ),
      ),
    );
  }


  gradientWebbar() {
    if(_isWeb && !ResponsiveLayout.isSmallScreen(context))
      return  AppBar(
        toolbarHeight: 80.0,
        elevation: 0,
        brightness: Brightness.dark,
        automaticallyImplyLeading: false,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white),onPressed: ()=>Navigator.of(context).pop()),
        title: Text('Shopping Lists',
                ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Theme
                        .of(context)
                        .accentColor,
                    Theme
                        .of(context)
                        .primaryColor
                  ]
              )
          ),
        ),
      );
  }
}

