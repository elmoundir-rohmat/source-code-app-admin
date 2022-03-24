//web.....


import 'dart:io';
import '../screens/map_address_screen.dart';

import 'package:cached_network_image/cached_network_image.dart';
import '../screens/map_address_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places_web/flutter_google_places_web.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../utils/ResponsiveLayout.dart';
import '../providers/addressfields.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/addressitems.dart';
import '../screens/address_screen.dart';
import '../constants/ColorCodes.dart';
import '../screens/map_screen.dart';
import '../screens/home_screen.dart';
import '../constants/images.dart';
import '../screens/example_screen.dart';
import 'package:flutter_translate/flutter_translate.dart';

enum FilterOptions {
  Edit,
  Delete,
}

class AddressbookScreen extends StatefulWidget {
  static const routeName = '/addressbook-screen';

  @override
  _AddressbookScreenState createState() => _AddressbookScreenState();
}

class _CustomRadioButton {
  bool buttonLables;
  bool buttonValues;
  bool radioButtonValue;
  bool buttonWidth;
  bool buttonList;

  _CustomRadioButton({
    this.buttonLables,
    this.buttonValues,
    this.radioButtonValue,
    this.buttonWidth,
    // this.buttonColor,
    // this.selectedColor,
    // this.buttonHeight,
    // this.horizontal,
    // this.enableShape,
    // this.elevation,
    // this.customShape,
    // this.fontSize,
    // this.lineSpace,
    // this.buttonSpace,
    // this.buttonBorderColor,
    // this.textColor,
    // this.selectedTextColor,
    // this.initialSelection,
    // this.unselectedButtonBorderColor
  });
}

class _AddressbookScreenState extends State<AddressbookScreen> {
  var addressitemsData;
  SharedPreferences prefs;
  var deliverylocation;
  bool _addresscheck = false;
  int _groupValue = 0;
  String singleAddress = '1';
  int value = 0;
  bool _isWeb = false;
  var _address = "";
  bool _isLoading = true;
  MediaQueryData queryData;
  double wid;
  double maxwid;

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

