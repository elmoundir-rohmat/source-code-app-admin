import 'dart:io';
import 'package:fellahi_e/screens/refer_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/images.dart';
import '../constants/ColorCodes.dart';
import '../screens/category_screen.dart';
import '../screens/home_screen.dart';
import '../screens/wallet_screen.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:launch_review/launch_review.dart';
import "package:http/http.dart" as http;
import 'package:flutter_translate/flutter_translate.dart';
import '../screens/edit_screen.dart';
import '../constants/IConstants.dart';
import '../screens/myorder_screen.dart';
import '../screens/signup_selection_screen.dart';
import '../screens/about_screen.dart';
import '../screens/membership_screen.dart';
import '../screens/addressbook_screen.dart';
import '../screens/privacy_screen.dart';
import '../screens/help_screen.dart';
import '../screens/shoppinglist_screen.dart';
import '../screens/customer_support_screen.dart';
import '../constants/images.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  var name = "", email = "", photourl = "", phone = "",mobile="",countrycode="";
  bool checkskip = false;
  bool _isIOS = false;

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
//      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  @override
  void initState() {
    _getPrefs();
    try {
      if (Platform.isIOS) {
        setState(() {
          _isIOS = true;
        });
      } else {
        setState(() {
          _isIOS = false;
        });
      }
    } catch (e) {
      setState(() {
        _isIOS = false;
      });
    }

    Future.delayed(Duration.zero, () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getString('FirstName') != null) {
        if (prefs.getString('LastName') != null) {
          name = prefs.getString('FirstName') +
              " " +
              prefs.getString('LastName');
        } else {
          name = prefs.getString('FirstName');
        }
        debugPrint('Initial state name : '+name);
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
        debugPrint('checkskip off setstate ? : '+checkskip.toString());
      } else {
        checkskip = false;
      }

      setState(() {
        debugPrint('On App Drawer::');

        if (prefs.getString('FirstName') != null) {
          if (prefs.getString('LastName') != null) {
            name = prefs.getString('FirstName') +
                " " +
                prefs.getString('LastName');
          } else {
            name = prefs.getString('FirstName');
          }
          debugPrint('Initial state name : '+name);
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
          debugPrint('checkskip setstate ? : '+checkskip.toString());
        } else {
          checkskip = false;
        }
        debugPrint('checkskip ? : '+ prefs.getString('skip') );
      });
    });
    debugPrint('checkskip ? : '+checkskip.toString());
    //initPlatformState();
    super.initState();
  }



  /*Future<void> initPlatformState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String firstname = prefs.getString("FirstName");
    String lastname = prefs.getString("LastName");
    String email = prefs.getString("Email");
    String countrycode = prefs.getString("country_code");
    String phone = prefs.getString("mobile");

    var response = await FlutterFreshchat.init(
      appID: "80f986ff-2694-4894-b0c5-5daa836fef5c",
      appKey: "b1f41ae0-f004-43c2-a0a1-79cb4e03658a",
      */ /*appID: "457bd17f-5f76-4fa7-9a6a-081ab1a2eb77",
      appKey: "cc0dd1c4-25b0-4b8c-8d32-e1c360b7f469",*/
  /*
      cameraEnabled: true,
      gallerySelectionEnabled: false,
      teamMemberInfoVisible: false,
      responseExpectationEnabled: false,
      showNotificationBanner: true,
    );
    FreshchatUser user = FreshchatUser.initail();
    user.email = email;
    user.firstName = firstname;
    user.lastName = lastname;
    user.phoneCountryCode = countrycode;
    user.phone = phone;

    await FlutterFreshchat.updateUserInfo(user: user);
    // Custom properties can be set by creating a Map<String, String>
    Map<String, String> customProperties = Map<String, String>();
    customProperties["loggedIn"] = "true";

    await FlutterFreshchat.updateUserInfo(user: user, customProperties: customProperties);



    //await FlutterFreshchat.updateUserInfo(user: FreshchatUser);
  }*/


  Future<void> _deleteCacheDir() async {
    final cacheDir = await getTemporaryDirectory();

    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }
  _getPrefs() async{
   /* mobile=await PrefUtils.getMobileNum();
    countrycode=await PrefUtils.getCountrycode();
    debugPrint("countrycode"+countrycode);*/
  }
  @override
  Widget build(BuildContext context) {
    debugPrint('name : '+name);

    void launchWhatsApp() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
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


    // TODO: implement build
    return
      Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            /*AppBar(
              title: Text('Hello Friend!'),
              automaticallyImplyLeading: false, // it shouldnt add back button
            ),*/
            Container(
              color: ColorCodes.whiteColor,
              child: Column(
                children: [
                  SizedBox(
                    height: 50.0,
                  ),
                  checkskip
                      ? GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacementNamed(
                                SignupSelectionScreen.routeName);
                          },
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 22.0,
                              ),
                              Image.asset(Images.appLogin,
                                  height: 20.0, width: 20.0),
                              SizedBox(
                                width: 13.0,
                              ),
                              Text(
                               translate('appdrawer.Login or sign up'),//"Log In or Sign Up",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0),
                              ),
                              SizedBox(
                                width: 55.0,
                              ),
                              Icon(Icons.keyboard_arrow_right,
                                  color: Theme.of(context).primaryColor,
                                  size: 24),
                              SizedBox(
                                width: 10.0,
                              ),
                            ],
                          ),
                        )
                      : Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            SizedBox(width: 7.0),
                            IconButton(
                              icon: Icon(Icons.keyboard_arrow_left,
                                  color: ColorCodes.blackColor,
                                  size: 28),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            // if(photourl != null) CircleAvatar(radius: 30.0, backgroundColor: Color(0xffD3D3D3), backgroundImage: NetworkImage(photourl),),
                            //  if(photourl == null) CircleAvatar(radius: 30.0, backgroundColor: Color(0xffD3D3D3),),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    name,
                                    maxLines: 2,
                                    /*overflow: TextOverflow.ellipsis,*/ style:
                                        TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17.0),
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Text(
                                    email,
                                    overflow: TextOverflow.ellipsis, style:
                                        TextStyle(fontSize: 14.0),
                                  ),
                                ],
                              ),
                            ),
                            FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context)
                                    .pushNamed(EditScreen.routeName);
                              },
                              child: Text(
                                translate('appdrawer.edit'),//'EDIT',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: ColorCodes.blackColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(width: 20),
                          ],
                        ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            Divider(height: 2,color: ColorCodes.grey,),
            SizedBox(height: 10),
          /*  GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(
                  CategoryScreen.routeName,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      SizedBox(
                        width: 25.0,
                      ),
                      Image.asset(Images.appCategory,
                          height: 15.0, width: 15.0),
                      SizedBox(
                        width: 15.0,
                      ),
                      Text('SHOP BY CATEGORY',
                          style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).primaryColor)),
                      SizedBox(
                        width: 40.0,
                      ),
                      Icon(Icons.keyboard_arrow_right,
                          color: Theme.of(context).primaryColor, size: 24),
                    ],
                  ),
                ],
              ),
            ),*/
        /*    SizedBox(height: 5),
            Divider(
              color: ColorCodes.lightColor,
              thickness: 2,
            ),*/
            SizedBox(height: 15),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.of(context).pop();
                checkskip
                    ? Navigator.of(context).pushNamed(
                        SignupSelectionScreen.routeName,
                      )
                    : Navigator.of(context).popUntil(ModalRoute.withName(
                        HomeScreen.routeName,
                      ));
                //Navigator.of(context).pop();
              },
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 25.0,
                  ),
                  Image.asset(Images.appHome, height: 15.0, width: 15.0),
                  SizedBox(
                    width: 15.0,
                  ),
                  Text(
                      translate('appdrawer.home'),//"Home",
                    style: TextStyle(
                        fontSize: 15, color: ColorCodes.mediumBlackColor),
                  ),
                  Spacer(),
                ],
              ),
            ),
            SizedBox(height: 15),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.of(context).pop();
                checkskip
                    ? Navigator.of(context).pushNamed(
                        SignupSelectionScreen.routeName,
                      )
                    : Navigator.of(context).pushNamed(
                        MyorderScreen.routeName,
                      );
                //Navigator.of(context).pop();
              },
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 25.0,
                  ),
                  Image.asset(Images.appMyorder, height: 15.0, width: 15.0),
                  SizedBox(
                    width: 15.0,
                  ),
                  Text(
                    translate('appdrawer.myorders'),// "My Orders",
                    style: TextStyle(
                        fontSize: 15,
                        color: checkskip ? Colors.grey : ColorCodes.mediumBlackColor),
                  ),
                  Spacer(),
                ],
              ),
            ),
            SizedBox(height: 15),
            /*GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.of(context).pop();
                checkskip
                    ? Navigator.of(context).pushNamed(
                        SignupSelectionScreen.routeName,
                      )
                    : Navigator.of(context).pushNamed(
                        ShoppinglistScreen.routeName,
                      );
              },
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 25.0,
                  ),
                  Image.asset(Images.appShop, height: 15.0, width: 15.0),
                  SizedBox(
                    width: 15.0,
                  ),
                  Text(
                    "My shopping list",
                    style: TextStyle(
                        fontSize: 15,
                        color: checkskip
                            ? ColorCodes.greyColor
                            : ColorCodes.mediumBlackColor),
                  ),
                  Spacer(),
                ],
              ),
            ),
            SizedBox(height: 15),*/
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.of(context).pop();
                checkskip
                    ? Navigator.of(context).pushNamed(
                        SignupSelectionScreen.routeName,
                      )
                    : Navigator.of(context).pushNamed(
                        AddressbookScreen.routeName,
                      );
              },
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 25.0,
                  ),
                  Image.asset(Images.appAddress, height: 15.0, width: 15.0),
                  SizedBox(
                    width: 15.0,
                  ),
                  Text(
                    translate('appdrawer.addressBook'),// "Address Book",
                    style: TextStyle(
                        fontSize: 15,
                        color: checkskip
                            ? ColorCodes.greyColor
                            : ColorCodes.mediumBlackColor),
                  ),
                  Spacer(),
                ],
              ),
            ),
          //  SizedBox(height: 15),
         /*   GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.of(context).pop();
                checkskip
                    ? Navigator.of(context).pushNamed(
                  SignupSelectionScreen.routeName,
                )
                    : Navigator.of(context).pushNamed(
                  AddressbookScreen.routeName,
                );
              },
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 25.0,
                  ),
                  Image.asset(Images.appAddress, height: 15.0, width: 15.0),
                  SizedBox(
                    width: 15.0,
                  ),
                  Text(
                    "My Cards",
                    style: TextStyle(
                        fontSize: 15,
                        color: checkskip
                            ? ColorCodes.greyColor
                            : ColorCodes.mediumBlackColor),
                  ),
                  Spacer(),
                ],
              ),
            ),*/
            /*SizedBox(height: 20),
            Container(
              height: 40.0,
              color: ColorCodes.lightColor,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 25.0,
                  ),
                  Container(
                      width: 150.0,
                      child: Row(
                        children: <Widget>[
                          Image.asset(Images.appOffer,
                              height: 15.0, width: 15.0),
                          SizedBox(
                            width: 15.0,
                          ),
                          Text('OFFERS',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).primaryColor)),
                        ],
                      )),
                ],
              ),
            ),*/
            SizedBox(height: 15),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.of(context).pop();
                checkskip
                    ? Navigator.of(context).pushNamed(
                  SignupSelectionScreen.routeName,
                )
                    : Navigator.of(context).pushNamed(WalletScreen.routeName,
                    arguments: {'type': "loyalty"});
              },
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 25.0,
                  ),
                  Image.asset(Images.appLoyalty,
                      height: 15.0, width: 15.0),
                  SizedBox(
                    width: 15.0,
                  ),
                  Text(
                    translate('appdrawer.loyalty'),
                    style: TextStyle(
                        fontSize: 15,
                        color: checkskip
                            ? ColorCodes.greyColor
                            : ColorCodes.mediumBlackColor),
                  ),
                  Spacer(),
                ],
              ),
            ),
            SizedBox(height: 15),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.of(context).pop();
                checkskip
                    ? Navigator.of(context).pushNamed(
                  SignupSelectionScreen.routeName,
                )
                    : Navigator.of(context).pushNamed(
                  ReferEarn.routeName,
                );
              },
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 25.0,
                  ),
                  Icon(Icons.card_giftcard,size: 15,color: checkskip ? Colors.grey : ColorCodes.mediumBlackColor,),
                  //Image.asset(Images.appAddress, height: 15.0, width: 15.0),
                  SizedBox(
                    width: 15.0,
                  ),
                  Text(
                    translate('appdrawer.referandearn'), //'Refer and Earn' ,// "Address Book",
                    style: TextStyle(
                        fontSize: 15,
                        color: checkskip
                            ? ColorCodes.greyColor
                            : ColorCodes.mediumBlackColor),
                  ),
                  Spacer(),
                ],
              ),
            ),
            SizedBox(height: 15),
            Divider(color: ColorCodes.lightGreyColor,),
           /* GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.of(context).pop();
                checkskip
                    ? Navigator.of(context).pushNamed(
                        SignupSelectionScreen.routeName,
                      )
                    : Navigator.of(context).pushNamed(
                        MembershipScreen.routeName,
                      );
              },
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 25.0,
                  ),
                  Container(
                      width: 150.0,
                      child: Row(
                        children: <Widget>[
                          Image.asset(Images.appMember,
                              height: 15.0, width: 15.0),
                          SizedBox(
                            width: 15.0,
                          ),
                          Text(
                            'Membership',
                            style: TextStyle(
                                fontSize: 15,
                                color: checkskip
                                    ? ColorCodes.greyColor
                                    : ColorCodes.mediumBlackColor),
                          ),
                        ],
                      )),
                  SizedBox(width: 50),
                  Icon(Icons.keyboard_arrow_right,
                      color: ColorCodes.greyColor, size: 24),
                ],
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.of(context).pop();
                checkskip
                    ? Navigator.of(context).pushNamed(
                        SignupSelectionScreen.routeName,
                      )
                    : Navigator.of(context).pushNamed(WalletScreen.routeName,
                        arguments: {'type': "loyalty"});
              },
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 25.0,
                  ),
                  Container(
                      width: 150.0,
                      child: Row(
                        children: <Widget>[
                          Image.asset(Images.appLoyalty,
                              height: 15.0, width: 15.0),
                          SizedBox(
                            width: 15.0,
                          ),
                          Text(
                            'Loyalty',
                            style: TextStyle(
                                fontSize: 15,
                                color: checkskip
                                    ? ColorCodes.greyColor
                                    : ColorCodes.mediumBlackColor),
                          ),
                        ],
                      )),
                  SizedBox(width: 50),
                  Icon(Icons.keyboard_arrow_right,
                      color: ColorCodes.greyColor, size: 24),
                ],
              ),
            ),*/
          /*  SizedBox(height: 15),
            Container(
              height: 40.0,
              color: ColorCodes.lightColor,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 25.0,
                  ),
                  Container(
                      width: 150.0,
                      child: Row(
                        children: <Widget>[
                          Image.asset(Images.appMore,
                              height: 15.0, width: 15.0),
                          SizedBox(
                            width: 15.0,
                          ),
                          Text('MORE',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).primaryColor)),
                        ],
                      )),
                ],
              ),
            ),*/
            SizedBox(height: 15),
        /*    GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(
                  AboutScreen.routeName,
                );
              },
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 25.0,
                  ),
                  Container(
                      width: 150.0,
                      child: Row(
                        children: <Widget>[
                          Image.asset(Images.appAbout,
                              height: 15.0, width: 15.0),
                          SizedBox(width: 15.0),
                          Text(
                            'About us',
                            style: TextStyle(
                                fontSize: 15,
                                color: ColorCodes.mediumBlackColor),
                          ),
                        ],
                      )),
                  SizedBox(width: 50),
                  Icon(Icons.keyboard_arrow_right,
                      color: ColorCodes.greyColor, size: 24),
                ],
              ),
            ),
            SizedBox(height: 10),*/
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                Navigator.of(context).pop();
                checkskip
                    ? Navigator.of(context).pushNamed(
                  SignupSelectionScreen.routeName,
                )
                    : launchWhatsApp();//FlutterOpenWhatsapp.sendSingleMessage("+212652-655363", translate('forconvience.hello'));
                /*Navigator.of(context)
                    .pushNamed(CustomerSupportScreen.routeName, arguments: {
                  'name': name,
                  'email': email,
                  'photourl': photourl,
                  'phone': phone,
                });*/
              },
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 25.0,
                  ),
                  Image.asset(Images.appCustomer, height: 15.0, width: 15.0),
                  SizedBox(
                    width: 15.0,
                  ),
                  Text(
                    translate('appdrawer.customer support'), // "Customer support",
                    style: TextStyle(
                        fontSize: 15,
                        color: checkskip
                            ? ColorCodes.greyColor
                            : ColorCodes.mediumBlackColor),
                  ),
                  Spacer(),
                ],
              ),
            ),
            SizedBox(height: 15),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(
                  PrivacyScreen.routeName,
                );
              },
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 25.0,
                  ),
                  Container(
                      width: 150.0,
                      child: Row(
                        children: <Widget>[
                          Image.asset(Images.appPrivacy,
                              height: 15.0, width: 15.0),
                          SizedBox(
                            width: 15.0,
                          ),
                          Expanded(
                            child: Text(
                              translate('appdrawer.privacyothers'),//'Privacy & others',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: ColorCodes.mediumBlackColor),
                            ),
                          ),
                        ],
                      )),
                  SizedBox(width: 50),
                  Icon(Icons.keyboard_arrow_right,
                      color: ColorCodes.greyColor, size: 24),
                ],
              ),
            ),
            SizedBox(height: 15),
           /* GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.of(context).pop();
                checkskip
                    ? Navigator.of(context).pushNamed(
                        SignupSelectionScreen.routeName,
                      )
                    : Navigator.of(context).pushNamed(
                        HelpScreen.routeName,
                      );
              },
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 25.0,
                  ),
                  Container(
                      width: 150.0,
                      child: Row(
                        children: <Widget>[
                          Image.asset(Images.appHelp,
                              height: 15.0, width: 15.0),
                          SizedBox(
                            width: 15.0,
                          ),
                          Text(
                            'Help',
                            style: TextStyle(
                                fontSize: 15,
                                color: checkskip
                                    ? ColorCodes.greyColor
                                    : ColorCodes.mediumBlackColor),
                          ),
                        ],
                      )),
                  SizedBox(width: 50),
                  Icon(Icons.keyboard_arrow_right,
                      color: ColorCodes.greyColor, size: 24),
                ],
              ),
            ),
            SizedBox(height: 10),*/
            /*GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.of(context).pop();
                try {
                  if (Platform.isIOS) {
                    Share.share('Download ' +
                        IConstants.APP_NAME +
                        ' from App Store https://apps.apple.com/us/app/id1563407384');
                  } else {
                    Share.share('Download ' +
                        IConstants.APP_NAME +
                        ' from Google Play Store https://play.google.com/store/apps/details?id=com.fellahi.store');
                  }
                }catch(e){

                }
              },
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 25.0,
                  ),
                  Image.asset(Images.appShare, height: 15.0, width: 15.0),
                  SizedBox(
                    width: 15.0,
                  ),
                  Text(
                    "Share",
                    style: TextStyle(
                        fontSize: 15, color: ColorCodes.mediumBlackColor),
                  ),
                  Spacer(),
                ],
              ),
            ),
            SizedBox(height: 15),*/
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.of(context).pop();
                try {
                  if (Platform.isIOS) {
                    LaunchReview.launch(
                        writeReview: false, iOSAppId: "1563407384");
                  } else {
                    LaunchReview.launch();
                  }
                }catch(e){};
              },
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 25.0,
                  ),
                  Image.asset(Images.appRate, height: 15.0, width: 15.0),
                  SizedBox(
                    width: 15.0,
                  ),

                  Text(

                  _isIOS
                  ? translate('appdrawer.rateusapple')//"Rate us on Appstore"
                      : translate('appdrawer.rateus'),//"Rate us on Play Store",
                    style: TextStyle(
                  fontSize: 15, color: ColorCodes.mediumBlackColor),


                  ),

                  Spacer(),
                ],
              ),
            ),
            SizedBox(height: 15),
            if (!checkskip)
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.remove('LoginStatus');

                  if (prefs.getString('prevscreen') == 'signingoogle') {
                    prefs.setString("photoUrl", "");
                    await _googleSignIn.signOut();
                    debugPrint("googleccode"+countrycode);
                    //String countryCode = prefs.getString("country_code");
                   /* String countryCode = prefs.getString("country_code");
                    String branch = prefs.getString("branch");
                    String _tokenId = prefs.getString("tokenid");
                    String _mapFetch = "null";
                    String _isDelivering = "false";
                    String defaultLocation = "null";
                    String deliverylocation="null";
                    String _latitude="null";
                    String _longitude="null";
                    String currentdeliverylocation = IConstants.currentdeliverylocation.value;
                    if(prefs.containsKey("ismapfetch")) {
                      _mapFetch = prefs.getString("ismapfetch");
                    }
                    if(prefs.containsKey("isdelivering")) {
                      _isDelivering = prefs.getString("isdelivering");
                    }
                    if(prefs.containsKey("defaultlocation")) {
                      defaultLocation = prefs.getString("defaultlocation");
                    }
                    if(prefs.containsKey("deliverylocation")) {
                      deliverylocation = prefs.getString("deliverylocation");
                    }
                    if(prefs.containsKey("latitude")) {
                      _latitude = prefs.getString("latitude");
                    }

                    if(prefs.containsKey("longitude")) {
                      _longitude = prefs.getString("longitude");
                    }
                    prefs.clear();
                    prefs.setBool('introduction', true);
                    prefs.setString('country_code', countryCode);
                    prefs.setString("branch", branch);
                    prefs.setString('skip', "yes");
                    prefs.setString('tokenid', _tokenId);
                    prefs.setString("ismapfetch", _mapFetch);
                    prefs.setString("isdelivering", _isDelivering);
                    prefs.setString("defaultlocation",defaultLocation);
                    prefs.setString("deliverylocation", deliverylocation);
                    prefs.setString("longitude", _longitude);
                    prefs.setString("latitude", _latitude);
                    debugPrint("is delivery"+prefs.getString("isdelivering").toString());

                    IConstants.currentdeliverylocation.value = currentdeliverylocation;

                  //  PrefUtils.setCountrycode(countrycode);
                    Navigator.of(context).pushReplacementNamed(
                      SignupSelectionScreen.routeName,
                    );*/

                    String countryCode = prefs.getString("country_code");
                    String branch = prefs.getString("branch");
                    String _tokenId = prefs.getString("tokenid");
                    String _mapFetch = "null";
                    String _isDelivering = "false";
                    String defaultLocation = "null";
                    String deliverylocation="null";
                    String _latitude="null";
                    String _longitude="null";
                    String guestUserId = prefs.getString('guestuserId');
                    String currentdeliverylocation = IConstants.currentdeliverylocation.value;
                    if(prefs.containsKey("ismapfetch")) {
                      _mapFetch = prefs.getString("ismapfetch");
                    }
                    if(prefs.containsKey("isdelivering")) {
                      _isDelivering = prefs.getString("isdelivering");
                    }
                    if(prefs.containsKey("defaultlocation")) {
                      defaultLocation = prefs.getString("defaultlocation");
                    }
                    if(prefs.containsKey("deliverylocation")) {
                      deliverylocation = prefs.getString("deliverylocation");
                    }
                    if(prefs.containsKey("latitude")) {
                      _latitude = prefs.getString("latitude");
                    }

                    if(prefs.containsKey("longitude")) {
                      _longitude = prefs.getString("longitude");
                    }
                    prefs.clear();
                    prefs.setBool('introduction', true);
                    prefs.setString('country_code', countryCode);
                    prefs.setString("branch", branch);
                    prefs.setString('skip', "yes");
                    prefs.setString('tokenid', _tokenId);
                    prefs.setString("ismapfetch", _mapFetch);
                    prefs.setString("isdelivering", _isDelivering);
                    prefs.setString("defaultlocation",defaultLocation);
                    prefs.setString("deliverylocation", deliverylocation);
                    prefs.setString("longitude", _longitude);
                    prefs.setString("latitude", _latitude);
                    prefs.setString("guestuserId", guestUserId);
                    debugPrint("is delivery"+prefs.getString("isdelivering").toString());

                    IConstants.currentdeliverylocation.value = currentdeliverylocation;
                    Navigator.of(context).pushReplacementNamed(
                      SignupSelectionScreen.routeName,
                    );
                  } else if (prefs.getString('prevscreen') ==
                      'signinfacebook') {
                    prefs.getString("FBAccessToken");
                    var facebookSignIn = FacebookLogin();

                    final graphResponse = await http.delete(
                        'https://graph.facebook.com/v2.12/me/permissions/?access_token=${prefs.getString("FBAccessToken")}&httpMethod=DELETE&ref=logout&destroy=true');

                    prefs.setString("photoUrl", "");
                    await facebookSignIn.logOut().then((value) {
                      //String countryCode = prefs.getString("country_code");
                      /*String countryCode = prefs.getString("country_code");
                      String branch = prefs.getString("branch");
                      String _tokenId = prefs.getString("tokenid");
                      debugPrint("fbccode"+countrycode);
                      String _mapFetch = "null";
                      String _isDelivering = "false";
                      String defaultLocation = "null";
                      String deliverylocation="null";
                      String _latitude="null";
                      String _longitude="null";

                      String currentdeliverylocation = IConstants.currentdeliverylocation.value;
                      if(prefs.containsKey("ismapfetch")) {
                        _mapFetch = prefs.getString("ismapfetch");
                      }
                      if(prefs.containsKey("isdelivering")) {
                        _isDelivering = prefs.getString("isdelivering");
                      }
                      if(prefs.containsKey("defaultlocation")) {
                        defaultLocation = prefs.getString("defaultlocation");
                      }
                      if(prefs.containsKey("deliverylocation")) {
                        deliverylocation = prefs.getString("deliverylocation");
                      }
                      if(prefs.containsKey("latitude")) {
                        _latitude = prefs.getString("latitude");
                      }

                      if(prefs.containsKey("longitude")) {
                        _longitude = prefs.getString("longitude");
                      }
                      prefs.clear();
                      prefs.setBool('introduction', true);
                      prefs.setString('country_code', countryCode);
                      prefs.setString("branch", branch);
                      prefs.setString('skip', "yes");
                      prefs.setString('tokenid', _tokenId);
                      prefs.setString("ismapfetch", _mapFetch);
                      prefs.setString("isdelivering", _isDelivering);
                      prefs.setString("defaultlocation",defaultLocation);
                      prefs.setString("deliverylocation", deliverylocation);
                      prefs.setString("longitude", _longitude);
                      prefs.setString("latitude", _latitude);
                      debugPrint("is delivery"+prefs.getString("isdelivering").toString());

                      IConstants.currentdeliverylocation.value = currentdeliverylocation;
                      Navigator.of(context).pushReplacementNamed(
                        SignupSelectionScreen.routeName,
                      );*/

                      String countryCode = prefs.getString("country_code");
                      String branch = prefs.getString("branch");
                      String _tokenId = prefs.getString("tokenid");
                      String _mapFetch = "null";
                      String _isDelivering = "false";
                      String defaultLocation = "null";
                      String deliverylocation="null";
                      String _latitude="null";
                      String _longitude="null";
                      String guestUserId = prefs.getString('guestuserId');
                      String currentdeliverylocation = IConstants.currentdeliverylocation.value;
                      if(prefs.containsKey("ismapfetch")) {
                        _mapFetch = prefs.getString("ismapfetch");
                      }
                      if(prefs.containsKey("isdelivering")) {
                        _isDelivering = prefs.getString("isdelivering");
                      }
                      if(prefs.containsKey("defaultlocation")) {
                        defaultLocation = prefs.getString("defaultlocation");
                      }
                      if(prefs.containsKey("deliverylocation")) {
                        deliverylocation = prefs.getString("deliverylocation");
                      }
                      if(prefs.containsKey("latitude")) {
                        _latitude = prefs.getString("latitude");
                      }

                      if(prefs.containsKey("longitude")) {
                        _longitude = prefs.getString("longitude");
                      }
                      prefs.clear();
                      prefs.setBool('introduction', true);
                      prefs.setString('country_code', countryCode);
                      prefs.setString("branch", branch);
                      prefs.setString('skip', "yes");
                      prefs.setString('tokenid', _tokenId);
                      prefs.setString("ismapfetch", _mapFetch);
                      prefs.setString("isdelivering", _isDelivering);
                      prefs.setString("defaultlocation",defaultLocation);
                      prefs.setString("deliverylocation", deliverylocation);
                      prefs.setString("longitude", _longitude);
                      prefs.setString("latitude", _latitude);
                      prefs.setString("guestuserId", guestUserId);
                      debugPrint("is delivery"+prefs.getString("isdelivering").toString());

                      IConstants.currentdeliverylocation.value = currentdeliverylocation;
                      Navigator.of(context).pushReplacementNamed(
                        SignupSelectionScreen.routeName,
                      );
                    });
                  } else {
                   // String countryCode = prefs.getString("country_code");
                    String countryCode = prefs.getString("country_code");
                    String branch = prefs.getString("branch");
                    String _tokenId = prefs.getString("tokenid");
                    String _mapFetch = "null";
                    String _isDelivering = "false";
                    String defaultLocation = "null";
                    String deliverylocation="null";
                    String _latitude="null";
                    String _longitude="null";
                    String guestUserId = prefs.getString('guestuserId');
                    String currentdeliverylocation = IConstants.currentdeliverylocation.value;
                    if(prefs.containsKey("ismapfetch")) {
                      _mapFetch = prefs.getString("ismapfetch");
                    }
                    if(prefs.containsKey("isdelivering")) {
                      _isDelivering = prefs.getString("isdelivering");
                    }
                    if(prefs.containsKey("defaultlocation")) {
                      defaultLocation = prefs.getString("defaultlocation");
                    }
                    if(prefs.containsKey("deliverylocation")) {
                      deliverylocation = prefs.getString("deliverylocation");
                    }
                    if(prefs.containsKey("latitude")) {
                      _latitude = prefs.getString("latitude");
                    }

                    if(prefs.containsKey("longitude")) {
                      _longitude = prefs.getString("longitude");
                    }
                    prefs.clear();
                    prefs.setBool('introduction', true);
                    prefs.setString('country_code', countryCode);
                    prefs.setString("branch", branch);
                    prefs.setString('skip', "yes");
                    prefs.setString('tokenid', _tokenId);
                    prefs.setString("ismapfetch", _mapFetch);
                    prefs.setString("isdelivering", _isDelivering);
                    prefs.setString("defaultlocation",defaultLocation);
                    prefs.setString("deliverylocation", deliverylocation);
                    prefs.setString("longitude", _longitude);
                    prefs.setString("latitude", _latitude);
                    prefs.setString("guestuserId", guestUserId);
                    debugPrint("is delivery"+prefs.getString("isdelivering").toString());

                    IConstants.currentdeliverylocation.value = currentdeliverylocation;
                    Navigator.of(context).pushReplacementNamed(
                      SignupSelectionScreen.routeName,
                    );
                  }

                  _deleteCacheDir();

                },
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 25.0,
                    ),
                    Image.asset(Images.appLogout, height: 15.0, width: 15.0),
                    SizedBox(
                      width: 15.0,
                    ),
                    Text(
                      translate('appdrawer.logout'), //"Log Out",
                      style: TextStyle(
                          fontSize: 15, color: ColorCodes.mediumBlackColor),
                    ),
                    Spacer(),
                  ],
                ),
              ),
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}
