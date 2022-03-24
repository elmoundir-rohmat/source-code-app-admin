import 'dart:io';

import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/material.dart';
import '../utils/ResponsiveLayout.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../constants/ColorCodes.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../data/hiveDB.dart';
import '../main.dart';
import '../providers/sellingitems.dart';
import '../providers/itemslist.dart';
import '../screens/cart_screen.dart';
import '../widgets/selling_items.dart';
import '../data/calculations.dart';
import '../constants/images.dart';

class SearchitemScreen extends StatefulWidget {
  static const routeName = '/searchitem-screen';

  @override
  _SearchitemScreenState createState() => _SearchitemScreenState();
}

class _SearchitemScreenState extends State<SearchitemScreen> {
  bool shimmereffect = true;
  SharedPreferences prefs;
  var notificationData;
  int unreadCount = 0;
  bool checkskip = false;
  var _currencyFormat = "";
  var popularSearch;
  bool _isSearchShow = false;
  List searchDispaly = [];
  var searchData;
  String searchValue = "";
  bool _isShowItem = false;
  bool _isLoading = false;
  FocusNode _focus = new FocusNode();
  bool _isNoItem = false;
  bool _checkmembership = false;
  bool _isWeb = false;
  var _address = "";
  var _membership = "";

  var itemname;
  var itemid;
  var itemimg;
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
      _address = prefs.getString("restaurant_address");
      setState(() {
        _currencyFormat = prefs.getString("currency_format");
        _membership = prefs.getString("membership");
        if (_membership == "1") {
          _checkmembership = true;
        } else {
          _checkmembership = false;
        }
      });
      //Provider.of<CartItems>(context, listen: false).fetchCartItems();
    });
    (_isWeb)
        ? _focus.addListener(_onFocusChangeWeb)
        : _focus.addListener(_onFocusChange);
    super.initState();
  }

  void _onFocusChangeWeb() {
    setState(() {
      if (_focus.hasFocus.toString() == "true") {
        _isShowItem = true;
        _isLoading = false;
        search(itemname);
      } else {
        _isShowItem = true;
      }
    });
  }

  void _onFocusChange() {
    setState(() {
      if (_focus.hasFocus.toString() == "true") {
        _isShowItem = false;
        _isLoading = false;
      } else {
        _isShowItem = true;
      }
    });
  }

  search(String value) async {
    await Provider.of<ItemsList>(context,listen: false).fetchsearchItems(value).then((_) {
      setState(() {
        searchData = Provider.of<ItemsList>(context,listen: false);

        //searchDispaly = searchData.searchitems.title;
        _isSearchShow = true;
        searchDispaly = searchData.searchitems.toList();
        if (searchDispaly.length <= 0) {
          _isNoItem = true;
        } else {
          _isNoItem = false;
        }
        /*searchData = Provider.of<ItemsList>(context, listen: false);
        searchDispaly = searchData.searchitems
            .where((elem) =>
            elem.title
                .toString()
                .toLowerCase()
                .contains(searchValue.toLowerCase()))
            .toList();
        _isSearchShow = true;*/
      });
    });
  }

  onSubmit(String value) async {
    //FocusScope.of(context).requestFocus(_focus);
    /*_focus = new FocusNode();
    FocusScope.of(context).requestFocus(_focus);*/

    await Provider.of<ItemsList>(context,listen: false).fetchsearchItems(value).then((_) {
      setState(() {
        searchData = Provider.of<ItemsList>(context,listen: false);
        searchDispaly = searchData.searchitems.toList();
        if (searchDispaly.length <= 0) {
          _isNoItem = true;
        } else {
          _isNoItem = false;
        }
        _isShowItem = true;
        _isLoading = false;
      });
      });

    facebookAppEvents.logSearch(itemname: value);

  }

  @override
  void dispose() {
    // TODO: implement dispose
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      if (_isWeb) {
        var routeArgs =
            ModalRoute.of(context).settings.arguments as Map<String, String>;
        itemname = routeArgs['itemname'];
        itemid = routeArgs['itemid'];
        itemimg = routeArgs['itemimg'];
      }
    } catch (e) {}

    final popularSearch = Provider.of<SellingItemsList>(context,listen: false);

    double deviceWidth = MediaQuery.of(context).size.width;
    int widgetsInRow = 1;

    if (deviceWidth > 1200) {
      widgetsInRow = 4;
    } else if (deviceWidth > 768) {
      widgetsInRow = 3;
    }
    double aspectRatio = (_isWeb && !ResponsiveLayout.isSmallScreen(context))
        ? (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 330
        : (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 120;

    _buildBottomNavigationBar() {
      return ValueListenableBuilder(
          valueListenable: Hive.box<Product>(productBoxName).listenable(),
          builder: (context, Box<Product> box, index) {
            if (box.values.isEmpty)
               return SizedBox.shrink();
            return
              Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                color: ColorCodes.greenColor,
                height: 50.0,
                child: Row(
                  // mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Center(
                      child: Text(
                        Calculations.itemCount.toString() + " "+translate('bottomnavigation.items'),
                        style: TextStyle(
                            fontSize: 16.0,
                            color: ColorCodes
                                .whiteColor,
                            fontWeight: FontWeight
                                .bold),
                      ),
                    ),
                    Center(
                      child: GestureDetector(
                          onTap: () =>
                          {
                            setState(() {
                              Navigator.of(context).pushNamed(
                                  CartScreen.routeName);
                            })
                          },
                          child: Container(
                            /*color: Theme
                                  .of(context)
                                  .primaryColor,*/
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .center,
                                  children: [
                                    Text(
                                      translate('bottomnavigation.viewcart'),
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          color: ColorCodes
                                              .whiteColor,
                                          fontWeight: FontWeight
                                              .bold),
                                      textAlign: TextAlign.center,
                                    ),
                                    /*   Icon(
                                                  Icons.arrow_right,
                                                  color: ColorCodes.whiteColor,
                                                ),*/
                                  ]))),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[

                        /* _checkmembership
                                  ? Text(
                                "Total: " +
                                    _currencyFormat +
                                    (Calculations.totalMember).toString(),
                                style: TextStyle(color: Colors.white,
                                    fontSize: 16
                                ),
                                )
                                  : */
                        Text(
                          /* "Total: " +*/
                          " "+
                              double.parse((Calculations.total).toString()).toStringAsFixed(2)+ _currencyFormat ,
                          style: TextStyle(
                              fontSize: 16.0,
                              color: ColorCodes
                                  .whiteColor,
                              fontWeight: FontWeight
                                  .bold),
                          textAlign: TextAlign.center,
                        ),


                        /*  Text(
                                      "Saved: " +
                                          _currencyFormat +
                                          Calculations.discount.toString(),
                                      style: TextStyle(
                                          color: ColorCodes.discount,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14),
                                    ),*/
                      ],
                    ),
                  ],
                ),
              );
          }
      );
      /*return ValueListenableBuilder(
        valueListenable: Hive.box<Product>(productBoxName).listenable(),
        builder: (context, Box<Product> box, index) {
          if (box.values.isEmpty) return SizedBox.shrink();

          return Container(
            width: MediaQuery.of(context).size.width,
            height: 50.0,
            color: Colors.green,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                 color: Colors.green,
                  height: 50,
                  width: MediaQuery.of(context).size.width * 40 / 100,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 15.0,
                      ),
                      _checkmembership
                          ? Text(
                              'Total: '  +
                                  " " +
                                  (Calculations.totalMember).toString()+
                                  _currencyFormat,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            )
                          : Text(
                              'Total: ' +
                                  " " +
                                  (Calculations.total).toString() +
                                  _currencyFormat,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                      Text(
                        Calculations.itemCount.toString() + " "+translate('bottomnavigation.items'),
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w400,
                            fontSize: 11),
                      )
                    ],
                  ),
                ),
                GestureDetector(
                    onTap: () => {
                          setState(() {
                            Navigator.of(context)
                                .pushNamed(CartScreen.routeName);
                          })
                        },
                    child: Container(
                       // color: Theme.of(context).primaryColor,
                        height: 50,
                        width: MediaQuery.of(context).size.width * 60 / 100,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                translate('bottomnavigation.viewcart'),
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.arrow_right,
                                color: Colors.white,
                              )
                            ]))),
              ],
            ),
          );
        },
      );*/

      /*if(Calculations.itemCount > 0) {
        return Container(
          width: MediaQuery
              .of(context)
              .size
              .width,
          height: 50.0,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                height:50,
                width:MediaQuery.of(context).size.width * 35/100,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 15.0,
                    ),
                    _checkmembership
                        ?
                    Text(_currencyFormat + (Calculations.totalMember).toString(), style: TextStyle(color: Colors.black),)
                        :
                    Text(_currencyFormat + (Calculations.total).toString(), style: TextStyle(color: Colors.black),),
                    Text(Calculations.itemCount.toString() + " "+translate('bottomnavigation.items'), style: TextStyle(color:Colors.black,fontWeight: FontWeight.w400,fontSize: 9),)
                  ],
                ),),
              GestureDetector(
                  onTap: () =>
                  {
                    setState(() {
                      Navigator.of(context).pushNamed(CartScreen.routeName);
                    })
                  },
                  child: Container(color: Theme.of(context).primaryColor, height:50,width:MediaQuery.of(context).size.width*65/100,
                      child:Column(children:[
                        SizedBox(height: 17,),
                        Text(translate('bottomnavigation.viewcart'), style: TextStyle(fontSize: 12.0, color: Colors.white, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                      ]
                      )
                  )
              ),
            ],
          ),
        );
      }*/
    }

    return Scaffold(
      backgroundColor: ColorCodes.whiteColor,
      body: Column(children: <Widget>[
       if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Header(true),
        //     :
       // if (_isWeb) onSubmit(itemname),
        _searchContainermobile(),
        Expanded(
            child: SingleChildScrollView(
          child: Column(children: [
            _isShowItem
                ? _isLoading
                    ? Container(
                        height: MediaQuery.of(context).size.height - 130.0,
                        child: Center(child: CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                        )),
                      )
                    : _isNoItem
                        ? ValueListenableBuilder(
                            valueListenable:
                                Hive.box<Product>(productBoxName).listenable(),
                            builder: (context, Box<Product> box, index) {
                              if (box.values.isEmpty)
                                return Container(
                                  height: MediaQuery.of(context).size.height -
                                      180.0,
                                  child: Center(
                                    child: new Image.asset(
                                      Images.noItemImg,
                                      fit: BoxFit.fill,
                                      height: 200.0,
                                      width: 200.0,
                                    ),
                                  ),
                                );

                              return Container(
                                height:
                                    MediaQuery.of(context).size.height - 130.0,
                                child: Center(
                                  child: new Image.asset(
                                    Images.noItemImg,
                                    fit: BoxFit.fill,
                                    height: 200.0,
                                    width: 200.0,
                                  ),
                                ),
                              );
                            },
                          )
                        : GridView.builder(
                            padding: EdgeInsets.only(top: 10.0),
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            itemCount: searchDispaly.length,
                            gridDelegate:
                                new SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: widgetsInRow,
                              childAspectRatio: aspectRatio,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              return SellingItems(
                                "searchitem_screen",
                                searchDispaly[index].id,
                                searchDispaly[index].title,
                                searchDispaly[index].imageUrl,
                                searchDispaly[index].brand,
                                "",
                              );
                            })
                : Container(
                    width: MediaQuery.of(context).size.width,
                    //height: MediaQuery.of(context).size.height,
                    margin: EdgeInsets.all(8.0),
                    color: Theme.of(context).backgroundColor,

                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (_isSearchShow)
                            SizedBox(
                              child: new ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: searchDispaly.length,
                                padding: EdgeInsets.zero,
                                itemBuilder: (_, i) => Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
/*                                        Navigator.of(context).pushNamed(
                                            SingleproductScreen.routeName,
                                            arguments: {
                                              "itemid" : searchDispaly[i].id.toString(),
                                              "itemname" : searchDispaly[i].title.toString(),
                                              "itemimg" : searchDispaly[i].imageUrl.toString(),
                                            }
                                        );*/
                                        _isShowItem = true;
                                        _isLoading = true;
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                        onSubmit(searchValue);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(12.0),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border(
                                              bottom: BorderSide(
                                                width: 2.0,
                                                color: Theme.of(context)
                                                    .backgroundColor,
                                              ),
                                            )),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Text(
                                          searchDispaly[i].title,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (ResponsiveLayout.isSmallScreen(context))
                            Container(
                              margin: EdgeInsets.all(14.0),
                              child: Text(translate('forconvience.Popular Searches')),
                            ),
                          if (ResponsiveLayout.isSmallScreen(context))
                            SizedBox(
                              child: new ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: popularSearch.items.length,
                                padding: EdgeInsets.zero,
                                itemBuilder: (_, i) => Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
/*                                      Navigator.of(context).pushNamed(
                                          SingleproductScreen.routeName,
                                          arguments: {
                                            "itemid" : popularSearch.items[i].id.toString(),
                                            "itemname" : popularSearch.items[i].title.toString(),
                                            "itemimg" : popularSearch.items[i].imageUrl.toString(),
                                          }
                                      );*/
                                        _isShowItem = true;

                                        _isLoading = true;
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                        onSubmit(popularSearch.items[i].title);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(14.0),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border(
                                              bottom: BorderSide(
                                                width: 2.0,
                                                color: Theme.of(context)
                                                    .backgroundColor,
                                              ),
                                            )),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Text(
                                          popularSearch.items[i].title,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ]),
                  ),
            if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Footer(address: _address),
          ]),
        ))
      ]),
      bottomNavigationBar: (_isWeb && !ResponsiveLayout.isSmallScreen(context))
          ? SizedBox.shrink()
          : Padding(
        padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
        child: _buildBottomNavigationBar(),
      ),
    );
  }

  _searchContainermobile() {
    return (_isWeb&&!ResponsiveLayout.isSmallScreen(context))?
    Opacity(
      opacity: 0.0,
          child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.topRight,
              colors:(_isWeb&&!ResponsiveLayout.isSmallScreen(context)) ?[Colors.transparent,Colors.transparent]:[
                Theme.of(context).primaryColor,
                Theme.of(context).accentColor
              ],
            ),
          ),
          //color: Theme.of(context).primaryColor,
          width: MediaQuery.of(context).size.width,
          child: Column(children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color:(_isWeb&&!ResponsiveLayout.isSmallScreen(context))?Colors.transparent: Theme.of(context).buttonColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                Text(
                  translate('forconvience.Search Products '),
                  style: TextStyle(color:(_isWeb&&!ResponsiveLayout.isSmallScreen(context))?Colors.transparent: Colors.white, fontSize: 18.0),
                )
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height:2,

              //padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.0),
                    border: Border.all(
                        color: (_isWeb&&!ResponsiveLayout.isSmallScreen(context))?Colors.transparent:Colors.grey.withOpacity(0.5), width: 1.0),
                    color:(_isWeb&&!ResponsiveLayout.isSmallScreen(context))?Colors.transparent: Color(0xffffffff),
                  ),
                  child: Row(children: [
                    IconButton(
                      icon: Icon(
                        Icons.search, size:22,
                        color:(_isWeb&&!ResponsiveLayout.isSmallScreen(context))?Colors.transparent: Colors.grey,
                      ),
                    ),
                    Container(
                        //margin: EdgeInsets.only(bottom: 30.0),
                        width: MediaQuery.of(context).size.width * 80 / 100,
                        child: TextField(
                            autofocus: true,
                            //controller: (_isWeb)?TextEditingController(text:itemname):null,
                            textInputAction: TextInputAction.search,
                            focusNode: _focus,
                            maxLines: 1,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
                              hintText: translate('forconvience.Type to search products'),
                            ),
                            onSubmitted: (value) {
                              searchValue = value;
                              if (value.length == 0) {
                                _isSearchShow = false;
                                _isLoading=false;
                                _isShowItem=false;
                              }
                              else {
                                _isShowItem = true;
                                _isLoading = true;
                                if (_isWeb) onSubmit(itemname);
                                onSubmit(value);
                              }
                            },
                            onChanged: (String newVal) {
                              setState(() {
                                searchValue = newVal;
                                if (newVal.length == 0) {
                                  _isSearchShow = false;
                                } else if (newVal.length == 2) {
                                } else if (newVal.length >= 3) {
                                  search(newVal);
                                }
                              });
                            })),
                  ])),
            ),
          ])),
    ):Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.topRight,
            colors:(_isWeb&&!ResponsiveLayout.isSmallScreen(context)) ?[Colors.transparent,Colors.transparent]:[
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor
            ],
          ),
        ),
        //color: Theme.of(context).primaryColor,
        width: MediaQuery.of(context).size.width,
        height: 130.0,
        child: Column(children: <Widget>[
          SizedBox(
            height: 30.0,
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_outlined,size: 20,
                  color:(_isWeb&&!ResponsiveLayout.isSmallScreen(context))?Colors.transparent:ColorCodes.whiteColor,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              Text(
                translate('forconvience.Search Products '),
                style: TextStyle(color:(_isWeb&&!ResponsiveLayout.isSmallScreen(context))?Colors.transparent: Colors.white, fontSize: 18.0),
              )
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 40.0,

            //padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.0),
                  border: Border.all(
                      color: (_isWeb&&!ResponsiveLayout.isSmallScreen(context))?Colors.transparent:Colors.grey.withOpacity(0.5), width: 1.0),
                  color:(_isWeb&&!ResponsiveLayout.isSmallScreen(context))?Colors.transparent: Color(0xffffffff),
                ),
                child: Row(children: [
                  IconButton(
                    icon: Icon(
                      Icons.search,
                      size:22,
                      color:(_isWeb&&!ResponsiveLayout.isSmallScreen(context))?Colors.transparent: Colors.grey,
                    ),
                  ),
                  Container(
                     // margin: EdgeInsets.only(top: 23.0),
                      width: MediaQuery.of(context).size.width * 80 / 100,
                      child: TextField(
                          autofocus: true,
                          //controller: (_isWeb)?TextEditingController(text:itemname):null,
                          textInputAction: TextInputAction.search,
                          focusNode: _focus,
                          maxLines: 1,
                          //cursorHeight: 20,
                          // style: TextStyle(
                          //   //fontSize: 40.0,
                          //   height: 0.0,
                          //   //color: Colors.black
                          // ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding:
                                EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 15.0),
                            hintText: translate('forconvience.Type to search products'),
                          ),
                          onSubmitted: (value) {
                            searchValue = value;
                            if(value.length==0){
                              _isSearchShow = false;
                              _isLoading=false;
                              _isShowItem=false;
                              _isNoItem = true;
                            }
                            else {
                              _isShowItem = true;
                              _isLoading = true;
                              if (_isWeb) onSubmit(itemname);
                              onSubmit(value);
                            }
                          },
                          onChanged: (String newVal) {
                            setState(() {
                              searchValue = newVal;
                              if (newVal.length == 0) {
                                _isSearchShow = false;
                              } else if (newVal.length == 2) {
                              } else if (newVal.length >= 3) {
                                search(newVal);
                              }
                            });
                          })),
                ])),
          ),
        ]));
  }
}
