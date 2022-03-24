import 'package:flutter/material.dart';
import '../constants/ColorCodes.dart';
import '../screens/items_screen.dart';
import '../providers/categoryitems.dart';

import 'package:provider/provider.dart';

class ExpansionDrawer extends StatefulWidget {

  final String parentcatId;
  final String subcatID;
  ExpansionDrawer(this.parentcatId, this.subcatID);



  @override
  _ExpansionDrawerState createState() => _ExpansionDrawerState();
}

class _ExpansionDrawerState extends State<ExpansionDrawer> {
  List variddata = [];
  var subcategoryData;
  var varlength;

  CategoriesItemsList categoriesData;
@override
  void initState() {
  // setState(() {
  //   categoriesData = Provider.of<CategoriesItemsList>(context, listen: false);
  // });
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    categoriesData = Provider.of<CategoriesItemsList>(context, listen: false);
    return Container(
      width: 200,
      height:MediaQuery.of(context).size.height,
      constraints: BoxConstraints(
        minHeight: 500,
        maxHeight:double.infinity,
        // maxWidth: 30.0,
      ),
      child: ListView.builder(
        itemCount: categoriesData.items.length,
        itemBuilder: (_, index) {
          final catid = categoriesData.items[index].catid;
         return SubCategoriesGrid(categoriesData.items[index].catid,
              categoriesData.items[index].title, widget.parentcatId,
              widget.subcatID);
          // return ListTileTheme(
          //     contentPadding: EdgeInsets.all(0),
          //     child: ExpansionTile(
          //         initiallyExpanded: (widget.parentcatId ==
          //             categoriesData.items[index].catid) ? true : false,
          //         title: Text(categoriesData.items[index].title),
          //         children: [
          //           SubCategoriesGrid(categoriesData.items[index].catid,
          //               categoriesData.items[index].title, widget.parentcatId,
          //               widget.subcatID),
          //         ]
          //     ));
        },
      ),

    );
  }

}
class SubCategoriesGrid extends StatefulWidget {
  final String catId;
  final String catTitle;
  final String parentcatId;
  final String subcatid;

  SubCategoriesGrid(this.catId, this.catTitle,this.parentcatId,this.subcatid);

  @override
  _SubCategoriesGridState createState() => _SubCategoriesGridState();
}

class _SubCategoriesGridState extends State<SubCategoriesGrid> {

  CategoriesItemsList subcategoryData;
  var _isloading = true;
  @override
  void initState() {
    Provider.of<CategoriesItemsList>(context, listen: false)
        .fetchNestedCategory(widget.catId,"subitemScreen")
        .then((_) {
      setState(() {
        subcategoryData = Provider.of<CategoriesItemsList>(
          context,
          listen: false,
        );
        _isloading = subcategoryData.itemsubNested.isEmpty? true:!true;
      });
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /*  subcategoryData = Provider.of<CategoriesItemsList>(
      context,
      listen: false,
    );*/
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

          child: _isloading? Center(
            child: CircularProgressIndicator(),
          ) : ListView.builder(
            shrinkWrap: true,
            controller: new ScrollController(keepScrollOffset: false),
            padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 0.0),
            itemCount: subcategoryData.itemsubNested.length,
            itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                value: subcategoryData.itemsubNested[i],
                child:GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.of(context).pushNamed(ItemsScreen.routeName, arguments: {
                      'maincategory': widget.catTitle,
                      'catId': widget.catId,
                      'catTitle': widget.catTitle,
                      'subcatId': subcategoryData.itemsubNested[i].catid,
                      'indexvalue': i.toString(),
                      'subcattitle':subcategoryData.itemsubNested[i].title,
                      'prev': "category_item"});
                  },
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child:  Text(subcategoryData.itemsubNested[i].title,
                      style: TextStyle(
                          color: (widget.subcatid==subcategoryData.itemsubNested[i].catid)?ColorCodes.discount:Colors.black
                      ),
                    ),
                  ),
                )
            ),

          ),
        )
      ],
    );
  }
}