import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/footer.dart';
import '../constants/ColorCodes.dart';
import '../widgets/header.dart';
import '../utils/ResponsiveLayout.dart';
import '../providers/myorderitems.dart';
import '../screens/home_screen.dart';
import '../widgets/myorder_display.dart';
import '../constants/images.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/ColorCodes.dart';
import 'home_screen.dart';
import '../screens/wallet_screen.dart';
import '../screens/signup_selection_screen.dart';
import 'customer_support_screen.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../screens/category_screen.dart';


class MyorderScreen extends StatefulWidget {
  static const routeName = '/myorder-screen';
  @override
  _MyorderScreenState createState() => _MyorderScreenState();
}

class _MyorderScreenState extends State<MyorderScreen> {
  var totalamount;
  var totlamount;
  var _isLoading = true;
  var _checkorders = false;
  var _isWeb = false;
  bool checkskip = false;
  SharedPreferences prefs;
  var _address = "";
  MediaQueryData queryData;
  double wid;
  double maxwid;
  var _currencyFormat = "";
  var /*name = "",*/ email = "", photourl = "", phone = "",mobile="",countrycode="";
  bool iphonex = false;

  @override
  void initState() {

    Future.delayed(Duration.zero, () {
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
      Provider.of<MyorderList>(context, listen: false).Getorders().then((_) async {
        prefs = await SharedPreferences.getInstance();
        _address = prefs.getString("restaurant_address");
        setState(() {
          _currencyFormat = prefs.getString("currency_format");
          _isLoading = false;


        });

      });
      /*setState(() {
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
      });*/
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    wid= queryData.size.width;
    maxwid=wid*0.70;
    return WillPopScope(
      onWillPop: () {
        // this is the block you need
       // Navigator.of(context).pop();


        (_isWeb && !ResponsiveLayout.isSmallScreen(context)) ?
       // SchedulerBinding.instance.addPostFrameCallback((_) {
          /* Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home-screen', (Route<dynamic> route) => false);*/
          // Navigator.of(context).pop();
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/home-screen', (Route<dynamic> route) => false)
       // })
            :

        Navigator.of(context).popUntil(ModalRoute.withName(
          HomeScreen.routeName,
        ));
       /* Navigator.pushNamedAndRemoveUntil(
            context, HomeScreen.routeName, (route) => false);*/
        return Future.value(false);
      },
      child: Scaffold(
        appBar: ResponsiveLayout.isSmallScreen(context)
            ? gradientappbarmobile()
            : null,
        backgroundColor: ColorCodes.whiteColor,
        body: Column(
          children: <Widget>[
            if(_isWeb && !ResponsiveLayout.isSmallScreen(context))
              Header(false),
            _isLoading ?
            Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                ),
              ),
            ):
            _body(),

          ],
        ),
        bottomNavigationBar:
        _isWeb ? SizedBox.shrink() : Container(
          color: Colors.white,
          child: Padding(
              padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
              child: bottomNavigationbar()
          ),
        ),
      ),
    );
  }

  _body() {
    final myorderData = Provider.of<MyorderList>(context, listen: false);
    if (myorderData.items.length <= 0) {
      _checkorders = false;
    } else {
      _checkorders = true;
    }
    return _checkorders
        ? Expanded(
      child:


      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (myorderData.items.length > 0)
              _isLoading
                  ? Center(
                    child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                    ),
                  )
                  :Container(
                  constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,

                child: SizedBox(

                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: myorderData.items.length,
                    itemBuilder: (_, i) => Column(
                      children: [
                        MyorderDisplay(
                          myorderData.items[i].id,
                          myorderData.items[i].oid,
                          myorderData.items[i].itemid,
                          myorderData.items[i].itemname,
                          myorderData.items[i].varname,
                          myorderData.items[i].price,
                          myorderData.items[i].qty,
                          myorderData.items[i].itemoactualamount,
                          myorderData.items[i].discount,
                          myorderData.items[i].subtotal,
                          myorderData.items[i].menuid,
                          myorderData.items[i].odeltime,
                          myorderData.items[i].itemImage,
                          myorderData.items[i].odate,
                          myorderData.items[i].itemPrice,
                          myorderData.items[i].itemQuantity,
                          myorderData.items[i].itemLeftCount,
                          myorderData.items[i].odelivery,
                          myorderData.items[i].isdeltime,
                          myorderData.items[i].ostatustext,
                          myorderData.items[i].ototal,
                          myorderData.items[i].orderType,
                          myorderData.items[i].ostatus,
                          myorderData.items[i].itemodelcharge,
                          myorderData.items[i].loyalty,
                          myorderData.items[i].wallet,
                          myorderData.items[i].totalDiscount,
                          _currencyFormat,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            SizedBox(
              height: 40.0,
            ),
            if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Footer(address: _address),
          ],
        ),
      ),
    )
        : Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
        /*  _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                ),
              )
              :*/
          EmptyOrder(),
          if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Footer(address: _address),
        ],
      ),
    );
  }

  Widget EmptyOrder() {
    return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Image.asset(Images.myorderImg),
          Text(
            translate('forconvience.You have no past orders'),//"You have no past orders",
            style: TextStyle(fontSize: 16.0),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            translate('forconvience.get started'), //"Let's get you started",
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(
            height: 20.0,
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).popUntil(ModalRoute.withName(
                HomeScreen.routeName,
              ));
            },
            child: Container(
              width: 120.0,
              height: 40.0,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(3.0),
                  border: Border(
                    top: BorderSide(
                        width: 1.0, color: Theme.of(context).primaryColor),
                    bottom: BorderSide(
                        width: 1.0, color: Theme.of(context).primaryColor),
                    left: BorderSide(
                        width: 1.0, color: Theme.of(context).primaryColor),
                    right: BorderSide(
                      width: 1.0,
                      color: Theme.of(context).primaryColor,
                    ),
                  )),
              child: Center(
                child: Text(
                  translate('forconvience.START SHOPPING'),//'Start Shopping',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void launchWhatsApp() async {
    String phone = /*"+212652-655363"*/prefs.getString("secondary_mobile");
    String url() {
      if (Platform.isIOS) {
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
                    maxRadius: 11.0,
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.transparent,
                    child: Image.asset(Images.categoriesImg,
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(translate('bottomnavigation.categories'),//"Category",
                      style: TextStyle(
                          color: ColorCodes.grey,
                          fontSize: 10.0,
                         )),
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
                  Text(
                      translate('bottomnavigation.wallet'),
                    //"Wallet",
                      style: TextStyle(
                          color: ColorCodes.grey, fontSize: 10.0)),
                ],
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                //Navigator.of(context).pop(true);
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home-screen', (Route<dynamic> route) => false);
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
                  Text(
                      translate('bottomnavigation.home'),//"Home",
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
            /*GestureDetector(
              onTap: () {
                checkskip
                    ? Navigator.of(context).pushNamed(
                  SignupSelectionScreen.routeName,
                )
                    : Navigator.of(context).popAndPushNamed(MyorderScreen.routeName
                );
              },
              child: */

            Column(
              children: <Widget>[
                SizedBox(
                  height: 7.0,
                ),
                CircleAvatar(
                  radius: 11.0,
                  backgroundColor: Colors.transparent,
                  child: Image.asset(Images.shoppinglistsImg,
                      color: Theme.of(context).primaryColor),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                    translate('bottomnavigation.myorders'),//"My Orders",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 10.0)),
              ],
            ),
            // ),
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
                    : launchWhatsApp();//FlutterOpenWhatsapp.sendSingleMessage("+212652-655363", "Hello");
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
  gradientappbarmobile() {
    return

      AppBar(
        automaticallyImplyLeading: false,
        elevation: 1,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded,size: 18, color: ColorCodes.backbutton,),
            onPressed: () {
              (_isWeb && !ResponsiveLayout.isSmallScreen(context)) ?
             // SchedulerBinding.instance.addPostFrameCallback((_) {
                /* Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home-screen', (Route<dynamic> route) => false);*/
                // Navigator.of(context).pop();
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home-screen', (Route<dynamic> route) => false)
              //})
                  :
              SchedulerBinding.instance.addPostFrameCallback((_) {
               /* Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home-screen', (Route<dynamic> route) => false);*/
               // Navigator.of(context).pop();
                Navigator.of(context).popUntil(ModalRoute.withName(
                  HomeScreen.routeName,
                ));
              });
            }),
        titleSpacing: 0,
        title: Text(
          translate('bottomnavigation.myorders'),// "My Orders",
          style: TextStyle(fontSize:18,color: ColorCodes.backbutton,fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    ColorCodes.whiteColor,
                    ColorCodes.whiteColor,
                  ])),
        ),
      );
  }
}