      setState(() {
        _address = prefs.getString("restaurant_address");
        deliverylocation= prefs.getString("deliverylocation");
        prefs.getString("lati");
        prefs.getString("long");
        Provider.of<AddressItemsList>(context, listen: false).fetchAddress().then((_) {
          setState(() {
            addressitemsData = Provider.of<AddressItemsList>(context, listen: false);
            if (addressitemsData.items.length <= 0) {
              _addresscheck = false;
              _isLoading = false;
            } else {
              _addresscheck = true;
              _isLoading = false;
            }
          });
        });
      });
    });

    super.initState();
  }

  void deleteaddress(String addressid) {
    _dialogforSaveadd(context);
    setState(() {
      _isLoading = true;
    });
    Provider.of<AddressItemsList>(context,listen: false).deleteAddress(addressid).then((_) {
      Provider.of<AddressItemsList>(context,listen: false).fetchAddress().then((_) {
        setState(() {
          Navigator.of(context).pop();
          addressitemsData =
              Provider.of<AddressItemsList>(context, listen: false);
          if (addressitemsData.items.length <= 0) {
            _addresscheck = false;
            _isLoading = false;
          } else {
            _addresscheck = true;
            _isLoading = false;
          }
        });
      });
    });
  }

  void setDefaultAddress(String addressid) {
    Provider.of<AddressItemsList>(context,listen: false)
        .setDefaultAddress(addressid)
        .then((_) {
      /*Provider.of<AddressItemsList>(context).fetchAddress().then((_) {*/
      setState(() {
        addressitemsData =
            Provider.of<AddressItemsList>(context, listen: false);
        if (addressitemsData.items.length <= 0) {
          _addresscheck = false;
          _isLoading = false;
        } else {
          _addresscheck = true;
          _isLoading = false;
        }
      });
    });
  }

  Widget printAddress(BuildContext context, i, String addressid) {
    if (addressitemsData.items[i].addressdefault == '1') {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pop(true);
        },
        child: Container(
          //height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.only(left: 20)),
              Align(
                  alignment: Alignment.topLeft,
                  child: Icon(Icons.radio_button_checked,
                      size: 18, color: ColorCodes.mediumBlueColor)),
              Padding(padding: EdgeInsets.only(left: 10)),
              Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      /*Align(
                        alignment: Alignment.topLeft,
                        child:*/ Text(
                        translate('forconvience.defaultaddress'),//'Default Address:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xff3B3939),
                        ),
                      ),
                      // ),
                      Padding(padding: EdgeInsets.only(top: 5)),


                      new RichText(textAlign: TextAlign.start,
                        text: new TextSpan(

                          // Note: Styles for TextSpans must be explicitly defined.
                          // Child text spans will inherit styles from parent
                          style: new TextStyle(
                            fontSize: 15.0,
                            color: Colors.grey,
                          ),
                          children: <TextSpan>[
                            new TextSpan(text: addressitemsData.items[i].useraddtype+"\n",
                              style:new TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: ColorCodes.blackColor), ),
                            new TextSpan(
                                text: addressitemsData.items[i].useraddress,
                                style:new TextStyle(fontSize: 14)
                              // style: new TextStyle(color: ColorCodes.darkgreen),
                            ),

                          ],
                        ),
                      ),
                      /* Text(
                        addressitemsData.items[i].useraddtype+  "\n" +addressitemsData.items[i].useraddress,
                        style: TextStyle(
                          fontSize: 14,
                          color: ColorCodes.greyColor,
                        ),
                      ),*/
                    ],
                  )),
            ],
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () async {
          setDefaultAddress(addressid);
          //UpdateAddress(addressid,latitude,longitude,branch);
          // Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
          Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
          //Navigator.of(context).pop(true);
        },
        child: Container(
          // height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.only(left: 20)),
              Align(
                  alignment: Alignment.topLeft,
                  child: Icon(Icons.radio_button_unchecked,
                      size: 18, color: ColorCodes.mediumBlueColor)),
              Padding(padding: EdgeInsets.only(left: 10)),
              Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    children: [
                      /*Text(
                        addressitemsData.items[i].useraddtype+  "\n" +addressitemsData.items[i].useraddress ,
                        style: TextStyle(
                          fontSize: 14,
                          color: ColorCodes.greyColor,
                        ),
                      ),*/
                      new RichText(
                        textAlign: TextAlign.start,
                        text: new TextSpan(

                          // Note: Styles for TextSpans must be explicitly defined.
                          // Child text spans will inherit styles from parent
                          style: new TextStyle(
                            fontSize: 15.0,
                            color: Colors.grey,
                          ),
                          children: <TextSpan>[
                            new TextSpan(text: addressitemsData.items[i].useraddtype+"\n",
                              style:new TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: ColorCodes.blackColor), ),
                            new TextSpan(
                                text: addressitemsData.items[i].useraddress,
                                style:new TextStyle(fontSize: 14)
                              // style: new TextStyle(color: ColorCodes.darkgreen),
                            ),

                          ],
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      );
    }
  }

  Widget _myRadioButton({int value, Function onChanged}) {
    return Radio(
      value: value,
      groupValue: _groupValue,
      onChanged: onChanged,
    );
  }

  _dialogforDeleteAdd(BuildContext context, String addressid) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                  width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.40:MediaQuery.of(context).size.width,
                  height: 100.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Text(
                          translate('forconvience.delete'),//'Are you sure you want to delete this address?',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        children: <Widget>[
                          Spacer(),
                          GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop(true);
                              },
                              child: Text(
                                translate('forconvience.no'), //'NO',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 14.0),
                              )),
                          SizedBox(
                            width: 20.0,
                          ),
                          GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop(true);

                                deleteaddress(addressid);
                              },
                              child: Text(
                                translate('forconvience.YES'),//'YES',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 14.0),
                              )),
                          SizedBox(
                            width: 20.0,
                          ),
                        ],
                      )
                    ],
                  )),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    wid= queryData.size.width;
    maxwid=wid*0.90;

    return WillPopScope(
      onWillPop: () { // this is the block you need
        //Hive.openBox<Product>(productBoxName);
        (_isWeb && !ResponsiveLayout.isSmallScreen(context)) ?

        Navigator.of(context).pushNamedAndRemoveUntil(
            '/home-screen', (Route<dynamic> route) => false)

            :

        Navigator.of(context).pop();
        return Future.value(false);
      },
      child: Scaffold(
          appBar: ResponsiveLayout.isSmallScreen(context) ?
          gradientappbarmobile() : null,
          backgroundColor: Colors.white,
          body:Column(
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
                )
                    :
                _body(),
              ]
          )
      ),
    );


  }

  _dialogforSaveadd(BuildContext context) {
    return showDialog(context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0)
                  ),
                  child: Container(
                      height: 100.0,
                      width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width/3:MediaQuery.of(context).size.width,
                      child:
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                          ),
                          SizedBox(width: 40.0,),
                          Text(
                            translate('forconvience.deleting'),//'Deleting...'
                          ),
                        ],
                      )
                  ),
                );
              }
          );
        });
  }
  _body(){
    return _isWeb?_bodyweb():
    _bodymobile();
  }
  _bodymobile(){
    return Expanded(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              !_addresscheck
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    Images.noAddressImg,
                    fit: BoxFit.fill,
                    width: 200.0,
                    height: 200.0,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Center(
                      child: Text(
                        translate('forconvience.saveaddress'),// "Save addresses to make home delivery more convenient.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 14.0),
                      )),
                  SizedBox(
                    height: 20.0,
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        prefs.setString("addressbook", "AddressbookScreen");
                        Navigator.of(context)
                            .pushReplacementNamed(ExampleScreen .routeName, arguments: {
                          'addresstype': "new",
                          'addressid': "",
                          'delieveryLocation': "",
                          'latitude': "",
                          'longitude': "",
                          'branch': ""
                        });
                      },
                      child: Text(
                        translate('forconvience.Add Address'), //"Add Address",
                        style: TextStyle(
                          //fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                ],
              )
                  : Expanded(child:Column(
                children: <Widget>[
                  SizedBox(
                    height: 10.0,
                  ),

                  /*Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Container(
                      child: RaisedButton(
                        onPressed: () {},
                        child: Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: ColorCodes.whiteColor,
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              prefs.setString(
                                "formapscreen", "addressbook_screen");
                              Navigator.of(context)
                                .pushNamed(MapScreen.routeName);
                              },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.gps_fixed),
                                Padding(padding: EdgeInsets.only(left: 5)),
                                Text(
                                'Choose Current Location',
                                  style: TextStyle(
                                    fontSize: 19,
                                    color: ColorCodes.mediumBlackColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),*/

                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10.0,
                      left: 20,
                      right: 28,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        /* Text(
                        'Saved Addresses',
                          style: TextStyle(
                            fontSize: 19,
                            color: ColorCodes.greyColor,
                          ),
                        ),*/
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              prefs.setString("addressbook", "AddressbookScreen");
                              Navigator.of(context)
                                  .pushReplacementNamed(ExampleScreen.routeName, arguments: {
                                'addresstype': "new",
                                'addressid': "",
                                'delieveryLocation': "",
                                'latitude': "",
                                'longitude': "",
                                'branch': ""
                              });
                            },
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 10.0,
                                ),
                                Icon(
                                  Icons.add,
                                  color:  Theme.of(context).primaryColor,
                                ),
                                SizedBox(
                                  width: 6.0,
                                ),
                                Text(
                                  translate('forconvience.Add Address'), //"Add Address",
                                  style: TextStyle(
                                    //fontWeight: FontWeight.bold,
                                      fontSize: 19.0,
                                      color: Theme.of(context).primaryColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //Divider(),
                  //Padding(padding: EdgeInsets.only(top: 10)),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                  ),
                  Expanded(
                    child: new ListView.builder(
                      itemCount: addressitemsData.items.length,
                      itemBuilder: (_, i) => Column(
                        children: [
                          Container(
                            width:MediaQuery.of(context).size.width,
                            margin: EdgeInsets.only(left: 10, right: 10),
                            //padding: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Container(
                              //height: 50,
                              margin: EdgeInsets.only(right: 10, ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal:10.0),
                                    child: Row(
                                      children: [
                                        /* Icon( addressitemsData.items[i].addressicon,color: ColorCodes.lightGreyColor,),
                                        Padding(
                                          padding: const EdgeInsets.only(left:5.0),
                                          child: Text(addressitemsData.items[i].useraddtype.toString()),
                                        ),*/

                                        /* CachedNetworkImage(
                                          imageUrl: addressitemsData.items[i].addressicon,
                                         *//* placeholder: (context, url) => Image.asset(
                                              Images.defaultCategoryImg),*//*

                                          height: ResponsiveLayout.isSmallScreen(context)?100:120,
                                          width: ResponsiveLayout.isSmallScreen(context)?115:160,
                                          //fit: BoxFit.fill,
                                        ) ,*/
                                      ],
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.only(top: 15),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              printAddress(context, i,
                                                  addressitemsData.items[i].userid),
                                              /*  Padding(
                                                padding: const EdgeInsets.only(left:15.0),
                                                child: Text(addressitemsData.items[i].useraddtype.toString()),
                                              ),*/
                                            ],
                                          ),
                                        ),
                                      ),
                                      //SizedBox(width: 20.0),
                                      //Spacer(),
                                      /* Padding(
                                        padding: EdgeInsets.only(left: 90),
                                      ),*/

                                      /*Row(
                                      //crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          IconButton(
                                            padding: EdgeInsets.all(0),
                                            icon: Icon(Icons.edit, size: 20),
                                            color: Colors.grey,
                                            onPressed: () {
                                              setState(() {
                                                prefs.setString("addressbook",
                                                  "AddressbookScreen");
                                                Navigator.of(context).pushNamed(
                                                  ExampleScreen.routeName,
                                                  arguments: {
                                                    'addresstype': "edit",
                                                    'addressid': addressitemsData
                                                        .items[i].userid
                                                        .toString(),
                                                    'delieveryLocation': deliverylocation,
                                                    'latitude': "",
                                                    'longitude': "",
                                                    'branch': ""
                                                  });
                                              });
                                              },
                                          ),
                                          Container(
                                            height: 12,
                                            width: 1,
                                            child: VerticalDivider(
                                              color: Colors.black),
                                          ),
                                          IconButton(
                                              padding: EdgeInsets.all(0),
                                              icon: Icon(Icons.delete_outline,
                                                size: 20),
                                              color: Colors.grey,
                                              onPressed: () {
                                              _dialogforDeleteAdd(
                                                  context,
                                                  addressitemsData
                                                      .items[i].userid);
                                              }),
                                        ],
                                      ),*/
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          /* SizedBox(
                            height: 10.0,
                          ),*/
                          Padding(
                            padding: const EdgeInsets.only(left:30.0),
                            child: Column(
                              children: [
                                Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FlatButton(
                                      child:Text(
                                        translate('forconvience.EDIT'),//"EDIT",
                                        style: TextStyle(color:Theme.of(context).primaryColor,fontWeight: FontWeight.normal,fontSize: 14.0,),),
                                      padding: EdgeInsets.only(left:20),
                                      //  icon: Icon(Icons.edit, size: 20),
                                      // color: Colors.grey,
                                      onPressed: () {
                                        setState(() {
                                          prefs.setString("addressbook",
                                              "AddressbookScreen");
                                          Navigator.of(context).pushReplacementNamed(
                                              ExampleScreen.routeName,
                                              arguments: {
                                                'addresstype': "edit",
                                                'addressid': addressitemsData
                                                    .items[i].userid
                                                    .toString(),
                                                'delieveryLocation': deliverylocation,
                                                'latitude': addressitemsData
                                                    .items[i].userlat
                                                    .toString(),//"",
                                                'longitude': addressitemsData
                                                    .items[i].userlong
                                                    .toString(),//"",
                                                'branch': ""
                                              });
                                        });
                                      },
                                    ),
                                    /* Container(
                                      height: 12,
                                      width: 1,
                                      child: VerticalDivider(
                                          color: Colors.black),
                                    ),*/
                                    FlatButton(
                                        child:Text(
                                          translate('forconvience.DELETE'),//"DELETE",
                                          style: TextStyle(color:ColorCodes.banner,fontWeight: FontWeight.normal,fontSize: 14.0,),),
                                        padding: EdgeInsets.only(left:20),
                                        /*icon: Icon(Icons.delete_outline,
                                          size: 20),*/
                                        // color: Colors.grey,
                                        onPressed: () {
                                          // _dialogforSaveadd(context);
                                          _dialogforDeleteAdd(
                                              context,
                                              addressitemsData
                                                  .items[i].userid);
                                        }),

                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:25.0,right:25),
                                  child: Divider(color: ColorCodes.lightGreyColor,),
                                ),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ],
              )),
            ]
        )
    );
  }
  _bodyweb(){
    return  Expanded(
      child: !_addresscheck?SingleChildScrollView(
          child: Column(
              children: <Widget>[
                _isLoading
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
                    height: MediaQuery.of(context).size.height/**0.8*/,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          Images.noAddressImg,
                          fit: BoxFit.fill,
                          width: 200.0,
                          height: 200.0,
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Center(
                            child: Text(
                              translate('forconvience.saveaddress'),// "Save addresses to make home delivery more convenient.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 14.0),
                            )),
                        SizedBox(
                          height: 20.0,
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              prefs.setString("addressbook", "AddressbookScreen");
                              /*Navigator.of(context)
                                  .pushReplacementNamed(MapAddressScreen.routeName, arguments: {
                                'addresstype': "new",
                                'addressid': "",
                                'delieveryLocation': "",
                                'latitude': "",
                                'longitude': "",
                                'branch': ""
                              });*/
                              prefs.setString("addressbook", "AddressbookScreen");
                        Navigator.of(context)
                            .pushReplacementNamed(ExampleScreen.routeName, arguments: {
                          'addresstype': "new",
                          'addressid': "",
                          'delieveryLocation': "",
                          'latitude': "",
                          'longitude': "",
                          'branch': ""
                        });
                            },
                            child: Text(
                              translate('forconvience.Add Address'),//"Add Address",
                              style: TextStyle(
                                //fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Footer(address: _address),
              ]
          )
      ):SingleChildScrollView(
        child: Column(
            children:[
              _isLoading
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
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10.0,
                      ),
                      /*   Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Container(
                  child: RaisedButton(
                    onPressed: () {},
                    child: Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: ColorCodes.whiteColor,
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          prefs.setString(
                              "formapscreen", "addressbook_screen");
                          Navigator.of(context).pushNamed(MapScreen.routeName);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.gps_fixed),
                            Padding(padding: EdgeInsets.only(left: 5)),
                            Text(
                              'Choose Current Location',
                              style: TextStyle(
                                fontSize: 19,
                                color: ColorCodes.mediumBlackColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),*/

                      Padding(
                        padding: const EdgeInsets.only(
                          top: 25.0,
                          left: 20,
                          right: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Saved Addresses',
                              style: TextStyle(
                                fontSize: 19,
                                color: ColorCodes.greyColor,
                              ),
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  prefs.setString("addressbook", "AddressbookScreen");
                                  Navigator.of(context).pushReplacementNamed(ExampleScreen.routeName, arguments: {
                                    'addresstype': "new",
                                    'addressid': "",
                                    'delieveryLocation': "",
                                    'latitude': "",
                                    'longitude': "",
                                    'branch': ""
                                  });
                                },
                                child: Row(
                                  children: <Widget>[
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Icon(
                                      Icons.add,
                                      color: Theme.of(context).primaryColor,//ColorCodes.mediumBlueColor,
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Text(
                                      translate('forconvience.Add Address'),// "Add Address",
                                      style: TextStyle(
                                        //fontWeight: FontWeight.bold,
                                          fontSize: 19.0,
                                          color: Theme.of(context).primaryColor,//ColorCodes.mediumBlueColor
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      //Divider(),
                      //Padding(padding: EdgeInsets.only(top: 10)),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                      ),
                      Flexible(
                        // height: MediaQuery.of(context).size.height,
                        child: Container(
                          height: MediaQuery.of(context).size.height,
                          child: new ListView.builder(
                            physics: AlwaysScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: addressitemsData.items.length,
                            itemBuilder: (_, i) => Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 10, right: 10),
                                  //padding: EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: Container(
                                    //height: 50,
                                    margin: EdgeInsets.only(right: 10, bottom: 10),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,

                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.only(top: 15, bottom: 10),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                printAddress(context, i, addressitemsData.items[i].userid),
                                              ],
                                            ),
                                          ),
                                        ),
                                        //SizedBox(width: 20.0),
                                        //Spacer(),
                                        Padding(
                                          padding: EdgeInsets.only(left: 90),
                                        ),

                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),


                                Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 60,),
                                    FlatButton(
                                      child:Text(
                                        translate('forconvience.EDIT'),
                                        style: TextStyle(color: ColorCodes.whiteColor),//"Edit"
                                      ),

                                      // padding: EdgeInsets.only(left: 20),
                                      //  icon: Icon(Icons.edit, size: 20),
                                      color: Theme.of(context).primaryColor,
                                      onPressed: () {
                                        setState(() {
                                          prefs.setString("addressbook",
                                              "AddressbookScreen");
                                          Navigator.of(context).pushNamed(
                                              ExampleScreen.routeName,
                                              arguments: {
                                                'addresstype': "edit",
                                                'addressid': addressitemsData
                                                    .items[i].userid
                                                    .toString(),
                                                'delieveryLocation': deliverylocation,
                                                'latitude': "",
                                                'longitude': "",
                                                'branch': ""
                                              });
                                        });
                                      },
                                    ),
                                    SizedBox(width: 50,),
                                    Container(
                                      height: 12,
                                      width: 1,
                                      child: VerticalDivider(
                                          color: Colors.black),
                                    ),
                                    FlatButton(
                                        child:Text(
                                          translate('forconvience.DELETE'),//"Delete"
                                          style: TextStyle(color: ColorCodes.whiteColor),
                                        ),
                                        padding: EdgeInsets.all(0),
                                        /*icon: Icon(Icons.delete_outline,
                                    size: 20),*/
                                        color: Theme.of(context).primaryColor,
                                        onPressed: () {
                                          _dialogforDeleteAdd(
                                              context,
                                              addressitemsData
                                                  .items[i].userid);
                                        }),
                                  ],
                                ),
                                //Divider(color: Colors.grey,),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20,),
              if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Footer(address: _address),
            ]
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
      leading: IconButton(icon: Icon(Icons.arrow_back_ios_outlined,size: 20, color: ColorCodes.backbutton),
          onPressed: ()=>
          (_isWeb && !ResponsiveLayout.isSmallScreen(context)) ?

          Navigator.of(context).pushNamedAndRemoveUntil(
              '/home-screen', (Route<dynamic> route) => false)
              :
          Navigator.of(context).pop()),

      title: Text(
        translate('forconvience.My Adresses'), //'My Addresses',
        style: TextStyle(color: ColorCodes.backbutton),

        //'My Addresses',style: TextStyle(color: ColorCodes.whiteColor),
      ),
      titleSpacing: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors:<Color> [
                  ColorCodes.whiteColor,
                  ColorCodes.whiteColor,
                ]
            )
        ),
      ),
    );
  }
}



//mobile
/*
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../utils/ResponsiveLayout.dart';
import '../providers/addressfields.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/addressitems.dart';
import '../screens/address_screen.dart';
import '../constants/ColorCodes.dart';
import '../screens/map_screen.dart';
import '../screens/home_screen.dart';
import '../constants/images.dart';
import '../screens/example_screen.dart';
import 'package:flutter_translate/flutter_translate.dart';

enum FilterOptions {
  Edit,
  Delete,
}

class AddressbookScreen extends StatefulWidget {
  static const routeName = '/addressbook-screen';

  @override
  _AddressbookScreenState createState() => _AddressbookScreenState();
}

class _CustomRadioButton {
  bool buttonLables;
  bool buttonValues;
  bool radioButtonValue;
  bool buttonWidth;
  bool buttonList;

  _CustomRadioButton({
    this.buttonLables,
    this.buttonValues,
    this.radioButtonValue,
    this.buttonWidth,
    // this.buttonColor,
    // this.selectedColor,
    // this.buttonHeight,
    // this.horizontal,
    // this.enableShape,
    // this.elevation,
    // this.customShape,
    // this.fontSize,
    // this.lineSpace,
    // this.buttonSpace,
    // this.buttonBorderColor,
    // this.textColor,
    // this.selectedTextColor,
    // this.initialSelection,
    // this.unselectedButtonBorderColor
  });
}

class _AddressbookScreenState extends State<AddressbookScreen> {
  var addressitemsData;
  SharedPreferences prefs;
  var deliverylocation;
  bool _addresscheck = false;
  int _groupValue = 0;
  String singleAddress = '1';
  int value = 0;
  bool _isWeb = false;
  var _address = "";
  bool _isLoading = true;
  MediaQueryData queryData;
  double wid;
  double maxwid;

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

      setState(() {
        _address = prefs.getString("restaurant_address");
        deliverylocation= prefs.getString("deliverylocation");
        prefs.getString("lati");
        prefs.getString("long");
        Provider.of<AddressItemsList>(context,listen: false).fetchAddress().then((_) {
          setState(() {
            addressitemsData = Provider.of<AddressItemsList>(context, listen: false);
            if (addressitemsData.items.length <= 0) {
              _addresscheck = false;
              _isLoading = false;
            } else {
              _addresscheck = true;
              _isLoading = false;
            }
          });
        });
      });
    });

    super.initState();
  }

  void deleteaddress(String addressid) {
    _dialogforSaveadd(context);
    setState(() {
      _isLoading = true;
    });
    Provider.of<AddressItemsList>(context,listen: false).deleteAddress(addressid).then((_) {
      Provider.of<AddressItemsList>(context,listen: false).fetchAddress().then((_) {
        setState(() {
          Navigator.of(context).pop();
          addressitemsData =
              Provider.of<AddressItemsList>(context, listen: false);
          if (addressitemsData.items.length <= 0) {
            _addresscheck = false;
            _isLoading = false;
          } else {
            _addresscheck = true;
            _isLoading = false;
          }
        });
      });
    });
  }

  void setDefaultAddress(String addressid) {
    Provider.of<AddressItemsList>(context,listen: false)
        .setDefaultAddress(addressid)
        .then((_) {
      */
/*Provider.of<AddressItemsList>(context, listen: false).fetchAddress().then((_) {*//*

      setState(() {
        addressitemsData =
            Provider.of<AddressItemsList>(context, listen: false);
        if (addressitemsData.items.length <= 0) {
          _addresscheck = false;
          _isLoading = false;
        } else {
          _addresscheck = true;
          _isLoading = false;
        }
      });
    });
  }

  Widget printAddress(BuildContext context, i, String addressid) {
    if (addressitemsData.items[i].addressdefault == '1') {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pop(true);
        },
        child: Container(
          //height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.only(left: 20)),
              Align(
                  alignment: Alignment.topLeft,
                  child: Icon(Icons.radio_button_checked,
                      size: 18, color: ColorCodes.mediumBlueColor)),
              Padding(padding: EdgeInsets.only(left: 10)),
              Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          translate('forconvience.defaultaddress'), //'Default Address:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xff3B3939),
                          ),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 5)),


                      new RichText(textAlign: TextAlign.start,
                        text: new TextSpan(

                          // Note: Styles for TextSpans must be explicitly defined.
                          // Child text spans will inherit styles from parent
                          style: new TextStyle(
                            fontSize: 15.0,
                            color: Colors.grey,
                          ),
                          children: <TextSpan>[
                            new TextSpan(text: addressitemsData.items[i].useraddtype+"\n",
                            style:new TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: ColorCodes.blackColor), ),
                            new TextSpan(
                                text: addressitemsData.items[i].useraddress,
                                style:new TextStyle(fontSize: 14)
                               // style: new TextStyle(color: ColorCodes.darkgreen),
                                ),

                          ],
                        ),
                      ),
                     */
/* Text(
                        addressitemsData.items[i].useraddtype+  "\n" +addressitemsData.items[i].useraddress,
                        style: TextStyle(
                          fontSize: 14,
                          color: ColorCodes.greyColor,
                        ),
                      ),*//*

                    ],
                  )),
            ],
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () async {
          setDefaultAddress(addressid);
          //UpdateAddress(addressid,latitude,longitude,branch);
          // Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
          Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
          //Navigator.of(context).pop(true);
        },
        child: Container(
          // height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.only(left: 20)),
              Align(
                  alignment: Alignment.topLeft,
                  child: Icon(Icons.radio_button_unchecked,
                      size: 18, color: ColorCodes.mediumBlueColor)),
              Padding(padding: EdgeInsets.only(left: 10)),
              Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    children: [
                      */
/*Text(
                        addressitemsData.items[i].useraddtype+  "\n" +addressitemsData.items[i].useraddress ,
                        style: TextStyle(
                          fontSize: 14,
                          color: ColorCodes.greyColor,
                        ),
                      ),*//*

                      new RichText(
                        textAlign: TextAlign.start,
                        text: new TextSpan(

                          // Note: Styles for TextSpans must be explicitly defined.
                          // Child text spans will inherit styles from parent
                          style: new TextStyle(
                            fontSize: 15.0,
                            color: Colors.grey,
                          ),
                          children: <TextSpan>[
                            new TextSpan(text: addressitemsData.items[i].useraddtype+"\n",
                              style:new TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: ColorCodes.blackColor), ),
                            new TextSpan(
                                text: addressitemsData.items[i].useraddress,
                                style:new TextStyle(fontSize: 14)
                              // style: new TextStyle(color: ColorCodes.darkgreen),
                            ),

                          ],
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      );
    }
  }

  Widget _myRadioButton({int value, Function onChanged}) {
    return Radio(
      value: value,
      groupValue: _groupValue,
      onChanged: onChanged,
    );
  }

  _dialogforDeleteAdd(BuildContext context, String addressid) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                  width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.40:MediaQuery.of(context).size.width,
                  height: 100.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Text(
                          translate('forconvience.delete'), //'Are you sure you want to delete this address?',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        children: <Widget>[
                          Spacer(),
                          GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop(true);
                              },
                              child: Text(
                                translate('forconvience.no'), //'NO',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 14.0),
                              )),
                          SizedBox(
                            width: 20.0,
                          ),
                          GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop(true);

                                deleteaddress(addressid);
                              },
                              child: Text(
                                translate('forconvience.YES'),//'YES',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 14.0),
                              )),
                          SizedBox(
                            width: 20.0,
                          ),
                        ],
                      )
                    ],
                  )),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    wid= queryData.size.width;
    maxwid=wid*0.90;

    return Scaffold(
        appBar: ResponsiveLayout.isSmallScreen(context) ?
        gradientappbarmobile() : null,
        backgroundColor: Colors.white,
        body:Column(
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
              )
              :
              _body(),
            ]
        )
    );


  }

  _dialogforSaveadd(BuildContext context) {
    return showDialog(context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0)
                  ),
                  child: Container(
                      height: 100.0,
                      child:
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                          ),
                          SizedBox(width: 40.0,),
                          Text(
                            translate('forconvience.deleting'),
                              //'Deleting...'
                          ),
                        ],
                      )
                  ),
                );
              }
          );
        });
  }
_body(){
    return _isWeb?_bodyweb():
    _bodymobile();
}
_bodymobile(){
    return Expanded(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              !_addresscheck
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    Images.noAddressImg,
                    fit: BoxFit.fill,
                    width: 200.0,
                    height: 200.0,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Center(
                      child: Text(
                        translate('forconvience.saveaddress'),// "Save addresses to make home delivery more convenient.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 14.0),
                      )),
                  SizedBox(
                    height: 20.0,
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        prefs.setString("addressbook", "AddressbookScreen");
                        Navigator.of(context)
                          .pushReplacementNamed(ExampleScreen .routeName, arguments: {
                        'addresstype': "new",
                        'addressid': "",
                        'delieveryLocation': "",
                        'latitude': "",
                        'longitude': "",
                        'branch': ""
                          });
                        },
                      child: Text(
                        translate('forconvience.Add Address'), //"Add Address",
                        style: TextStyle(
                        //fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                ],
              )
                  : Expanded(child:Column(
                children: <Widget>[
                  SizedBox(
                    height: 10.0,
                  ),

                  */
/*Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Container(
                      child: RaisedButton(
                        onPressed: () {},
                        child: Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: ColorCodes.whiteColor,
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              prefs.setString(
                                "formapscreen", "addressbook_screen");
                              Navigator.of(context)
                                .pushNamed(MapScreen.routeName);
                              },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.gps_fixed),
                                Padding(padding: EdgeInsets.only(left: 5)),
                                Text(
                                'Choose Current Location',
                                  style: TextStyle(
                                    fontSize: 19,
                                    color: ColorCodes.mediumBlackColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),*//*


                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10.0,
                      left: 20,
                      right: 28,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                       */
/* Text(
                        'Saved Addresses',
                          style: TextStyle(
                            fontSize: 19,
                            color: ColorCodes.greyColor,
                          ),
                        ),*//*

                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              prefs.setString("addressbook", "AddressbookScreen");
                              Navigator.of(context)
                                .pushReplacementNamed(ExampleScreen.routeName, arguments: {
                              'addresstype': "new",
                              'addressid': "",
                              'delieveryLocation': "",
                              'latitude': "",
                              'longitude': "",
                              'branch': ""
                                });
                              },
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 10.0,
                                ),
                                Icon(
                                  Icons.add,
                                  color:  Theme.of(context).primaryColor,
                                ),
                                SizedBox(
                                  width: 6.0,
                                ),
                                Text(
                                  translate('forconvience.Add Address'), //"Add Address",
                                  style: TextStyle(
                                  //fontWeight: FontWeight.bold,
                                      fontSize: 19.0,
                                      color: Theme.of(context).primaryColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                //Divider(),
                //Padding(padding: EdgeInsets.only(top: 10)),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                  ),
                  Expanded(
                    child: new ListView.builder(
                      itemCount: addressitemsData.items.length,
                      itemBuilder: (_, i) => Column(
                        children: [
                          Container(
                            width:MediaQuery.of(context).size.width,
                            margin: EdgeInsets.only(left: 10, right: 10),
                          //padding: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Container(
                            //height: 50,
                              margin: EdgeInsets.only(right: 10, ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal:10.0),
                                    child: Row(
                                      children: [
                                       */
/* Icon( addressitemsData.items[i].addressicon,color: ColorCodes.lightGreyColor,),
                                        Padding(
                                          padding: const EdgeInsets.only(left:5.0),
                                          child: Text(addressitemsData.items[i].useraddtype.toString()),
                                        ),*//*


                                       */
/* CachedNetworkImage(
                                          imageUrl: addressitemsData.items[i].addressicon,
                                         *//*
*/
/* placeholder: (context, url) => Image.asset(
                                              Images.defaultCategoryImg),*//*
*/
/*

                                          height: ResponsiveLayout.isSmallScreen(context)?100:120,
                                          width: ResponsiveLayout.isSmallScreen(context)?115:160,
                                          //fit: BoxFit.fill,
                                        ) ,*//*

                                      ],
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.only(top: 15),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              printAddress(context, i,
                                                addressitemsData.items[i].userid),
                                            */
/*  Padding(
                                                padding: const EdgeInsets.only(left:15.0),
                                                child: Text(addressitemsData.items[i].useraddtype.toString()),
                                              ),*//*

                                            ],
                                          ),
                                        ),
                                      ),
                                    //SizedBox(width: 20.0),
                                    //Spacer(),
                                     */
/* Padding(
                                        padding: EdgeInsets.only(left: 90),
                                      ),*//*


                                      */
/*Row(
                                      //crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          IconButton(
                                            padding: EdgeInsets.all(0),
                                            icon: Icon(Icons.edit, size: 20),
                                            color: Colors.grey,
                                            onPressed: () {
                                              setState(() {
                                                prefs.setString("addressbook",
                                                  "AddressbookScreen");
                                                Navigator.of(context).pushNamed(
                                                  ExampleScreen.routeName,
                                                  arguments: {
                                                    'addresstype': "edit",
                                                    'addressid': addressitemsData
                                                        .items[i].userid
                                                        .toString(),
                                                    'delieveryLocation': deliverylocation,
                                                    'latitude': "",
                                                    'longitude': "",
                                                    'branch': ""
                                                  });
                                              });
                                              },
                                          ),
                                          Container(
                                            height: 12,
                                            width: 1,
                                            child: VerticalDivider(
                                              color: Colors.black),
                                          ),
                                          IconButton(
                                              padding: EdgeInsets.all(0),
                                              icon: Icon(Icons.delete_outline,
                                                size: 20),
                                              color: Colors.grey,
                                              onPressed: () {
                                              _dialogforDeleteAdd(
                                                  context,
                                                  addressitemsData
                                                      .items[i].userid);
                                              }),
                                        ],
                                      ),*//*

                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                         */
/* SizedBox(
                            height: 10.0,
                          ),*//*

                          Padding(
                            padding: const EdgeInsets.only(left:30.0),
                            child: Column(
                              children: [
                                Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FlatButton(
                                      child:Text(
                                        translate('forconvience.EDIT'),//"EDIT",
                                        style: TextStyle(color:Theme.of(context).primaryColor,fontWeight: FontWeight.normal,fontSize: 14.0,),),
                                      padding: EdgeInsets.only(left:20),
                                      //  icon: Icon(Icons.edit, size: 20),
                                     // color: Colors.grey,
                                      onPressed: () {
                                        setState(() {
                                          prefs.setString("addressbook",
                                              "AddressbookScreen");
                                          Navigator.of(context).pushNamed(
                                              ExampleScreen.routeName,
                                              arguments: {
                                                'addresstype': "edit",
                                                'addressid': addressitemsData
                                                    .items[i].userid
                                                    .toString(),
                                                'delieveryLocation': deliverylocation,
                                                'latitude': "",
                                                'longitude': "",
                                                'branch': ""
                                              });
                                        });
                                      },
                                    ),
                                   */
/* Container(
                                      height: 12,
                                      width: 1,
                                      child: VerticalDivider(
                                          color: Colors.black),
                                    ),*//*

                                    FlatButton(
                                        child:Text(
                                          translate('forconvience.DELETE'),//"DELETE",
                                          style: TextStyle(color:ColorCodes.banner,fontWeight: FontWeight.normal,fontSize: 14.0,),),
                                        padding: EdgeInsets.only(left:20),
                                        */
/*icon: Icon(Icons.delete_outline,
                                          size: 20),*//*

                                       // color: Colors.grey,
                                        onPressed: () {
                                         // _dialogforSaveadd(context);
                                          _dialogforDeleteAdd(
                                              context,
                                              addressitemsData
                                                  .items[i].userid);
                                        }),

                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:25.0,right:25),
                                  child: Divider(color: ColorCodes.lightGreyColor,),
                                ),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ],
              )),
            ]
        )
    );
}
_bodyweb(){
    return  Expanded(
        child: !_addresscheck?SingleChildScrollView(
            child: Column(
                children: <Widget>[
                  _isLoading
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
                        height: MediaQuery.of(context).size.height*/
/**0.8*//*
,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              Images.noAddressImg,
                              fit: BoxFit.fill,
                              width: 200.0,
                              height: 200.0,
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Center(
                                child: Text(
                                  translate('forconvience.saveaddress'), //"Save addresses to make home delivery more convenient.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey, fontSize: 14.0),
                                )),
                            SizedBox(
                              height: 20.0,
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  prefs.setString("addressbook", "AddressbookScreen");
                                  Navigator.of(context)
                              .pushReplacementNamed(ExampleScreen.routeName, arguments: {
                                'addresstype': "new",
                                    'addressid': "",
                                    'delieveryLocation': "",
                                    'latitude': "",
                                    'longitude': "",
                                    'branch': ""
                              });
                                  },
                                child: Text(
                                  translate('forconvience.Add Address'), // "Add Address",
                                  style: TextStyle(
                          //fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                  ),
                  ),
                  SizedBox(height: 20,),
                  if(_isWeb) Footer(address: _address),
                ]
            )
        ):SingleChildScrollView(
          child: Column(
            children:[
              _isLoading
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
              height: MediaQuery.of(context).size.height,
              child: Column(
              children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
           */
/*   Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Container(
                  child: RaisedButton(
                    onPressed: () {},
                    child: Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: ColorCodes.whiteColor,
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          prefs.setString(
                              "formapscreen", "addressbook_screen");
                          Navigator.of(context).pushNamed(MapScreen.routeName);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.gps_fixed),
                            Padding(padding: EdgeInsets.only(left: 5)),
                            Text(
                              'Choose Current Location',
                              style: TextStyle(
                                fontSize: 19,
                                color: ColorCodes.mediumBlackColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),*//*


              Padding(
                padding: const EdgeInsets.only(
                  top: 25.0,
                  left: 20,
                  right: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                   */
/* Text(
                      'Saved Addresses',
                      style: TextStyle(
                        fontSize: 19,
                        color: ColorCodes.greyColor,
                      ),
                    ),*//*

                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          prefs.setString("addressbook", "AddressbookScreen");
                          Navigator.of(context).pushReplacementNamed(ExampleScreen.routeName, arguments: {
                            'addresstype': "new",
                            'addressid': "",
                            'delieveryLocation': "",
                            'latitude': "",
                            'longitude': "",
                            'branch': ""
                          });
                        },
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 10.0,
                            ),
                            Icon(
                              Icons.add,
                              color: ColorCodes.mediumBlueColor,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              translate('forconvience.Add Address'),  // "Add Address",
                              style: TextStyle(
                                //fontWeight: FontWeight.bold,
                                  fontSize: 19.0,
                                  color: ColorCodes.mediumBlueColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //Divider(),
              //Padding(padding: EdgeInsets.only(top: 10)),
              Container(
                margin: EdgeInsets.only(top: 10),
              ),
              Flexible(
                // height: MediaQuery.of(context).size.height,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  child: new ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: addressitemsData.items.length,
                    itemBuilder: (_, i) => Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 10, right: 10),
                          //padding: EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Container(
                            //height: 50,
                            margin: EdgeInsets.only(right: 10, bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(top: 15, bottom: 10),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        printAddress(context, i, addressitemsData.items[i].userid),
                                      ],
                                    ),
                                  ),
                                ),
                                //SizedBox(width: 20.0),
                                //Spacer(),
                                Padding(
                                  padding: EdgeInsets.only(left: 90),
                                ),


                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),


                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FlatButton(
                                child:Text(
                                  translate('forconvience.EDIT'),
                                  style: TextStyle(color: ColorCodes.whiteColor),// "Edit"
                                ),
                                padding: EdgeInsets.only(left:20),
                              //  icon: Icon(Icons.edit, size: 20),
                                color: Theme.of(context).primaryColor,//Colors.grey,
                                onPressed: () {
                                  setState(() {
                                    prefs.setString("addressbook",
                                        "AddressbookScreen");
                                    Navigator.of(context).pushNamed(
                                        ExampleScreen.routeName,
                                        arguments: {
                                          'addresstype': "edit",
                                          'addressid': addressitemsData
                                              .items[i].userid
                                              .toString(),
                                          'delieveryLocation': deliverylocation,
                                          'latitude': "",
                                          'longitude': "",
                                          'branch': ""
                                        });
                                  });
                                },
                              ),
                              Container(
                                height: 12,
                                width: 1,
                                child: VerticalDivider(
                                    color: Colors.black),
                              ),
                              SizedBox(width:20),
                              FlatButton(
                                child:Text(
                                  translate('forconvience.DELETE'),// "Delete"
                                  style: TextStyle(color: ColorCodes.whiteColor),
                                ),

                                  padding: EdgeInsets.all(0),
                                  */
/*icon: Icon(Icons.delete_outline,
                                      size: 20),*//*

                                  color: Theme.of(context).primaryColor,
                                  onPressed: () {
                                    _dialogforDeleteAdd(
                                        context,
                                        addressitemsData
                                            .items[i].userid);
                                  }),
                            ],
                          ),
                        ),
                        //Divider(color: Colors.grey,),
                      ],
                    ),
                  ),
                ),
              ),
              ],
        ),
            ),
          ),
              SizedBox(height: 20,),
              if(_isWeb) Footer(address: _address),
            ]
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
      leading: IconButton(icon: Icon(Icons.arrow_back_ios_outlined,size: 20, color: ColorCodes.backbutton),onPressed: ()=>Navigator.of(context).pop()),
      title: Text(
        translate('forconvience.My Adresses'), //'My Addresses',
        style: TextStyle(color: ColorCodes.backbutton),
      ),
      titleSpacing: 0,
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
}
*/
