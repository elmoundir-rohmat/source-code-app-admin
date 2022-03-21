import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/ColorCodes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../constants/IConstants.dart';
//import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file/local.dart';
import '../constants/images.dart';
import '../screens/mobile_authentication.dart';
import 'package:flutter_translate/flutter_translate.dart';


class MultipleImagePicker extends StatefulWidget {
  static const routeName = '/multipleImage-screen';


  final LocalFileSystem localFileSystem;

  MultipleImagePicker({localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();
  @override
  _MultipleImagePickerState createState() => _MultipleImagePickerState();
}

class _MultipleImagePickerState extends State<MultipleImagePicker> {
  final _contactFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  String name = "";
  String phone ="";
  String deliverlocation="";
  String ln = "";
  String ea = "";
  String gst = "";
  String sn = "";
  String dropdownValue = 'GSTIN';
  SharedPreferences prefs;
  File _image;
  final picker = ImagePicker();
  DateTime pickedDate;
  var image;
  File file;
  TextEditingController _controller = new TextEditingController();
  bool _isDuration = false;
  File galleryFile;
  List uploadlist = [];
//save the result of camera file
  File cameraFile;
  var images_captured=List<Widget>();
  int _groupValue = 1;
  bool _value = false;
  List<File> _files;
  String filePath="";
  List pics;
  List<File> images = List<File>();
  var uploadtime;
  String imageSize;
  int check = 0;
  bool status = false;
  bool iphonex = false;
  AnimationController _animationController;

  imageSelectorGallery() async {
    galleryFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
    );

    if(galleryFile!=null) {
      images.add(galleryFile);

      uploadlist.add(MultipartFile.fromFileSync(galleryFile.path));
    }

    setState(() {

    });
  }
  //display image selected from camera
  imageSelectorCamera() async {
    cameraFile = await ImagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 40
    );
    if(cameraFile!=null) {
      images.add(cameraFile);
      uploadlist.add(MultipartFile.fromFileSync(cameraFile.path));
    }
    setState(() {

    });
  }

