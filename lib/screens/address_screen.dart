import 'dart:io';
import '../screens/mobile_authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../utils/ResponsiveLayout.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../screens/return_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/addressitems.dart';
import '../screens/addressbook_screen.dart';
import '../screens/confirmorder_screen.dart';
import '../screens/map_screen.dart';
import '../screens/map_address_screen.dart';
import 'home_screen.dart';
import '../constants/ColorCodes.dart';
import 'package:flutter_translate/flutter_translate.dart';

class AddressScreen extends StatefulWidget {
  static const routeName = '/address-screen';

  @override
  _AddressScreenState createState() => _AddressScreenState();

}

class _AddressScreenState extends State<AddressScreen> {
  SharedPreferences prefs;
  var _home = Color(0xff035733);
  var _work = Colors.grey;
  var _other = Colors.grey;
  var _addresstag = "home";
  double _homeWidth = 2.0;
  double _workWidth = 1.0;
  double _otherWidth = 1.0;
  bool _isLoading = false;
  String addresstype = "";
  String addressid = "";
  final _form = GlobalKey<FormState>();
  bool _isChecked = false;
  String _deliverylocation = "";
  String _latitude = "";
  String _longitude = "";
  String _branch = "";
  var _isWeb= false;
  MediaQueryData queryData;
  double wid;
  double maxwid;

  TextEditingController _controllerHouseno = new TextEditingController();
  TextEditingController _controllerApartment = new TextEditingController();
  TextEditingController _controllerStreet = new TextEditingController();
  TextEditingController _controllerLandmark = new TextEditingController();
  TextEditingController _controllerArea = new TextEditingController();
  TextEditingController _controllerPincode = new TextEditingController();

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
      if(routeArgs['delieveryLocation'] == "") {
        setState(() {
          _deliverylocation = prefs.getString("deliverylocation");
          _latitude = prefs.getString('latitude');
          _longitude = prefs.getString('longitude');
          _branch = prefs.getString("branch");
          debugPrint("lataddemp"+_latitude);
          debugPrint("longaddwmp"+_longitude);
        });
      } else {
        setState(() {
          _deliverylocation = routeArgs['delieveryLocation'];
          _latitude = routeArgs['latitude'];
          _longitude = routeArgs['longitude'];
          _branch = routeArgs['branch'];
debugPrint("latadd"+_latitude.toString());
          debugPrint("longadd"+_longitude.toString());
          _controllerHouseno.text = routeArgs['houseNo'];
          _controllerApartment.text = routeArgs['apartment'];
          _controllerStreet.text = routeArgs['street'];
          _controllerLandmark.text = routeArgs['landmark'];
          _controllerArea.text = routeArgs['area'];
          _controllerPincode.text = routeArgs['pincode'];
        });
      }

