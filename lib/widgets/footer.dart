import 'package:fellahi_e/constants/ColorCodes.dart';
import 'package:fellahi_e/providers/featuredCategory.dart';
import 'package:fellahi_e/screens/items_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:launch_review/launch_review.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/IConstants.dart';
import '../utils/ResponsiveLayout.dart';
import '../providers/branditems.dart';
import '../providers/categoryitems.dart';
import '../screens/brands_screen.dart';
import '../screens/policy_screen.dart';
import '../screens/subcategory_screen.dart';
import '../constants/images.dart';

class Footer extends StatefulWidget {
  final String address;

  const Footer({
    Key key,
    @required this.address,
  }): super(key: key);

  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  String brandsName = "";
  SharedPreferences prefs;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      final brandsData = Provider.of<BrandItemsList>(context, listen: false);
      for (int i = 0;
      i < (brandsData.items.length > 6 ? 6 : brandsData.items.length);
      i++) {
        setState(() {
          if (i == 0) {
            brandsName = brandsData.items[i].title;
          } else if (i == 5 || i == brandsData.items.length - 1) {
            brandsName = brandsName + brandsData.items[i].title;
          } else {
            brandsName = brandsName + brandsData.items[i].title + ", ";
          }
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ResponsiveLayout.isSmallScreen(context)
          ? createFooterForMobile()
          : createFooterForWeb(),
    );
  }

  createFooterForWeb() {
    final categoriesData = Provider.of<CategoriesItemsList>(context, listen: false);
    final brandsData = Provider.of<BrandItemsList>(context, listen: false);
    final subcategoryData = Provider.of<FeaturedCategoryList>(context, listen: false);
    return Column(
      children: [
        /*SizedBox(
          height: 70.0,
        ),*/
        Divider(),
        SizedBox(
          height: 30.0,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Container(),
              flex: 10,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Categories",
                      style:
                      TextStyle(fontSize: 21.0, color: Theme.of(context).primaryColor,//Color(0xff5983F9)
                      ),
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: (subcategoryData.catTwoitems.length > 6)
                            ? 6
                            : subcategoryData.catTwoitems.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (_, i) => GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                ItemsScreen.routeName, arguments: {
                              'maincategory': subcategoryData.catTwoitems[i].title,
                              'catId': subcategoryData.catTwoitems[i].catid,
                              'catTitle': subcategoryData.catTwoitems[i].title,
                              'subcatId': subcategoryData.catTwoitems[i].catid,
                              'indexvalue': i.toString(),
                              'prev': "category_item"
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 16,
                              ),
                              Text(
                                subcategoryData.catTwoitems[i].title,
                                style: TextStyle(
                                    fontSize: 16.0, color: Color(0xff7D7D7D)),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              ),
              flex: 30,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Useful Links",
                      style:
                      TextStyle(fontSize: 21.0, color: Theme.of(context).primaryColor//Color(0xff5983F9)
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(PolicyScreen.routeName, arguments: {
                            'title': "Terms & Conditions",
                            'body': prefs.getString("restaurant_terms"),
                          });
                        },
                        child: Text(
                          "Term & Conditions",
                          style: TextStyle(
                              fontSize: 16.0, color: Color(0xff7D7D7D)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(PolicyScreen.routeName, arguments: {
                            'title': "Return",
                            'body': prefs.getString("returnspolicy"),
                          });
                        },
                        child: Text(
                          "Return policy",
                          style: TextStyle(
                              fontSize: 16.0, color: Color(0xff7D7D7D)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          Navigator.of(context)
                              .pushNamed(PolicyScreen.routeName, arguments: {
                            'title': "Refund",
                            'body': prefs.getString("refund"),
                          });
                        },
                        child: Text(
                          "Refund Policy",
                          style: TextStyle(
                              fontSize: 16.0, color: Color(0xff7D7D7D)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          Navigator.of(context)
                              .pushNamed(PolicyScreen.routeName, arguments: {
                            'title': "Wallet",
                            'body': prefs.getString("wallet"),
                          });
                        },
                        child: Text(
                          "Wallet Policy",
                          style: TextStyle(
                              fontSize: 16.0, color: Color(0xff7D7D7D)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(PolicyScreen.routeName, arguments: {
                            'title': "About Us",
                            'body': prefs.getString("description"),
                          });
                        },
                        child: Text(
                          "About us",
                          style: TextStyle(
                              fontSize: 16.0, color: Color(0xff7D7D7D)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(PolicyScreen.routeName, arguments: {
                            'title': "Contact Us",
                            'body': "",
                            'businessname': prefs.getString("restaurant_name"),
                            'address': prefs.getString("restaurant_address"),
                            'contactnum': prefs.getString("primary_mobile"),
                            'pemail': prefs.getString("primary_email"),
                            'semail': prefs.getString("secondary_email"),
                          });
                        },
                        child: Text(
                          "Contact",
                          style: TextStyle(
                              fontSize: 16.0, color: Color(0xff7D7D7D)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              flex: 30,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    /* Text(
                      "Popular Brands",
                      style:
                          TextStyle(fontSize: 21.0, color: Color(0xff5983F9)),
                    ),*/
                    /*   SizedBox(
                      height: 60,
                      child: new ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: (brandsData.items.length > 6)
                            ? 6
                            : brandsData.items.length,
                        itemBuilder: (_, i) => GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(BrandsScreen.routeName, arguments: {
                              'brandId': brandsData.items[i].id,
                              'indexvalue': i.toString(),
                            });
                          },
                          child: Text(
                            brandsData.items[i].title + ", ",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 5,
                            style: TextStyle(
                                fontSize: 16.0, color: Color(0xff7D7D7D)),
                          ),
                        ),
                      ),
                    ),*/
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      "Download Our App",
                      style:
                      TextStyle(fontSize: 21.0, color: Theme.of(context).primaryColor//Color(0xff5983F9)
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: new InkWell(
                          onTap: () => launch(
                              'https://play.google.com/store/apps/details?id=com.fellahi.store'),
                          child: Image.asset(Images.playstoreImg)),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: new InkWell(
                        child: Image.asset(Images.appStroreImg),
                        onTap: () => launch('#'),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      "Get social with us",
                      style:
                      TextStyle(fontSize: 21.0, color: Theme.of(context).primaryColor//Color(0xff5983F9)
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        MouseRegion(
                          child: new InkWell(
                            child: Image.asset(Images.fbImg),
                            onTap: () => launch('#'),
                          ),
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        MouseRegion(
                          child: new InkWell(
                            child: Image.asset(Images.twitterImg),
                            onTap: () => launch('#'),
                          ),
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Image.asset(Images.youtubeImg),
                        SizedBox(
                          width: 8.0,
                        ),
                        Image.asset(Images.instaImg),
                      ],
                    )
                  ],
                ),
              ),
              flex: 30,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Payment Method",
                      style:
                      TextStyle(fontSize: 21.0, color: Theme.of(context).primaryColor//Color(0xff5983F9)
                      )
                      ,
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Image.asset(Images.paymentsImg),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      "Address",
                      style:
                      TextStyle(fontSize: 21.0, color: Theme.of(context).primaryColor,//Color(0xff5983F9)
                      ),
                    ),
                    Text(
                      IConstants.APP_NAME,
                      style:
                      TextStyle(fontSize: 17.0, color: Color(0xff7D7D7D)),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      widget.address,
                      style:
                      TextStyle(fontSize: 16.0, color: Color(0xff7D7D7D)),
                    ),
                  ],
                ),
              ),
              flex: 30,
            ),
            Expanded(
              child: Container(),
              flex: 10,
            ),
          ],
        ),
        SizedBox(
          height: 50.0,
        ),
        Divider(),
        Container(
          height: 96.0,
          color: ColorCodes.whiteColor,//Color(0xffEEEEEE),
          width: MediaQuery.of(context).size.width,
          child: Center(
              child: Text(
                "Copyright ©2021 All rights reserved | Fellahi.",
                style: TextStyle(fontSize: 16.0, color: Color(0xff585858)),
              )),
        )
      ],
    );
  }

  createFooterForMobile() {
    final categoriesData = Provider.of<CategoriesItemsList>(context, listen: false);
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Categories",
                style: TextStyle(fontSize: 21.0, color: Color(0xff5983F9)),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: (categoriesData.items.length > 6)
                    ? 6
                    : categoriesData.items.length,
                padding: EdgeInsets.zero,
                itemBuilder: (_, i) => GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(SubcategoryScreen.routeName, arguments: {
                      'catId': categoriesData.items[i].catid,
                      'catTitle': categoriesData.items[i].title,
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        categoriesData.items[i].title,
                        style:
                        TextStyle(fontSize: 16.0, color: Color(0xff7D7D7D)),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                "Useful Links",
                style: TextStyle(fontSize: 21.0, color: Color(0xff5983F9)),
              ),
              SizedBox(
                height: 8,
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(PolicyScreen.routeName, arguments: {
                    'title': "Terms & Conditions",
                    'body': prefs.getString("restaurant_terms"),
                  });
                },
                child: Text(
                  "Term & Conditions",
                  style: TextStyle(fontSize: 16.0, color: Color(0xff7D7D7D)),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(PolicyScreen.routeName, arguments: {
                    'title': "Return",
                    'body': prefs.getString("returnspolicy"),
                  });
                },
                child: Text(
                  "Return policy",
                  style: TextStyle(fontSize: 16.0, color: Color(0xff7D7D7D)),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () async {
                  Navigator.of(context)
                      .pushNamed(PolicyScreen.routeName, arguments: {
                    'title': "Refund",
                    'body': prefs.getString("refund"),
                  });
                },
                child: Text(
                  "Refund Policy",
                  style: TextStyle(fontSize: 16.0, color: Color(0xff7D7D7D)),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () async {
                  Navigator.of(context)
                      .pushNamed(PolicyScreen.routeName, arguments: {
                    'title': "Wallet",
                    'body': prefs.getString("wallet"),
                  });
                },
                child: Text(
                  "Wallet Policy",
                  style: TextStyle(fontSize: 16.0, color: Color(0xff7D7D7D)),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(PolicyScreen.routeName, arguments: {
                    'title': "About Us",
                    'body': prefs.getString("description"),
                  });
                },
                child: Text(
                  "About us",
                  style: TextStyle(fontSize: 16.0, color: Color(0xff7D7D7D)),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(PolicyScreen.routeName, arguments: {
                    'title': "Contact Us",
                    'body': "",
                    'businessname': prefs.getString("restaurant_name"),
                    'address': prefs.getString("restaurant_address"),
                    'contactnum': prefs.getString("primary_mobile"),
                    'pemail': prefs.getString("primary_email"),
                    'semail': prefs.getString("secondary_email"),
                  });
                },
                child: Text(
                  "Contact",
                  style: TextStyle(fontSize: 16.0, color: Color(0xff7D7D7D)),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                "Popular Brands",
                style: TextStyle(fontSize: 21.0, color: Color(0xff5983F9)),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                brandsName,
                style: TextStyle(fontSize: 16.0, color: Color(0xff7D7D7D)),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                "Download Our App",
                style: TextStyle(fontSize: 21.0, color: Color(0xff5983F9)),
              ),
              SizedBox(
                height: 8,
              ),
              Image.asset(Images.playstoreImg),
              SizedBox(
                height: 4,
              ),
              Image.asset(Images.appStroreImg),
              SizedBox(
                height: 8,
              ),
              Text(
                "Get social with us",
                style: TextStyle(fontSize: 21.0, color: Color(0xff5983F9)),
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  Image.asset(Images.fbImg),
                  SizedBox(
                    width: 8.0,
                  ),
                  Image.asset(Images.twitterImg),
                  SizedBox(
                    width: 8.0,
                  ),
                  Image.asset(Images.youtubeImg),
                  SizedBox(
                    width: 8.0,
                  ),
                  Image.asset(Images.instaImg),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                "Payment Method",
                style: TextStyle(fontSize: 21.0, color: Color(0xff5983F9)),
              ),
              SizedBox(
                height: 20.0,
              ),
              Image.asset(Images.paymentsImg),
              SizedBox(
                height: 20.0,
              ),
              Text(
                "Address",
                style: TextStyle(fontSize: 21.0, color: Color(0xff5983F9)),
              ),
              Text(
                IConstants.APP_NAME,
                style: TextStyle(fontSize: 17.0, color: Color(0xff7D7D7D)),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                widget.address,
                style: TextStyle(fontSize: 16.0, color: Color(0xff7D7D7D)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 50.0,
        ),

        Divider(),
        Container(
          height: 96.0,
          color: ColorCodes.whiteColor,//Color(0xffEEEEEE),
          width: MediaQuery.of(context).size.width,
          child: Center(
              child: Text(
                "Copyright ©2021 All rights reserved | Fellahi.",
                style: TextStyle(fontSize: 16.0, color: Color(0xff585858)),
              )),
        )
      ],
    );
  }
}
