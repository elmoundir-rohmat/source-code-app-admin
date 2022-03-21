import 'dart:convert';
import 'package:fellahi_e/constants/ColorCodes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../screens/searchitem_screen.dart';
import '../providers/notificationitems.dart';
import '../widgets/categories_item.dart';
import '../screens/home_screen.dart';
import '../constants/IConstants.dart';
import '../providers/addressitems.dart';
import '../providers/branditems.dart';
import 'package:flutter_translate/flutter_translate.dart';

class NotSubcategoryScreen extends StatefulWidget {
  static const routeName = '/not-subcategory-screen';
  @override
  _NotSubcategoryScreenState createState() => _NotSubcategoryScreenState();
}

class _NotSubcategoryScreenState extends State<NotSubcategoryScreen> {
  bool _isLoading = true;
  var subcategoryData;
  bool _isInit = true;
  var currency_format = "";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
      final subcategoryId = routeArgs['subcategoryId'];

      if(routeArgs['fromScreen'] == "ClickLink") {
        Provider.of<NotificationItemsList>(context,listen: false).updateNotificationStatus(routeArgs['notificationId'], "1" );
      } else {
        if(routeArgs['notificationStatus'] == "0"){
          Provider.of<NotificationItemsList>(context,listen: false).updateNotificationStatus(routeArgs['notificationId'], "1" ).then((value){
            Provider.of<NotificationItemsList>(context,listen: false).fetchNotificationLogs(
                prefs.getString('userID'));
          });
        }
      }

      Provider.of<NotificationItemsList>(context,listen: false).fetchCategoryItems(subcategoryId).then((_) {
        subcategoryData = Provider.of<NotificationItemsList>(context,listen: false);
        setState(() {

          if (subcategoryData.catitems.length <= 0) {
            _isLoading = false;
          } else {
            _isLoading = false;
          }
        });

      }); // only create the future once.
    });
  }

  @override
  didChangeDependencies() {
    if (_isInit){
      setState(() {
        _isLoading = true;
      });

      //Provider.of<CartItems>(context, listen: false).fetchCartItems();

      Provider.of<AddressItemsList>(context,listen: false).fetchAddress();
      Provider.of<BrandItemsList>(context,listen: false).fetchShoppinglist();
      Provider.of<BrandItemsList>(context,listen: false).GetRestaurant().then((value) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        currency_format = prefs.getString("currency_format");
      });
      fetchDelivery();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> fetchDelivery () async { // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'restaurant/details';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final response = await http
          .post(
          url,
          body: { // await keyword is used to wait to this operation is complete.
            "mode": "getAll",
            "branch": prefs.getString('branch'),
          }
      );

      final responseJson = json.decode(response.body);

      if (responseJson['status'].toString() == "true") {
        final dataJson = json.encode(responseJson['data']); //fetching categories data
        final dataJsondecode = json.decode(dataJson);


        List data = []; //list for categories

        dataJsondecode.asMap().forEach((index, value) =>
            data.add(dataJsondecode[index] as Map<String, dynamic>)
        ); //store each category values in data list

        SharedPreferences prefs = await SharedPreferences.getInstance();


        for (int i = 0; i < data.length; i++){
          prefs.setString("resId", data[i]['id'].toString());
          prefs.setString("minAmount", data[i]['minOrderAmount'].toString());
          prefs.setString("deliveryCharge", data[i]['deliveryCharge'].toString());
        }

      }

    } catch (error) {
      throw error;
    }
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    bool _isNotification = false;
    final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
    if(routeArgs['fromScreen'] == "ClickLink") {
      _isNotification = false;
    } else {
      _isNotification = true;
    }

    return _isNotification ?
    WillPopScope(
      onWillPop: (){
        Navigator.of(context).pop();
       /* Navigator.of(context).pushNamedAndRemoveUntil(
            '/home-screen', (Route<dynamic> route) => false);*/
      },
      child: Scaffold(
        backgroundColor: ColorCodes.whiteColor,
        appBar: GradientAppBar(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [ ColorCodes.whiteColor,
                ColorCodes.whiteColor,]
          ),
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_outlined,size: 20, color: ColorCodes.backbutton),
              onPressed: () =>  /*Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home-screen', (Route<dynamic> route) => false)*/
            Navigator.of(context).pop()
          ),
          title: Text(
              translate('bottomnavigation.categories')  // "Categories",

          ),
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(
                  SearchitemScreen.routeName,
                );
              },
              child: Icon(
                Icons.search,
                size: 22.0,
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
          ],
        ),

        body: _isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
          ),
        )
            :
        GridView.builder(
          shrinkWrap: true,
          controller: new ScrollController(
              keepScrollOffset: false
          ),
          padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 0.0),
          itemCount: subcategoryData.catitems.length,
          itemBuilder: (BuildContext context, int index) {
            return  Container(
              color: ColorCodes.whiteColor,
              /*shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),

                ),
              ),*/
              //elevation: 0,
              margin: EdgeInsets.all(5),
              child: CategoriesItem(
                  "NotSubcategoryScreen", "Offers", "", "", "", index,
                  subcategoryData.catitems[index].imageUrl),
              // backgroundColor: Colors.transparent
            );
          },
/*            itemBuilder: (ctx, i) => ChangeNotifierProvider.value (
                value: subcategoryData.catitems[i],
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  margin: EdgeInsets.all(5),
                  child: CategoriesItem("SubcategoryScreen", "Offers", i),
                ),
              ),*/
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 3,
            mainAxisSpacing: 3,
          ),
        ),
      ),
    )
        :
    WillPopScope(
      onWillPop: () { // this is the block you need
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/home-screen', (Route<dynamic> route) => false);
       // Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: ColorCodes.whiteColor,
        appBar: GradientAppBar(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [ ColorCodes.whiteColor,
                ColorCodes.whiteColor,]
          ),
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_outlined,size: 20, color: ColorCodes.backbutton),
              onPressed: () =>
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/home-screen', (Route<dynamic> route) => false)
            // Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,))
          ),
          title: Text(
              translate('bottomnavigation.categories') // "Categories",
          ),
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(
                  SearchitemScreen.routeName,
                );
              },
              child: Icon(
                Icons.search,
                size: 22.0,
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
          ],
        ),

        body: _isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
          ),
        )
            :
        GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
          controller: new ScrollController(
              keepScrollOffset: false
          ),
          itemCount: subcategoryData.catitems.length,
          itemBuilder: (BuildContext context, int index) {
            return  Container(
             /* shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),*/
              //elevation: 0,
              margin: EdgeInsets.all(5),
              child: CategoriesItem("NotSubcategoryScreen", "Offers", "", "", "", index, subcategoryData.catitems[index].imageUrl),
            );
          },
/*            itemBuilder: (ctx, i) => ChangeNotifierProvider.value (
              value: subcategoryData.catitems[i],
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                margin: EdgeInsets.all(5),
                child: CategoriesItem("SubcategoryScreen", "Offers", i),
              ),
            ),*/
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 3,
            mainAxisSpacing: 3,
          ),
        ),
      ),
    );
  }
}