      _controllerHouseno.text=_deliverylocation;
    });
    super.initState();
  }

  @override
  void dispose() {
    _controllerHouseno.dispose();
    _controllerApartment.dispose();
    _controllerStreet.dispose();
    _controllerLandmark.dispose();
    _controllerArea.dispose();
    _controllerPincode.dispose();
    super.dispose();
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
                            translate('forconvience.Saving'),
                //'Saving...'
                 ),
                        ],
                      )
                  ),
                );
              }
          );
        });
  }

  _saveaddress() async {

    prefs.setString('newaddresstype', _addresstag);
    debugPrint("addresstag"+_addresstag.toString());
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    } else {
      _dialogforSaveadd(context);
      setState(() {
        _isLoading = true;
      });

      String apartment;
      String street;
      String landmark;
      String pincode;

      if(_controllerApartment.text == "") {
        apartment = "";
      } else {
        apartment = ", " + _controllerApartment.text;
      }

      if(_controllerStreet.text == "") {
        street = "";
      } else {
        street = ", " + _controllerStreet.text;
      }

      if(_controllerLandmark.text == "") {
        landmark = "";
      } else {
        landmark = ", " + _controllerLandmark.text;
      }

      if(_controllerPincode.text == "") {
        pincode = "";
      } else {
        pincode = ", " + _controllerPincode.text;
      }
     /* debugPrint("location"+_deliverylocation);
      debugPrint("house"+_controllerHouseno.text);
      debugPrint("location"+_deliverylocation);
      debugPrint("location"+_deliverylocation);*/
      prefs.setString('newaddress', (_controllerHouseno.text + apartment + street + landmark + ", " + _controllerArea.text + ", " + _deliverylocation + " - " + pincode));
      if(addresstype == "edit") {
        Provider.of<AddressItemsList>(context,listen: false).UpdateAddress(addressid, _latitude, _longitude, _branch).then((_) {
          Provider.of<AddressItemsList>(context,listen: false).fetchAddress().then((_) {
            _isLoading = false;
            if (prefs.containsKey("addressbook")) {
              if (prefs.getString("addressbook") == "AddressbookScreen") {
                prefs.setString("addressbook", "");
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed(
                    AddressbookScreen.routeName);
              }else if (prefs.getString("addressbook") == "returnscreen") {
                Navigator.of(context).pushReplacementNamed(
                    ReturnScreen.routeName);
              } else {
                Navigator.of(context).pop();
                if (prefs.getString('mobile').toString()!="null") {
                  debugPrint("present");
                  prefs.setString("isPickup", "no");
                  Navigator.of(context).pushReplacementNamed(
                      ConfirmorderScreen.routeName,
                      arguments: {"prev": "cart_screen"});
                }
                else{
                  debugPrint(" not present");
                  debugPrint("mobile" +"if");
                  //prefs.setString('prevscreen', "confirmorder");
                  Navigator.of(context)
                      .pushNamed(MobileAuthScreen.routeName,);
                }
              /*  Navigator.of(context).pushReplacementNamed(
                    ConfirmorderScreen.routeName,
                    arguments: {
                      "prev": "address_screen",
                    }
                );*/
              }
            }
            else {
              Navigator.of(context).pop();
              debugPrint("address"+prefs.getString('mobile').toString());
              if (prefs.getString('mobile').toString()!="null") {
                debugPrint("present");
                prefs.setString("isPickup", "no");
                Navigator.of(context).pushReplacementNamed(
                    ConfirmorderScreen.routeName,
                    arguments: {"prev": "cart_screen"});
              }
              else{
                debugPrint(" not present");
                debugPrint("mobile" +"if");
                //prefs.setString('prevscreen', "confirmorder");
                Navigator.of(context)
                    .pushNamed(MobileAuthScreen.routeName,);
              }
             /* Navigator.of(context).pushReplacementNamed(
                  ConfirmorderScreen.routeName,
                  arguments: {
                    "prev": "address_screen",
                  }
              );*/
            }
          });
        });
      } else {

        Provider.of<AddressItemsList>(context,listen: false).NewAddress(_latitude, _longitude, _branch).then((_) {
          Provider.of<AddressItemsList>(context,listen: false).fetchAddress().then((_) {
            _isLoading = false;
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed(
                MapAddressScreen.routeName,
                arguments: {
                  "address": (_controllerHouseno.text + apartment + street + landmark + ", " + _controllerArea.text + ", "),
                  "pincode": pincode,
                }
            );
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: ResponsiveLayout.isSmallScreen(context) ?
      gradientappbarmobile() : null,
      backgroundColor: Colors.white,
      body:  Column(
        children: <Widget>[
          if(_isWeb && !ResponsiveLayout.isSmallScreen(context))
            Header(true),
          _body(),
        ],
      ),
      bottomNavigationBar: _isWeb ? SizedBox.shrink() : _buildBottomNavigationBar(),
    );
  }
  _buildBottomNavigationBar() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          _saveaddress();
        },
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).primaryColor,
            height: 50.0,
            child: Center(
              child: Text(
                "SAVE ADDRESS",
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  _body(){
    return _isWeb?_bodyweb():
    _bodymobile();
  }
  _bodymobile(){
    return Expanded(
      child: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
        ),
      ) :
      SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Form(
                key: _form,
                child: Container(
                  margin: EdgeInsets.only(left: 20.0, top: 20.0, right: 20),
                  child: Column(
                    children: <Widget>[
                      Container(
                        //width: MediaQuery.of(context).size.width ,
                        child: TextFormField(
                          controller: _controllerHouseno,
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                              hintText: "*Address",
                              hintStyle: new TextStyle(
                                fontSize: 14.0,
                                color: Colors.black54,
                              ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: Colors.green),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: Colors.green),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: Colors.green),
                            ),
                          ),




                          onFieldSubmitted: (_) {
                            //FocusScope.of(context).requestFocus(_lnameFocusNode);
                          },
                          validator: (value) {
                            if(value.isEmpty) {
                              return "Please enter Address";
                            }
                            return null; //it means user entered a valid input
                          },
                        ),
                      ),
                     /* Row(
                        children: <Widget>[

                         *//* SizedBox(width: 20.0,),
                          Expanded(
                            child: TextFormField(
                              controller: _controllerApartment,
                              textAlign: TextAlign.left,
                              decoration: InputDecoration(
                                  labelText: "Apartment name",
                                  labelStyle: new TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black54,
                                  )
                              ),
                              onFieldSubmitted: (_) {
                                //FocusScope.of(context).requestFocus(_lnameFocusNode);
                              },
                            ),
                          ),*//*
                        ],
                      ),*/
                      SizedBox(height: 20.0,),
                      TextFormField(
                        controller: _controllerStreet,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                            hintText: "Quartier,Apartment etc",
                            hintStyle: new TextStyle(
                              fontSize: 14.0,
                              color: Colors.black54,
                            ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.green),
                          ),
                        ),

                        onFieldSubmitted: (_) {
                          //FocusScope.of(context).requestFocus(_lnameFocusNode);
                        },
                      ),
                      SizedBox(height: 20.0,),
                     /* TextFormField(
                        controller: _controllerLandmark,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                            labelText: "Landmark for easy reach out",
                            labelStyle: new TextStyle(
                              fontSize: 14.0,
                              color: Colors.black54,
                            )
                        ),
                        onFieldSubmitted: (_) {
                          //FocusScope.of(context).requestFocus(_lnameFocusNode);
                        },
                      ),*/
                      SizedBox(height: 5.0,),
                      TextFormField(
                        controller: _controllerArea,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                            hintText: "Ville",
                            hintStyle: new TextStyle(
                              fontSize: 14.0,
                              color: Colors.black54,
                            ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.green),
                          ),
                        ),
                        onFieldSubmitted: (_) {
                          //FocusScope.of(context).requestFocus(_lnameFocusNode);
                        },
                        validator: (value) {
                          if(value.isEmpty) {
                            return 'Please enter Ville';
                          }
                          return null; //it means user entered a valid input
                        },
                      ),
                      SizedBox(height: 5.0,),
                    /*  Row(
                        children: <Widget>[
                          Expanded(
                            child:
                             GestureDetector(
                              onTap: () async {
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                prefs.setString("formapscreen", "addressscreen");
                                Navigator.of(context).pushNamed(MapScreen.routeName,
                                    arguments: {
                                      "houseNo" : _controllerHouseno.text,
                                      "apartment" : _controllerApartment.text,
                                      "street" :  _controllerStreet.text,
                                      "landmark" : _controllerLandmark.text,
                                      "area" : _controllerArea.text,
                                      "pincode" : _controllerPincode.text,
                                    }
                                );
                              },
                              child: TextFormField(
                                textAlign: TextAlign.left,
                                enabled: false,
                                decoration: InputDecoration(
                                    labelText: _deliverylocation,
                                    labelStyle: new TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.black,
                                    )
                                ),
                                onFieldSubmitted: (_) {
                                  //FocusScope.of(context).requestFocus(_lnameFocusNode);
                                },
                              ),
                            ),
                          ),
                          GestureDetector(
                              onTap: () async {
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                prefs.setString("formapscreen", "addressscreen");
                                Navigator.of(context).pushNamed(MapScreen.routeName,
                                    arguments: {
                                      "houseNo" : _controllerHouseno.text,
                                      "apartment" : _controllerApartment.text,
                                      "street" :  _controllerStreet.text,
                                      "landmark" : _controllerLandmark.text,
                                      "area" : _controllerArea.text,
                                      "pincode" : _controllerPincode.text,
                                    }
                                );
                              },
                              child: Icon(Icons.edit, size: 15.0,)),
                          //SizedBox(width: 30.0,),
                         *//* Container(
                            width: MediaQuery.of(context).size.width * 35 / 100,
                            child: TextFormField(
                              controller: _controllerPincode,
                              textAlign: TextAlign.left,
                              decoration: InputDecoration(
                                  labelText: "Pincode",
                                  labelStyle: new TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black54,
                                  )
                              ),
                              onFieldSubmitted: (_) {
                                //FocusScope.of(context).requestFocus(_lnameFocusNode);
                              },
                            ),
                          ),*//*
                        ],
                      ),*/
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 20.0),
                child: Column(
                  children: [
                    SizedBox(height: 20.0,),
                    Text("Choose nick name for this address", style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black54,
                    ),),
                    SizedBox(height: 10.0,),
                  ],
                ),
              ),

              Container(
                margin: EdgeInsets.only(left: 20.0),
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _addresstag = "Home";
                          _home = Theme.of(context).primaryColor;
                          _work = Colors.grey;
                          _other = Colors.grey;
                          _homeWidth = 2.0;
                          _workWidth = 1.0;
                          _otherWidth = 1.0;
                        });
                      },
                      child: Container(
                        width: 60.0,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(3.0),
                            border: Border(
                              top: BorderSide(width: _homeWidth, color: _home,),
                              bottom: BorderSide(width: _homeWidth, color: _home,),
                              left: BorderSide(width: _homeWidth, color: _home),
                              right: BorderSide(width: _homeWidth, color: _home),
                            )),
                        height: 35.0,
                        child: Center(
                          child: Text(
                            "Home",
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15.0,),
                    GestureDetector(
                      //behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          _addresstag = "Work";
                          _home = Colors.grey;
                          _work = Theme.of(context).primaryColor;
                          _other = Colors.grey;
                          _homeWidth = 1.0;
                          _workWidth = 2.0;
                          _otherWidth = 1.0;
                        });
                      },
                      child: Container(
                        width: 60.0,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(3.0),
                            border: Border(
                              top: BorderSide(width: _workWidth, color: _work,),
                              bottom: BorderSide(width: _workWidth, color: _work,),
                              left: BorderSide(width: _workWidth, color: _work,),
                              right: BorderSide(width: _workWidth, color: _work,),
                            )),
                        height: 35.0,
                        child: Center(
                          child: Text(
                            "Office",
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15.0,),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _addresstag = "Other";
                          _home = Colors.grey;
                          _work = Colors.grey;
                          _other = Theme.of(context).primaryColor;
                          _homeWidth = 1.0;
                          _workWidth = 1.0;
                          _otherWidth = 2.0;
                        });
                      },
                      child: Container(
                        width: 60,
                        height: 35.0,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(3.0),
                            border: Border(
                              top: BorderSide(width: _otherWidth, color: _other,),
                              bottom: BorderSide(width: _otherWidth, color: _other,),
                              left: BorderSide(width: _otherWidth, color: _other,),
                              right: BorderSide(width: _otherWidth, color: _other,),
                            )),
                        child: Center(
                          child: Text(
                            "Other",
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              // Container(
              //   margin: EdgeInsets.only(left: 9, top: 10,),
              //   child: CheckboxListTile(
              //     contentPadding: EdgeInsets.all(0),
              //     title: Text('Set this as my default delivery address'),
              //     value: _isChecked,
              //     controlAffinity: ListTileControlAffinity.leading,
              //     onChanged: (bool value) {
              //       setState(() {
              //         _isChecked = value;
              //       });
              //     },
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
  _bodyweb(){
    queryData = MediaQuery.of(context);
    wid= queryData.size.width;
    maxwid=wid*0.90;
    return    Expanded(
      child: SingleChildScrollView(
        child: Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              Container(
                constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,
                // margin: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Form(
                      key: _form,
                      child: Container(
                        margin: EdgeInsets.only(left: 20.0, top: 20.0, right: 20),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width * 30 / 100,
                                  child: TextFormField(
                                    controller: _controllerHouseno,
                                    textAlign: TextAlign.left,
                                    decoration: InputDecoration(
                                        labelText: "*House no",
                                        labelStyle: new TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black54,
                                        )
                                    ),
                                    onFieldSubmitted: (_) {
                                      //FocusScope.of(context).requestFocus(_lnameFocusNode);
                                    },
                                    validator: (value) {
                                      if(value.isEmpty) {
                                        return "Please enter House no";
                                      }
                                      return null; //it means user entered a valid input
                                    },
                                  ),
                                ),
                                SizedBox(width: 20.0,),
                                Expanded(
                                  child: TextFormField(
                                    controller: _controllerApartment,
                                    textAlign: TextAlign.left,
                                    decoration: InputDecoration(
                                        labelText: "Apartment name",
                                        labelStyle: new TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black54,
                                        )
                                    ),
                                    onFieldSubmitted: (_) {
                                      //FocusScope.of(context).requestFocus(_lnameFocusNode);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5.0,),
                            TextFormField(
                              controller: _controllerStreet,
                              textAlign: TextAlign.left,
                              decoration: InputDecoration(
                                  labelText: "Street details to locate you",
                                  labelStyle: new TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black54,
                                  )
                              ),
                              onFieldSubmitted: (_) {
                                //FocusScope.of(context).requestFocus(_lnameFocusNode);
                              },
                            ),
                            SizedBox(height: 5.0,),
                            TextFormField(
                              controller: _controllerLandmark,
                              textAlign: TextAlign.left,
                              decoration: InputDecoration(
                                  labelText: "Landmark for easy reach out",
                                  labelStyle: new TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black54,
                                  )
                              ),
                              onFieldSubmitted: (_) {
                                //FocusScope.of(context).requestFocus(_lnameFocusNode);
                              },
                            ),
                            SizedBox(height: 5.0,),
                            TextFormField(
                              controller: _controllerArea,
                              textAlign: TextAlign.left,
                              decoration: InputDecoration(
                                  labelText: "*Area details",
                                  labelStyle: new TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black54,
                                  )
                              ),
                              onFieldSubmitted: (_) {
                                //FocusScope.of(context).requestFocus(_lnameFocusNode);
                              },
                              validator: (value) {
                                if(value.isEmpty) {
                                  return 'Please enter area details';
                                }
                                return null; //it means user entered a valid input
                              },
                            ),
                            SizedBox(height: 5.0,),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child:  GestureDetector(
                                    onTap: () async {
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      prefs.setString("formapscreen", "addressscreen");
                                      Navigator.of(context).pushNamed(MapScreen.routeName,
                                          arguments: {
                                            "houseNo" : _controllerHouseno.text,
                                            "apartment" : _controllerApartment.text,
                                            "street" :  _controllerStreet.text,
                                            "landmark" : _controllerLandmark.text,
                                            "area" : _controllerArea.text,
                                            "pincode" : _controllerPincode.text,
                                          }
                                      );
                                    },
                                    child: TextFormField(
                                      textAlign: TextAlign.left,
                                      enabled: false,
                                      decoration: InputDecoration(
                                          labelText: _deliverylocation,
                                          labelStyle: new TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.black,
                                          )
                                      ),
                                      onFieldSubmitted: (_) {
                                        //FocusScope.of(context).requestFocus(_lnameFocusNode);
                                      },
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                    onTap: () async {
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      prefs.setString("formapscreen", "addressscreen");
                                      Navigator.of(context).pushNamed(MapScreen.routeName,
                                          arguments: {
                                            "houseNo" : _controllerHouseno.text,
                                            "apartment" : _controllerApartment.text,
                                            "street" :  _controllerStreet.text,
                                            "landmark" : _controllerLandmark.text,
                                            "area" : _controllerArea.text,
                                            "pincode" : _controllerPincode.text,
                                          }
                                      );
                                    },
                                    child: Icon(Icons.edit, size: 15.0,)),
                                SizedBox(width: 30.0,),
                                Container(
                                  width: MediaQuery.of(context).size.width * 35 / 100,
                                  child: TextFormField(
                                    controller: _controllerPincode,
                                    textAlign: TextAlign.left,
                                    decoration: InputDecoration(
                                        labelText: "Pincode",
                                        labelStyle: new TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black54,
                                        )
                                    ),
                                    onFieldSubmitted: (_) {
                                      //FocusScope.of(context).requestFocus(_lnameFocusNode);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20.0),
                      child: Column(
                        children: [
                          SizedBox(height: 20.0,),
                          Text("Choose nick name for this address", style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black54,
                          ),),
                          SizedBox(height: 10.0,),
                        ],
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(left: 20.0),
                      child: Row(
                        children: <Widget>[
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _addresstag = "Home";
                                  _home = Theme.of(context).primaryColor;
                                  _work = Colors.grey;
                                  _other = Colors.grey;
                                  _homeWidth = 2.0;
                                  _workWidth = 1.0;
                                  _otherWidth = 1.0;
                                });
                              },
                              child: Container(
                                width: 60.0,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(3.0),
                                    border: Border(
                                      top: BorderSide(width: _homeWidth, color: _home,),
                                      bottom: BorderSide(width: _homeWidth, color: _home,),
                                      left: BorderSide(width: _homeWidth, color: _home),
                                      right: BorderSide(width: _homeWidth, color: _home),
                                    )),
                                height: 35.0,
                                child: Center(
                                  child: Text(
                                    "Home",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 15.0,),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              //behavior: HitTestBehavior.translucent,
                              onTap: () {
                                setState(() {
                                  _addresstag = "Work";
                                  _home = Colors.grey;
                                  _work = Theme.of(context).primaryColor;
                                  _other = Colors.grey;
                                  _homeWidth = 1.0;
                                  _workWidth = 2.0;
                                  _otherWidth = 1.0;
                                });
                              },
                              child: Container(
                                width: 60.0,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(3.0),
                                    border: Border(
                                      top: BorderSide(width: _workWidth, color: _work,),
                                      bottom: BorderSide(width: _workWidth, color: _work,),
                                      left: BorderSide(width: _workWidth, color: _work,),
                                      right: BorderSide(width: _workWidth, color: _work,),
                                    )),
                                height: 35.0,
                                child: Center(
                                  child: Text(
                                    "Office",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 15.0,),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _addresstag = "Other";
                                  _home = Colors.grey;
                                  _work = Colors.grey;
                                  _other = Theme.of(context).primaryColor;
                                  _homeWidth = 1.0;
                                  _workWidth = 1.0;
                                  _otherWidth = 2.0;
                                });
                              },
                              child: Container(
                                width: 60,
                                height: 35.0,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(3.0),
                                    border: Border(
                                      top: BorderSide(width: _otherWidth, color: _other,),
                                      bottom: BorderSide(width: _otherWidth, color: _other,),
                                      left: BorderSide(width: _otherWidth, color: _other,),
                                      right: BorderSide(width: _otherWidth, color: _other,),
                                    )),
                                child: Center(
                                  child: Text(
                                    "Other",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    // Container(
                    //   margin: EdgeInsets.only(left: 9, top: 10,),
                    //   child: CheckboxListTile(
                    //     contentPadding: EdgeInsets.all(0),
                    //     title: Text('Set this as my default delivery address'),
                    //     value: _isChecked,
                    //     controlAffinity: ListTileControlAffinity.leading,
                    //     onChanged: (bool value) {
                    //       setState(() {
                    //         _isChecked = value;
                    //       });
                    //     },
                    //   ),
                    // )
                    SizedBox(height: 20,),
                    _buildBottomNavigationBar(),
                    SizedBox(height: 30,),

                  ],
                ),
              ),
              if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Footer(address: prefs.getString("restaurant_address")),
            ],
          ),
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
      leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined,size: 18, color:ColorCodes.backbutton),
          onPressed: () {
            Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
            return Future.value(false);
          }
      ),
      titleSpacing: 0,
      title: Text("Add new address",style: TextStyle(color: ColorCodes.backbutton,fontSize:18,fontWeight: FontWeight.bold),),
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
}