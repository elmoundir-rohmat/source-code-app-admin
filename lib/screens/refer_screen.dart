
import 'dart:io';
import 'package:fellahi_e/constants/ColorCodes.dart';
import 'package:fellahi_e/constants/images.dart';
import 'package:fellahi_e/utils/ResponsiveLayout.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../constants/IConstants.dart';
import '../providers/branditems.dart';
import '../screens/policy_screen.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReferEarn extends StatefulWidget {
  static const routeName = '/refer_screen';
  @override
  _ReferEarnState createState() => _ReferEarnState();
}

class _ReferEarnState extends State<ReferEarn> {
  var image;
  bool _loading = true;
  String referalCode = " ";
  String referalCount = " ";
  String referalEarning = " ";
  bool iphonex = false;
  bool _isWeb = false;
  Uri dynamicUrl;
  var _currencyFormat = "";
  bool _isIOS = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      try {
        if (Platform.isIOS) {
          setState(() {
            _isIOS = true;
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      referalCode= prefs.getString('myreffer');
      /*  List<Application> apps = await DeviceApps.getInstalledApplications(
          onlyAppsWithLaunchIntent: true, includeSystemApps: true);*/
      await Provider.of<BrandItemsList>(context,listen: false).ReferEarn().then((_) {
        final referData = Provider.of<BrandItemsList>(context,listen: false);
        image = referData.referEarn.imageUrl;
        referalCount = referData.referEarn.referral_count.toString();
        referalEarning = referData.referEarn.earning_amount.toString();
        setState(() {
          _loading =false;
        });
      });
      createReferralLink(referalCode);

    });
  }
  showBottom(){
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  Text(
                      'Invite'
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
  Future<String> createReferralLink(String referralCode) async {
    final DynamicLinkParameters dynamicLinkParameters = DynamicLinkParameters(
        uriPrefix: 'https://fellahi.page.link',
        link: Uri.parse('https://referandearn.com/refer?code=$referralCode'),
        androidParameters: AndroidParameters(
          packageName: IConstants.androidId,
        ),
        iosParameters: IosParameters(
            bundleId: "com.fellahi.store",
            appStoreId: IConstants.appleId
        )
      /* socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Refer A Friend',
        description: 'Refer and earn',
        imageUrl: Uri.parse(
            'https://www.insperity.com/wp-content/uploads/Referral-_Program1200x600.png'),
      ),*/
    );

    final ShortDynamicLink shortLink =
    await dynamicLinkParameters.buildShortLink();
    dynamicUrl = shortLink.shortUrl;
    return dynamicUrl.toString();
  }

  @override
  Widget build(BuildContext context) {
    final referData = Provider.of<BrandItemsList>(context,listen: false);
    return Scaffold(
      appBar:ResponsiveLayout.isSmallScreen(context)
          ? gradientappbarmobile()
          : null,
      /*GradientAppBar(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Theme.of(context).accentColor,
                Theme.of(context).primaryColor
              ]),
          title: Text(
             "Refer And Earn",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),*/
      body: _loading? Center(
        child: CircularProgressIndicator(),
      ):
      SingleChildScrollView(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Text(
                    translate('forconvience.referal_count')// "Referral count"
                          + ": " + referalCount.toString(),style: TextStyle(fontSize: 18),),
                    Spacer(),
                    Text(
                        translate('forconvience.yours_earning')//"Your Earnings"
                            + ": " + _currencyFormat +referalEarning.toString(),style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
              SizedBox(height: 20,),
              GestureDetector(
                onTap: () async {
              /*    SharedPreferences prefs = await SharedPreferences.getInstance();
*//*                  prefs.setString('pressed', "termsuse");
                        Navigator.of(context).pushNamed(
                          PolicyScreen.routeName,
                        );*//*
                  Navigator.of(context).pushNamed(
                      PolicyScreen.routeName,
                      arguments: {
                        'title' : "Refer",
                        'body' : prefs.getString("refer"),
                      }
                  );*/
                },
                child: Image.network(
                  image,
                  errorBuilder: (context, url, error) => Image.asset(Images.defaultSliderImg),
                  width: MediaQuery.of(context).size.width,
                  height:MediaQuery.of(context).size.height*0.80,
                  //  fit: BoxFit.fill,
                ),
              ),


            ],
          ),
        ),
      ),
      bottomNavigationBar: _loading ? SizedBox.shrink() :
      Padding(
        padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
        child:GestureDetector(
          onTap: (){
            _isIOS ?
            Share.share(/*'Download the '*/translate('forconvience.download_the') +
                IConstants.APP_NAME /*+" Grocery app "*/+
                //' from App Store '
                translate('forconvience.using_link')+
                ' ('+ referalCode +').'+" "+" <" +dynamicUrl.toString() +">")
                :
            Share.share(/*'Download the '*/translate('forconvience.download_the') +
                IConstants.APP_NAME /*+" Grocery app "*/+
                // ' from Google Play Store '
                translate('forconvience.using_link')+
                ' ('+ referalCode +').'+" " + "<"+dynamicUrl.toString()+">");
          },
          child: Container(
            color: Theme.of(context).primaryColor,
            height: 60,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(child: RichText(
                  text: new TextSpan(
                    children: <TextSpan>[
                      new TextSpan(
                        text:
                  translate('forconvience.your_code') + ":",//'Your Code:  ',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 17, color: ColorCodes.whiteColor),
                      ),
                      new TextSpan(
                        text: referalCode ,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18, color: ColorCodes.whiteColor ),
                      ),
                    ],
                  ),
                ),),
                Center(
                  child: Container(
                    height: 30,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(child: Text(
                      translate('forconvience.invite'),//'Invite',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,color: Theme.of(context).primaryColor),)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  gradientappbarmobile() {
    return AppBar(
      brightness: Brightness.dark,
      toolbarHeight: 60.0,
      elevation: 1,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_outlined,size: 20, color: ColorCodes.backbutton),
        onPressed: () async{
          Navigator.of(context).pop();
        },),
      title: Text(
          translate('appdrawer.referandearn')/*'Refer And Earn'*/,style: TextStyle(color: ColorCodes.backbutton,fontWeight: FontWeight.bold),
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
                ])),
      ),
    );
  }
}
