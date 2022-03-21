import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../utils/ResponsiveLayout.dart';
import 'package:provider/provider.dart';

import '../providers/categoryitems.dart';
import './categories_item.dart';

class CategoriesGrid extends StatefulWidget {
  final String catId;
  final String catTitle;

  CategoriesGrid(this.catId, this.catTitle);

  @override
  _CategoriesGridState createState() => _CategoriesGridState();
}

class _CategoriesGridState extends State<CategoriesGrid> {
  @override
  Widget build(BuildContext context) {
    final subcategoryData = Provider.of<CategoriesItemsList>(
      context,
      listen: false,
    ).findById(widget.catId);

    double deviceWidth = MediaQuery.of(context).size.width;
    int widgetsInRow = 3;
    double aspectRatio =
        (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 125;

    if (deviceWidth > 1200) {
      widgetsInRow = 5;
      aspectRatio =
          (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 295;
    } else if (deviceWidth > 768) {
      widgetsInRow = 4;
      aspectRatio =
          (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 195;
    }

    return  Column(
      children: <Widget>[
        SizedBox(
          width: 5.0,
        ),
       Container(
          margin: EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: Colors.white,
          ),

          child:  MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GridView.builder(
              shrinkWrap: true,
              controller: new ScrollController(keepScrollOffset: false),
              padding:ResponsiveLayout.isSmallScreen(context)? const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 0.0):
              const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              itemCount: subcategoryData.length,
              itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                value: subcategoryData[i],
                child: Card(
                  color: Color(0xFFD0F0DE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  elevation: 0,
                  margin: EdgeInsets.all(5),

                  child: CategoriesItem(
                      "SubcategoryScreen",
                      widget.catTitle,
                      widget.catId,
                      subcategoryData[i].subcatid,
                      subcategoryData[i].title,
                      i,
                      subcategoryData[i].imageUrl),
                ),
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widgetsInRow,
                childAspectRatio: aspectRatio,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
            ),
          ),
        )
      ],
    );
  }
}
