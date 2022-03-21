import 'dart:io';
import 'package:fellahi_e/screens/myorder_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/ColorCodes.dart';
import '../utils/ResponsiveLayout.dart';
import '../widgets/header.dart';
import '../widgets/footer.dart';
import '../providers/categoryitems.dart';
import '../widgets/expandable_categories.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/home_screen.dart';
import '../screens/membership_screen.dart';
import '../screens/shoppinglist_screen.dart';
import '../screens/wallet_screen.dart';
import '../screens/signup_selection_screen.dart';
import '../constants/images.dart';
import 'customer_support_screen.dart';
import '../providers/categoryitems.dart';
import '../widgets/categoryTwo.dart';
import 'myorder_screen.dart';
import 'package:flutter_translate/flutter_translate.dart';

class CategoryScreen extends StatefulWidget {
  static const routeName = '/category-screen';

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool checkskip = false;
  bool _isWeb = false;
  SharedPreferences prefs;
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
      setState(() {
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

  @override
  Widget build(BuildContext context) {

    queryData = MediaQuery.of(context);
    wid= queryData.size.width;
    maxwid=wid*0.90;

    void launchWhatsApp() async {
      String phone = /*"+212652-655363"*/prefs.getString("secondary_mobile");
      debugPrint("Whatsapp . .. . . .. . .");
      String url() {
        if (Platform.isIOS) {
          debugPrint("Whatsapp1 . .. . . .. . .");
          return "whatsapp://wa.me/$phone/?text=${Uri.parse(translate('forconvience.hello'))}";
        } else {
          return "whatsapp://send?phone=$phone&text=${Uri.parse(translate('forconvience.hello'))}";
          const url = "https://wa.me/?text=YourTextHere";

        }
      }

      if (await canLaunch(url())) {
        await launch(url());
      } else {
        throw 'Could not launch ${url()}';
      }
    }

    bottomNavigationbar() {
      return SingleChildScrollView(
        child: Container(
          height: 60,
          color: Colors.white,
          child: Row(
            children: <Widget>[

              Spacer(),
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 7.0,
                  ),
                  CircleAvatar(
                    maxRadius: 11.0,
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.transparent,
                    child: Image.asset(Images.categoriesImg,
                        color: Theme.of(context).primaryColor),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(translate('bottomnavigation.categories'),//"Category",
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
                    Text(translate('bottomnavigation.wallet'),//"Wallet",
                        style: TextStyle(
                            color: ColorCodes.grey, fontSize: 10.0)),
                  ],
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(true);
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
                    Text(translate('bottomnavigation.home'),//"Home",
                        style: TextStyle(
                            color: ColorCodes.grey, fontSize: 10.0)),
                  ],
                ),
              ),
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
              Spacer(),
              GestureDetector(
                onTap: () {
                  checkskip
                      ? Navigator.of(context).pushNamed(
                    SignupSelectionScreen.routeName,
                  )
                      : Navigator.of(context).popAndPushNamed(MyorderScreen.routeName
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
                    Text(translate('bottomnavigation.myorders'),//"My Orders",
                        style: TextStyle(
                            color: ColorCodes.grey, fontSize: 10.0)),
                  ],
                ),
              ),
              Spacer(
                flex: 1,
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  checkskip
                      ? Navigator.of(context).pushNamed(
                    SignupSelectionScreen.routeName,
                  )
                      : launchWhatsApp(); //FlutterOpenWhatsapp.sendSingleMessage("+212652-655363", "Hello");
                  /*Navigator.of(context)
                                .pushNamed(
                                CustomerSupportScreen.routeName, arguments: {
                              'name': name,
                              'email': email,
                              'photourl': photourl,
                              'phone': phone,
                            });*/
                },
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 7.0,
                    ),
                    CircleAvatar(
                      radius: 11.0,
                      backgroundColor: Colors.transparent,
                      child: Image.asset(Images.whatsapp),
                    ),
                    // Icon(Icons.chat, color: Colors.black12,),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(translate('bottomnavigation.chat'),//"Chat",
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
        ),
      );
    }

    Widget _appBar() {
      return AppBar(
        toolbarHeight: 60.0,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Text(
          translate('forconvience.allcategories'),// "All Categories",
          style: TextStyle(color: ColorCodes.backbutton),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,size: 20,color: ColorCodes.backbutton,),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    ColorCodes.whiteColor,
                    ColorCodes.whiteColor,
              ])),
        ),
      );
    }

    Widget _webbody() {
      final categoriesData = Provider.of<CategoriesItemsList>(context,listen: false);
      return Column(
        children: <Widget>[
          if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Header(false),
          if (_isWeb && !ResponsiveLayout.isSmallScreen(context))
            Container(
                padding: EdgeInsets.all(10),
                color: ColorCodes.lightGreyWebColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ' All Categories',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Text("Filter",
                            style: TextStyle(
                                color: ColorCodes.mediumBlackColor,
                                fontSize: 14.0)),
                        Container(
                            height: 15.0,
                            child: VerticalDivider(
                                color: ColorCodes.dividerColor)),
                        Text("Sort",
                            style: TextStyle(
                                color: ColorCodes.mediumBlackColor,
                                fontSize: 14.0)),
                        SizedBox(
                          width: 10.0,
                        ),
                        Image.asset(
                          Images.sortImg,
                          color: ColorCodes.mediumBlackColor,
                          width: 22,
                          height: 16.0,
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ],
                )),
          if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Divider(),
          Expanded(
            child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,
                      child: Column(
                        children: [
                      if (categoriesData.items.length > 0)
                        SizedBox(
                          height: 10,
                        ),
                      if (categoriesData.items.length > 0)  ExpansionCategory(),
                      SizedBox(
                        height: 20,
                      ),

              ],
            ),
                    ),
                    if (_isWeb && !ResponsiveLayout.isSmallScreen(context))
                      Footer(
                        address: "nxdz",
                      ),
                  ],
                )
            ),
          ),
        ],
      );
    }

     return ResponsiveLayout.isSmallScreen(context)
         ? Scaffold(
       backgroundColor: ColorCodes.whiteColor,
       appBar: ResponsiveLayout.isSmallScreen(context) ? _appBar() : SizedBox.shrink(),
       body: _webbody(),
       bottomNavigationBar:
       _isWeb ? SizedBox.shrink() : Container(
         color: Colors.white,
         child: Padding(
             padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
             child: bottomNavigationbar()
         ),
       ),
     )
         : Scaffold(
       body: _webbody(),
     );
  }
}