  displayImages(){
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        return Container(
          margin: EdgeInsets.all(5.0),
          child: Stack(children: <Widget>[
            Container(
              height: 100,
              width: 100,
              child: Image.file(images[index],fit: BoxFit.fill,),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: (){
                  setState(() {
                    images.removeAt(index);
                  });
                },
                child: Icon(
                  Icons.cancel,
                ),
              ),
            ),
          ],),
        );

      }),
    );
  }
  Widget Option() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffe9e9e9),
      ),
      height: 60,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: <Widget>[
          SizedBox(width:10),
         /* Checkbox(
            value: _value,
            checkColor: Theme.of(context).primaryColor,
            activeColor: Colors.white,
            hoverColor: Colors.white,
            focusColor: Colors.white,
            onChanged: (bool newValue) {
              setState(() {
                _value = newValue;
              });
            },
          ),*/
          Expanded(
            child: Text(
             translate('forconvience.Do You Want Fellahi To Call You For Further Details'),
              style: TextStyle(/*fontWeight: FontWeight.bold, fontSize: 16,*/color: Theme.of(context).primaryColor),
            ),
          ),
          SizedBox(width:10),
          FlutterSwitch(
            width:60,
            height: 25,
            toggleSize: 23,

            activeColor: Theme.of(context).accentColor,
            activeToggleColor: Theme.of(context).primaryColorDark,
            value: status,
            onToggle: (val) {
            setState(() {
              status = val;
            });
          },
          ),
          SizedBox(width:10)
        ],
      ),
    );
  }
  _dialogforProcessing1() {
    return showDialog(context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return AbsorbPointer(
                  child: Container(
                    color: Colors.transparent,
                    height: double.infinity,
                    width: double.infinity,
                    alignment: Alignment.center,


                    child:
//                    CircularProgressIndicator(),
                    LinearPercentIndicator(
//                      width: MediaQuery.of(context).size.width,
                      animation: true,
                      lineHeight: 20.0,
                      animationDuration: uploadtime,
                      percent: 0.95,
                      center: Text(translate('forconvience.Uploading...')),
                      linearStrokeCap: LinearStrokeCap.roundAll,
                      progressColor: Colors.green,
                    ),

                  ),
                );
              }
          );
        });
  }
  final TextEditingController firstnamecontroller = new TextEditingController();
  final TextEditingController lastnamecontroller = new TextEditingController();

  bool _isinternet = true;


  Future<void> _refreshProducts(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      setState(() {
        _isinternet = true;
      });
    } else if (connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        _isinternet = true;
      });
    } else {
      Fluttertoast.showToast(msg: "No internet connection!!!");
      setState(() {
        _isinternet = false;
      });
    }

  }
  @override
  void initState() {
    pickedDate = DateTime.now();
    Future.delayed(Duration.zero, () async {
      try {
        if (Platform.isIOS) {
          setState(() {
            iphonex = MediaQuery.of(context).size.height >= 812.0;
          });
        }
      } catch (e) {
      }
       prefs = await SharedPreferences.getInstance();
      setState(() {
        deliverlocation = prefs.getString("deliverylocation");
      });
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile) {
        setState(() {
          _isinternet = true;
        });
        // I am connected to a mobile network.
      } else if (connectivityResult == ConnectivityResult.wifi) {
        // I am connected to a wifi network.
        setState(() {
          _isinternet = true;
        });
      } else {
        Fluttertoast.showToast(msg: "No internet connection!!!");
        setState(() {
          _isinternet = false;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    firstnamecontroller.dispose();
    lastnamecontroller.dispose();
   // _animationController.dispose();
    _contactFocusNode.dispose();
    _addressFocusNode.dispose();

    super.dispose();
  }


  _dialogforProcessing() {
    return showDialog(context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return AbsorbPointer(
                  child: Container(
                    color: Colors.transparent,
                    height: double.infinity,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                    ),
                  ),
                );
              }
          );
        });
  }

  Future<void> createTicket() async { // imp feature in adding async is the it automatically wrap into Future.
    String _imagePath = "";
    List path = [];
    for(int i = 0; i < images.length; i++) {
      if(i == 0) {
        path.add(MultipartFile.fromFileSync(images[i].path.toString()));
        _imagePath = images[i].path.toString();
      } else {
        path.add(MultipartFile.fromFileSync(images[i].path.toString()));
        _imagePath = _imagePath + "," + images[i].path.toString();

      }
    }
    try {
      final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
      final subject = routeArgs['subject'];
      final type = routeArgs['type'];
      SharedPreferences prefs = await SharedPreferences.getInstance();

      var map = FormData.fromMap({

        "id": prefs.getString('userID'),
        "parent": prefs.getString('userID'),
        "subject": subject,
        "message": name + ", " + deliverlocation + ", Contact Number: " +
            phone + " Date: " + pickedDate.toString(),
        "type": type,
        'image': path,
        'place': deliverlocation,
        "callback": (_value == true) ? "1" : "0",
        "branch": prefs.getString('branch'),

      });

      Dio dio;
      BaseOptions options = BaseOptions(
        baseUrl: IConstants.API_PATH,
        connectTimeout: 30000,
        receiveTimeout: 30000,
      );


      dio = Dio(options);
      final response = await dio.post("create-ticket", data: map);
      final responseEncode = json.encode(response.data);
      final responseJson = json.decode(responseEncode);
      if(responseJson['status'].toString() == "200") {
        //init();
        Navigator.of(context).pop();
        Fluttertoast.showToast(msg: translate('forconvience.Successfully submited'), backgroundColor: Colors.black87, textColor: Colors.white, timeInSecForIos: 2);
       // Navigator.of(context).pop();
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/home-screen', (Route<dynamic> route) => false);
      } else {
        Navigator.of(context).pop();
        Fluttertoast.showToast(msg: "Something went wrong", backgroundColor: Colors.black87, textColor: Colors.white, timeInSecForIos: 2);
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/home-screen', (Route<dynamic> route) => false);
      }

    } catch (error) {
      Navigator.of(context).pop();
      Fluttertoast.showToast(msg: "Something went wrong", backgroundColor: Colors.black87, textColor: Colors.white, timeInSecForIos: 2);
      throw error;
    }
  }

  init() {
    pickedDate = DateTime.now();

    Future.delayed(Duration.zero, () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile) {
        setState(() {
          _isinternet = true;
        });
        // I am connected to a mobile network.
      } else if (connectivityResult == ConnectivityResult.wifi) {
        // I am connected to a wifi network.
        setState(() {
          _isinternet = true;
        });
      } else {
        Fluttertoast.showToast(msg: "No internet connection!!!");
        setState(() {
          _isinternet = false;
        });
      }
    });
  }
  checkmobile(){
    if(prefs.getString('mobile').toString() != "null" && prefs.getString('mobile').toString() != "") {
      //  prefs.setString("isPickup", "no");
      // if (addressitemsData.items.length > 0) {
    /*  _dialogforProcessing1();
      createTicket();*/
      checkdetails();


    }
    else{
      prefs.setString('frommultiple', "multipleimagepicker");
      Navigator.of(context)
          .pushReplacementNamed(MobileAuthScreen.routeName,);
    }

  }
  void checkdetails() {
    final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;

      if(images.length == 0){
        Fluttertoast.showToast(msg: translate('forconvience.provideimage'),//"provide image",
            backgroundColor: Colors.black87, textColor: Colors.white);
      }
      else{
       /* try {
        }catch(e){}
        if(prefs.getString('mobile').toString() != "null" && prefs.getString('mobile').toString() != "") {
        //  prefs.setString("isPickup", "no");
          */
          // if (addressitemsData.items.length > 0) {
          _dialogforProcessing1();
          createTicket();


       /* }
        else{
          prefs.setString('frommultiple', "multipleimagepicker");
          Navigator.of(context)
              .pushNamed(MobileAuthScreen.routeName,);
        }*/


      }
  }




  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
    if(images.length == 1){
      uploadtime = http.MultipartRequest("", Uri.parse("uri")).contentLength * 11;
    }
    else if (images.length == 2){
      uploadtime = http.MultipartRequest("", Uri.parse("uri")).contentLength * 11 *2;
    }
    else if(images.length == 3){
      uploadtime = http.MultipartRequest("", Uri.parse("uri")).contentLength * 11 *3;
    }
    else if(images.length == 4){
      uploadtime = http.MultipartRequest("", Uri.parse("uri")).contentLength * 11 *4;
    }
    else if(images.length == 5){
      uploadtime = http.MultipartRequest("", Uri.parse("uri")).contentLength * 11 *5;
    }
    else if(images.length >= 6){
      uploadtime = http.MultipartRequest("", Uri.parse("uri")).contentLength * 11 *6;
    }
    _buildBottomNavigationBar() {
      return GestureDetector(
        onTap: (){
          checkmobile();
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 50.0,
          color: Theme.of(context).primaryColor,
          child: Center(child: Text(translate('forconvience.PLACE ORDER'),//Text("PLACE ORDER",
            style: TextStyle(color: Theme.of(context).buttonColor,fontSize: 16),)),
        ),
      );
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: GradientAppBar(
        gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [ColorCodes.whiteColor, ColorCodes.whiteColor]
        ),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded,size: 20, color: ColorCodes.backbutton),
            onPressed: () {
              Navigator.of(context).pop();
              return Future.value(false);
            }
        ),

        title: Text(
          translate('forconvience.Upload'),
          style: TextStyle(color: ColorCodes.blackColor),
        ),
      ),
      backgroundColor: Colors.white,
      body: !_isinternet ?
      Center(
        child: Container(

          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 80.0, right: 80.0),
                    width: MediaQuery.of(context).size.width,
                    height: 200.0,
                    child: new Image.asset(Images.noInternetImg)
                ),
              ),
              SizedBox(height: 10.0,),
              Text("No internet connection"),
              SizedBox(height: 5.0,),
              Text("Ugh! Something's not right with your internet", style: TextStyle(fontSize: 12.0, color: Colors.grey),),
              SizedBox(height: 10.0,),
              GestureDetector(
                onTap: () {
                  _refreshProducts(context);
                },
                child: Container(
                  width: 90.0,
                  height: 40.0,
                  decoration: BoxDecoration(color: Theme.of(context).accentColor, borderRadius: BorderRadius.circular(3.0),),
                  child: Center(
                      child: Text('Try Again', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),)),
                ),
              ),
            ],
          ),
        ),
      ):
      SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
//            SizedBox(height: 10,),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xffe9e9e9),
                ),
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(height: 20,),
                      GestureDetector(
                          onTap: (){
                            imageSelectorCamera();
                          },
                          child: Image.asset(Images.cameraImg, width: MediaQuery.of(context).size.width-40,)),
                      SizedBox(height: 20,),
                      GestureDetector(
                          onTap: (){
                            imageSelectorGallery();
                          },
                          child: Image.asset(Images.galleryImg, width: MediaQuery.of(context).size.width-40,)),
                      SizedBox(height: 20,),
                    ],
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height/3,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                          width: MediaQuery.of(context).size.width,
//                              margin: EdgeInsets.only(bottom: 20.0),
                          child: displayImages()),
                    ),
                  ],
                ),
              ),
            Spacer(),
            //Option(),
//            SizedBox(height: 30,),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
        child: _buildBottomNavigationBar(),
      ),
    );
  }


}
