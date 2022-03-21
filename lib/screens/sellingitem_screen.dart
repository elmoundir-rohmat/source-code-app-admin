//web
/*
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import '../constants/ColorCodes.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../widgets/selling_items.dart';
import '../providers/sellingitems.dart';
import '../utils/ResponsiveLayout.dart';
import '../screens/home_screen.dart';
import '../widgets/header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/footer.dart';
import 'package:flutter_translate/flutter_translate.dart';
class SellingitemScreen extends StatefulWidget {
  static const routeName = '/sellingitem-screen';
  @override
  _SellingitemScreenState createState() => _SellingitemScreenState();
}

class _SellingitemScreenState extends State<SellingitemScreen> {
  var _isLoading = true;
  bool _isWeb =false;
  SharedPreferences prefs;
  MediaQueryData queryData;

  @override
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
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
      final seeallpress = routeArgs['seeallpress'];

      if(seeallpress == "featured") {
        Provider.of<SellingItemsList>(context,listen: false).fetchAllSellingItems("featured").then((_) {
          setState(() {
            _isLoading = false;
          });
        });
      } else {
        Provider.of<SellingItemsList>(context,listen: false).fetchAllSellingItems("discount").then((_) {
          setState(() {
            _isLoading = false;
          });
        });
      }
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final sellingitemData = Provider.of<SellingItemsList>(context,listen: false);
    double deviceWidth = MediaQuery.of(context).size.width;
    int widgetsInRow = 1;
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    double wid= queryData.size.width;
    double maxwid=wid*0.95;
    if (deviceWidth > 1200) {
      widgetsInRow = 5;
    } else if (deviceWidth > 768) {
      widgetsInRow = 3;
    }
    // double aspectRatio = (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 160;
    double aspectRatio =   (_isWeb && !ResponsiveLayout.isSmallScreen(context))?
    (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 290:
    (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 120;
    final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
    final title = routeArgs['title'];

    gradientappbarmobile() {
      return  AppBar(
        brightness: Brightness.dark,
        toolbarHeight: 60.0,
        elevation: 1,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined,size: 20, color: ColorCodes.backbutton),
            onPressed: () {

              Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
              return Future.value(false);
            }
        ),
        titleSpacing: 0,
        title: Text(
          translate('forconvience.Featured item'),
          //"Featured item",
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



    _body() {
      return _isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,
                      child: new GridView.builder(
                          shrinkWrap: true,
                          itemCount: sellingitemData.itemsall.length,
                          gridDelegate:
                          new SliverGridDelegateWithFixedCrossAxisCount(

                            crossAxisCount: widgetsInRow,
                            crossAxisSpacing: 3,
                            childAspectRatio: aspectRatio,
                            mainAxisSpacing: 3,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            return SellingItems(
                              "sellingitem_screen",
                              sellingitemData.itemsall[index].id,
                              sellingitemData.itemsall[index].title,
                              sellingitemData.itemsall[index].imageUrl,
                              sellingitemData.itemsall[index].brand,
                              "",
                            );
                          }),
                    ),

                  ),
                  if(_isWeb) Footer(address: prefs.getString("restaurant_address"))
                ],
              ),
            ),
          );


    }
    return Scaffold(
      appBar: ResponsiveLayout.isSmallScreen(context) ?
      gradientappbarmobile() : null,
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          if(_isWeb && !ResponsiveLayout.isSmallScreen(context))
            Header(false),
          _body(),
        ],
      ),
    );
  }
}
*/



//mobile

//mobile..........
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import '../constants/ColorCodes.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../widgets/selling_items.dart';
import '../providers/sellingitems.dart';
import '../utils/ResponsiveLayout.dart';
import '../screens/home_screen.dart';
import '../widgets/header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/footer.dart';
import 'package:flutter_translate/flutter_translate.dart';
class SellingitemScreen extends StatefulWidget {
  static const routeName = '/sellingitem-screen';
  @override
  _SellingitemScreenState createState() => _SellingitemScreenState();
}

class _SellingitemScreenState extends State<SellingitemScreen> {
  var _isLoading = true;
  bool _isWeb =false;
  SharedPreferences prefs;
  MediaQueryData queryData;

  @override
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
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
      final seeallpress = routeArgs['seeallpress'];

      if(seeallpress == "featured") {
        Provider.of<SellingItemsList>(context,listen: false).fetchAllSellingItems("featured").then((_) {
          setState(() {
            _isLoading = false;
          });
        });
      } else {
        Provider.of<SellingItemsList>(context,listen: false).fetchAllSellingItems("discount").then((_) {
          setState(() {
            _isLoading = false;
          });
        });
      }
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final sellingitemData = Provider.of<SellingItemsList>(context,listen: false);
    double deviceWidth = MediaQuery.of(context).size.width;
    int widgetsInRow = 1;
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    double wid= queryData.size.width;
    double maxwid=wid*0.95;
    if (deviceWidth > 1200) {
      widgetsInRow = 5;
    } else if (deviceWidth > 768) {
      widgetsInRow = 3;
    }
    // double aspectRatio = (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 160;
    double aspectRatio =   (_isWeb && !ResponsiveLayout.isSmallScreen(context))?
    (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 290:
    (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 120;
    final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;

    final title = routeArgs['title'];
    gradientappbarmobile() {
      return  AppBar(
        brightness: Brightness.dark,
        toolbarHeight: 60.0,
        elevation: 1,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined,size: 20, color: ColorCodes.backbutton),
            onPressed: () {
              Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
              return Future.value(false);
            }
        ),
        titleSpacing: 0,
        title: Text(
          translate('forconvience.Featured item'),
          //"Featured item",
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
      _body() {
       return
 _isLoading
            ? Center(
          child: CircularProgressIndicator(),
        )

            :
        Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                     // height: 100,
                        constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,
                        child: new GridView.builder(
                            shrinkWrap: true,
                            controller: new ScrollController(keepScrollOffset: false),
                        itemCount: sellingitemData.itemsall.length,
                        gridDelegate:
                        new SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: widgetsInRow,
                          crossAxisSpacing: 3,
                          childAspectRatio: aspectRatio,
                          mainAxisSpacing: 3,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return SellingItems(
                            "sellingitem_screen",
                            sellingitemData.itemsall[index].id,
                            sellingitemData.itemsall[index].title,
                            sellingitemData.itemsall[index].imageUrl,
                            sellingitemData.itemsall[index].brand,
                            "",
                          );
                        }),
                      ),
                    if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Footer(address: prefs.getString("restaurant_address"))
                  ],
                ),
              ),
            );


      }
    return Scaffold(
      appBar: ResponsiveLayout.isSmallScreen(context) ?
      gradientappbarmobile() : null,
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          if(_isWeb && !ResponsiveLayout.isSmallScreen(context))
            Header(false),
          _isLoading ? Expanded(
            child: Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
              ),
            ),
          )
              :
          _body(),
        ],
      ),
    );
  }
}


