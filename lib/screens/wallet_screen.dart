import 'package:fellahi_e/constants/ColorCodes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../screens/myorder_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/ResponsiveLayout.dart';
import '../widgets/header.dart';
import '../widgets/footer.dart';
import '../providers/branditems.dart';
import '../screens/category_screen.dart';
import '../screens/home_screen.dart';
import '../screens/membership_screen.dart';
import '../screens/shoppinglist_screen.dart';
import '../screens/signup_selection_screen.dart';
import '../constants/ColorCodes.dart';
import '../constants/images.dart';
import 'customer_support_screen.dart';
import 'package:flutter_translate/flutter_translate.dart';

class WalletScreen extends StatefulWidget {
  static const routeName = '/wallet-screen';
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  SharedPreferences prefs;
  var currency_format = "";
  bool _isloading = true;
  bool _iswalletbalance = true;
  bool _iswalletlogs = true;
  var walletbalance = "0";
  bool notransaction = true;
  bool checkskip = false;
  bool _isWeb =false;
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
      final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
      final type = routeArgs['type'];
      prefs = await SharedPreferences.getInstance();
      _address = prefs.getString("restaurant_address");
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
        currency_format = prefs.getString("currency_format");
      });

      Provider.of<BrandItemsList>(context,listen: false).fetchWalletBalance().then((_) {
        setState(() {
          _iswalletbalance = false;
          if (type == "wallet")
            walletbalance = prefs.getString("wallet_balance");
          else
            walletbalance = prefs.getString("loyalty_balance");
        });
      });
      Provider.of<BrandItemsList>(context,listen: false).fetchWalletLogs(type).then((_) {
        setState(() {
          _iswalletlogs = false;
        });
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    final routeArgs =
        ModalRoute.of(context).settings.arguments as Map<String, String>;
    final type = routeArgs['type'];

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
          //color: Color(0xFFfd8100),
          child:Row(
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
                    Text(translate('bottomnavigation.categories'),//"Category",
                        style: TextStyle(
                            color: ColorCodes.grey, fontSize: 10.0)),
                  ],
                ),
              ),
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
                    child: Image.asset(Images.walletImg,
                        color: Theme.of(context).primaryColor),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(type == "wallet"? translate('bottomnavigation.wallet'):translate('appdrawer.loyalty'),//"Wallet",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold)),
                ],
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
              GestureDetector(
                onTap: () {
                  checkskip
                      ? Navigator.of(context).pushNamed(
                    SignupSelectionScreen.routeName,
                  )
                      : Navigator.of(context).popAndPushNamed(
                    MyorderScreen.routeName,
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

    if (!_iswalletbalance && !_iswalletlogs) {
      _isloading = false;
    }
    final walletData = Provider.of<BrandItemsList>(context,listen: false);
    if (walletData.itemswallet.length <= 0) {
      notransaction = true;
    } else {
      notransaction = false;
    }
    gradientappbarmobile() {
      return  AppBar(
        brightness: Brightness.dark,
        toolbarHeight: 60.0,
        elevation: 1,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded,size: 20, color: ColorCodes.backbutton),
            onPressed: () {
              Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
              return Future.value(false);
            }
        ),
        titleSpacing: 0,
        title: Text(
           type == "wallet"? translate('bottomnavigation.wallet'):translate('appdrawer.loyalty'),
          //type,
           style: TextStyle(color: ColorCodes.backbutton),),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                  ColorCodes.whiteColor,
                    ColorCodes.whiteColor,
                  ]
              )
          ),
        ),
      );
    }
    Widget _bodyMobile(){
      return _isloading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
        ),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 20.0),
            color: Colors.white,
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 50.0, bottom: 50.0),
                ),
                SizedBox(
                  width: 30.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: <Widget>[
                    (type == "wallet")
                        ? Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                     // crossAxisAlignment: CrossAxisAlignment.center,
                          //mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                       " " + walletbalance+currency_format ,
                      style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 35.0,
                              fontWeight: FontWeight.bold),
                    ),
                            (type == "wallet")
                                ? Padding(
                                  padding: const EdgeInsets.symmetric(horizontal:8.0,),
                                  child: Text(
                              translate('forconvience.walletbalance'),

                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 21.0,
                                  color: Color(0xff646464),
                              ),
                            ),
                                )
                                : Padding(
                                  padding: const EdgeInsets.symmetric(horizontal:8.0),
                                  child: Text(
                              "Available Points",
                              style: TextStyle(
                                  fontSize: 21.0,
                                  color: Color(0xff646464),
                              ),
                            ),
                                )
                          ],
                        )
                        : Row(
                      children: <Widget>[
                        Text(
                          double.parse(walletbalance).toStringAsFixed(2),
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Image.asset(
                          Images.coinImg,
                          width: 21.0,
                          height: 21.0,
                          alignment: Alignment.center,
                        ),



                      ],
                    ),
                    SizedBox(
                      height: 5.0,
                    ),

                  ],
                ),
                SizedBox(
                  height: 100.0,
                ),
                Divider(),
              ],
            ),
          ),
          notransaction
              ? Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Align(
                  child: Image.asset(
                    (type == 'wallet')
                        ? Images.walletTransImg
                        : Images.loyaltyImg,
                    width: 232.0,
                    height: 168.0,
                    alignment: Alignment.center,
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  translate('forconvience.notransaction'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 19.0,
                      color: Color(0xff616060),
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
              : Expanded(
            child: new ListView.builder(
              itemCount: walletData.itemswallet.length,
              itemBuilder: (_, i) => Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 10.0,
                      ),
                      Image.asset(
                        walletData.itemswallet[i].img,
                        fit: BoxFit.fill,
                        width: 40.0,
                        height: 40.0,
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            walletData.itemswallet[i].title,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            walletData.itemswallet[i].time,
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12.0),
                          ),
                        ],
                      ),
                      Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            walletData.itemswallet[i].date,
                            style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            walletData.itemswallet[i].amount,
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          (type == "wallet")
                              ? Text(
                            translate('forconvience.Total Balance')+": " //"Total Balance: "  +
                               + " " +
                                walletData.itemswallet[i]
                                    .closingbalance+
                            currency_format,
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12.0),
                          )
                              : Text(
                            "Total Points: " +
                                walletData.itemswallet[i]
                                    .closingbalance,
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12.0),
                          )
                        ],
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 60.0,
                        top: 10.0,
                        right: 10.0,
                        bottom: 10.0),
                    child: Text(
                      walletData.itemswallet[i].note,
                      style: TextStyle(
                          color: Colors.black54, fontSize: 12.0),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 60.0,
                        top: 10.0,
                        right: 10.0,
                        bottom: 10.0),
                    child: Divider(),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
   Widget  _bodyWeb(){
     queryData = MediaQuery.of(context);
     wid= queryData.size.width;
     maxwid=wid*0.90;
      return  Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _isloading
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                   children: <Widget>[
                     SizedBox(height: 15,),
                    Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      color: Colors.white,
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 50.0, bottom: 50.0),
                          ),
                          SizedBox(
                            width: 30.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              (type == "wallet")
                                  ? Text(
                                " " + walletbalance+ currency_format ,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 35.0,
                                    fontWeight: FontWeight.bold),
                              )
                                  : Row(
                                children: <Widget>[
                                  Text(
                                    walletbalance,
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 25.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  Image.asset(
                                    Images.coinImg,
                                    width: 21.0,
                                    height: 21.0,
                                    alignment: Alignment.center,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              (type == "wallet")
                                  ? Text(
                                translate('forconvience.walletbalance'),
                                style: TextStyle(
                                  fontSize: 21.0,
                                  color: Color(0xff646464),
                                ),
                              )
                                  : Text(
                                "Available Points",
                                style: TextStyle(
                                  fontSize: 21.0,
                                  color: Color(0xff646464),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 100.0,
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                    notransaction
                        ? Expanded(

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Align(
                              child: Image.asset(
                                (type == 'wallet')
                                    ? Images.walletTransImg
                                    : Images.loyaltyImg,
                                width: 232.0,
                                height: 168.0,
                                alignment: Alignment.center,
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              translate('forconvience.notransaction'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 19.0,
                                  color: Color(0xff616060),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )

                        : new ListView.builder(
                          itemCount: walletData.itemswallet.length,
                          shrinkWrap: true,
                          itemBuilder: (_, i) => Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: <Widget>[
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Image.asset(
                                    walletData.itemswallet[i].img,
                                    fit: BoxFit.fill,
                                    width: 40.0,
                                    height: 40.0,
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        walletData.itemswallet[i].title,
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Text(
                                        walletData.itemswallet[i].time,
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12.0),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        walletData.itemswallet[i].date,
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.0),
                                      ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Text(
                                        walletData.itemswallet[i].amount,
                                      ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      (type == "wallet")
                                          ? Text(
                                        translate('forconvience.Total Balance')+": "  //"Total Balance: "  +
                                            +" " +
                                            walletData.itemswallet[i]
                                                .closingbalance+
                                        currency_format,
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12.0),
                                      )
                                          : Text(
                                        "Total Points: " +
                                            walletData.itemswallet[i]
                                                .closingbalance,
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12.0),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    left: 60.0,
                                    top: 10.0,
                                    right: 10.0,
                                    bottom: 10.0),
                                child: Text(
                                  walletData.itemswallet[i].note,
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 12.0),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    left: 60.0,
                                    top: 10.0,
                                    right: 10.0,
                                    bottom: 10.0),
                                child: Divider(),
                              ),
                            ],
                          ),
                        ),
                        ],
                     ),
                  ),
                ),
                SizedBox(height: 20,),
                if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Footer(address: _address),
              ],
            ),
          ),
        );
    }
    return new Scaffold(
        appBar: ResponsiveLayout.isSmallScreen(context) ?
          gradientappbarmobile() : null,
    backgroundColor: Colors.white,/*Theme
        .of(context)
        .backgroundColor*/
                  body: Column(
                      children: <Widget>[
                     if(_isWeb && !ResponsiveLayout.isSmallScreen(context))
                        Header(false),
                       _isWeb? _bodyWeb():Flexible(child: _bodyMobile()),
    ],
    ),
      bottomNavigationBar:  _isWeb ? SizedBox.shrink() : Container(
        color: Colors.white,
        child: Padding(
            padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
            child: bottomNavigationbar()
        ),
      ),
    );
  }
}
