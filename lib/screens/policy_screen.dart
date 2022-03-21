import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/ResponsiveLayout.dart';
import '../widgets/header.dart';
import '../widgets/footer.dart';
import '../screens/home_screen.dart';
import '../constants/ColorCodes.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'dart:io';
class PolicyScreen extends StatefulWidget {
  static const routeName = '/policy-screen';
  @override
  _PolicyScreenState createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  bool _iscontactus = false;
  bool _isWeb =false;
  SharedPreferences prefs;
 // bool _isloading = true;
  MediaQueryData queryData;
  double wid;
  double maxwid;
  void initState() {
    try {
      if (Platform.isIOS) {
        setState(() {
          _isWeb = false;
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
    // Future.delayed(Duration.zero, () async{
    //   prefs = await SharedPreferences.getInstance();
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute
        .of(context)
        .settings
        .arguments as Map<String, String>;

    final title = routeArgs['title'];
    final body = routeArgs['body'];
    String businessname;
    String address;
    String contactnum;
    String pemail;
    String semail;

    if(title == "Contact Us") {
      _iscontactus = true;
      businessname = routeArgs['businessname'];
      address = routeArgs['address'];
      contactnum = routeArgs['contactnum'];
      pemail = routeArgs['pemail'];
      semail = routeArgs['semail'];
    } else {
      _iscontactus = false;
    }
    
    gradientappbarmobile() {
      return  AppBar(
        brightness: Brightness.dark,
        toolbarHeight: 60.0,
        elevation: 1,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined,size: 20, color: ColorCodes.backbutton),
            onPressed: () {
             // Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
              Navigator.of(context).pop();
              return Future.value(false);
            }
        ),
        titleSpacing: 0,
        title: Text(title,style: TextStyle(color:ColorCodes.backbutton),),
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
    _body() {
       /*_isloading ?
      Center(
        child: CircularProgressIndicator(),
      ) :*/
      queryData = MediaQuery.of(context);
      wid= queryData.size.width;
      maxwid=wid*0.90;
     return Expanded(
        child: SingleChildScrollView(
          child: Container(
            constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,

            child: Column(
              children: <Widget>[
                _iscontactus ?
                Column(
                  children: <Widget>[
                    SizedBox(height: 10.0,),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 10.0,),
                        Text("Business Name", style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),),
                      ],
                    ),
                    SizedBox(height: 5.0,),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 10.0,),
                        Text(businessname, style: TextStyle(fontSize: 14.0),),
                      ],
                    ),
                    SizedBox(height: 10.0,),
                    Divider(),
                    SizedBox(height: 10.0,),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 10.0,),
                        Text("Address", style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.0),),
                      ],
                    ),
                    SizedBox(height: 5.0,),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 10.0,),
                        Expanded(child: Text(
                          address, style: TextStyle(fontSize: 14.0),)),
                      ],
                    ),
                    SizedBox(height: 10.0,),
                    Divider(),
                    SizedBox(height: 10.0,),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 10.0,),
                        Text("Contact Number", style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.0),),
                      ],
                    ),
                    SizedBox(height: 5.0,),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 10.0,),
                        Text(contactnum, style: TextStyle(fontSize: 14.0),),
                      ],
                    ),
                    SizedBox(height: 10.0,),
                    Divider(),
                    SizedBox(height: 10.0,),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 10.0,),
                        Text("Email", style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.0),),
                      ],
                    ),
                    SizedBox(height: 5.0,),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 10.0,),
                        Text(pemail, style: TextStyle(fontSize: 14.0),),
                      ],
                    ),
                    SizedBox(height: 5.0,),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 10.0,),
                        Text(semail, style: TextStyle(fontSize: 14.0),),
                      ],
                    ),
                    SizedBox(height: 10.0,),
                    Divider(),
                  ],
                )
                    :
                Row(
                  children: <Widget>[
                    SizedBox(width: 5.0,),
//                  Expanded(child: Text(privacy)),
                    Expanded(
                        child: MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                              textScaleFactor: 1.0),
                          child: Html(data: body,
                            style: {
                              "span": Style(
                                fontSize: FontSize(12.0),
                                fontWeight: FontWeight.normal,
                              )
                            },
                          ),
                        )
                    ),
                    // SizedBox(width: 5.0,),
                  ],
                ),
                if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Footer(address: 'abc')
              ],
            ),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: (){
        Navigator.of(context).pop();
      },
      child: Scaffold(

        appBar: ResponsiveLayout.isSmallScreen(context) ?
        gradientappbarmobile() : null,
        backgroundColor:Colors.white, //Theme.of(context).backgroundColor,
        body: Column(
          children: <Widget>[
            if(_isWeb && !ResponsiveLayout.isSmallScreen(context))
              Header(false),
            _body(),
          ],
        ),
      ),
    );
  }
}
