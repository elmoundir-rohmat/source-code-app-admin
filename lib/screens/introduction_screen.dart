import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import '../screens/home_screen.dart';
import '../screens/signup_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../constants/images.dart';
import '../constants/ColorCodes.dart';
import 'package:flutter_translate/flutter_translate.dart';


class introductionscreen extends StatefulWidget {
  static const routeName = '/introduction-screen';


  @override
  _introductionscreenState createState() => _introductionscreenState();
}
class _introductionscreenState extends State<introductionscreen> {

  final introKey = GlobalKey<IntroductionScreenState>();

  void introductionSkip() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('introduction', true);
    prefs.setString("formapscreen", "");
    var LoginStatus = prefs.getString('LoginStatus');

    if(LoginStatus == null || LoginStatus != "true") {
      prefs.setString('skip', "yes");
    }
    //Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
    //Navigator.of(context).pushReplacementNamed(SignupSelectionScreen.routeName);
    Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
  }




  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 20.0);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold,color:Colors.green),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),

      pageColor: Colors.white,
      imagePadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
      contentPadding: EdgeInsets.zero,
      footerPadding: EdgeInsets.only(bottom: 5),
      bodyFlex: 0,
    );
    return IntroductionScreen(
          key: introKey,
          pages: [
            PageViewModel(
              title: 'Produits fraîchement récoltés',//'Direct du Fellah',
              bodyWidget: Column(children: [
                // SizedBox(height: 20,),
              Text(
              'Vos produits frais proviennent directement des petits agriculteurs de la région',//'Vos produits frais proviennent directement de vos petits agriculteurs de la région',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: ColorCodes.introtextColor,
                      fontSize: 14.0,
                      //fontWeight: FontWeight.w300
                  )),
                /*SizedBox(height: 20,),
              Text('#ApkaApnaSuperMART', textAlign: TextAlign.center,
                style: TextStyle(color: Colors.green,
                    fontSize: 15,
                    fontWeight: FontWeight.w300),)*/
                SizedBox(height: 70,//MediaQuery.of(context).size.height/10,//35,
                ),
              ]
              ),
              image:  Center(child: SvgPicture.asset(Images.onboarding1Img,)),
              decoration: pageDecoration,

            ),

            PageViewModel(
                title: 'Livraison 7j/7',//'Livraison en 3h',
                bodyWidget: Column(
                    children:[
                      // SizedBox(height: 20,),
                      Text(
                          'Choisissez le créneau qui vous convient.\nLa récolte du matin arrive chez vous le jour même',//'La récolte du matin arrive chez vous le jour même. Choisissez le créneau qui vous convient',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: ColorCodes.introtextColor,
                              fontSize: 14.0,
                              //fontWeight: FontWeight.w300
                          )),
                      //SizedBox(height: 15,),
                     /* Center(
                        child: Text(
                            'La récolte du matin arrive chez vous le jour même. Choisissez le créneau qui vous convient',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 17.0, fontWeight: FontWeight.w300
                            )),
                      ),*/
                      /*Row(children:[Expanded(child:Text('La récolte du matin arrive chez vous le jour même. Choisissez le créneau qui vous convient',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 17.0,fontWeight: FontWeight.w300
                          )),)]),
                      *//* SizedBox(height: 20,),
            Text('#SayNoToChemicals',textAlign: TextAlign.center,style: TextStyle(fontSize: 15,fontWeight: FontWeight.w300,color:Colors.green),)*/
                      SizedBox(height: 70,//MediaQuery.of(context).size.height/10,//50,
                           ),
                    ]
                ),
                image:  Center(child: SvgPicture.asset(Images.onboarding2Img)),
                decoration: pageDecoration
            ),
            PageViewModel(
                title: 'Fellah mieux rémunéré',//'Fellah mieux rémunéré',
                bodyWidget: Column(
                    children:[
                      // SizedBox(height: 20,),
                      Row(children:[Expanded(child:Text('Grâce à votre achat, les petits agriculteurs sont rémunérés au juste prix',//'Améliorez le niveau de vie des petits agriculteurs avec une rémunération au juste prix',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: ColorCodes.introtextColor,
                              fontSize: 14.0,
                              //fontWeight: FontWeight.w300
                          )),)]),
                      SizedBox(height: 20,),
                      GestureDetector(
                        onTap: (){
                          introductionSkip();
                        },
                        child: Container(
                          height: 50,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Theme.of(context).primaryColor,width: 2),
                          ),
                          child: Center(child: Text('C’EST PARTI!',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Theme.of(context).primaryColor),)),),
                      ),
                      // Text('#HaveItYourWay',textAlign: TextAlign.center,style:TextStyle(fontSize: 15,fontWeight: FontWeight.w300,color: Colors.green),)
                    //  SizedBox(height: 8,),
                    ]
                ),
                image:  Center(child: SvgPicture.asset(Images.onboarding3Img)),
                decoration: pageDecoration
            ),
            /* PageViewModel(
          title: 'Hassle free Payments',
          bodyWidget: Column(
              children:[
            SizedBox(height: 20,),
            Row(children:[
              Expanded(child:Text
                ('India’s first online postpaid Grocery Delivery. Get all your bills generated weekly and pay as per your convenience. Pay via cash or digital modes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 15.0,fontWeight: FontWeight.w300
                  )),),]),
            SizedBox(height:20,),
            Text('#AajUdhaarKalNakad',textAlign: TextAlign.center,style: TextStyle(fontSize: 15,fontWeight: FontWeight.w300,color:Colors.green),)
          ]
          ),
          decoration: pageDecoration,
          image: Image.asset(Images.onboarding4Img)
        )*/

          ],
          showSkipButton: false,
          showNextButton: false,
          onDone:(){
          }, /* ()    {
                      //Navigator.of(context).pushReplacementNamed(SignupSelectionScreen.routeName);
                      introductionSkip();
                      },*/
          onSkip: ()     {
            introductionSkip();
          },
          skipFlex: 0,
          nextFlex: 0,
          skip: const Text('Skip',style: TextStyle(color: Colors.green,fontWeight: FontWeight.w700,fontSize: 18),),
          next: const Icon(Icons.arrow_forward),
          done: Container(),//Container(child: const Text('C’EST PARTI!', style: TextStyle(fontWeight: FontWeight.w700,color: Colors.green,fontSize: 18))),
          dotsDecorator: const DotsDecorator(
              size: Size(15.0, 15.0),
              color: Color(0xFFBDBDBD),
              activeSize: Size(15.0, 15.0),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0)),),
              activeColor: Colors.green)
      );
  }

}

