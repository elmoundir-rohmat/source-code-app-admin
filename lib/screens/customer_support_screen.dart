import 'package:crisp/crisp_view.dart';
import 'package:crisp/models/main.dart';
import 'package:crisp/models/user.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter/material.dart';

class CustomerSupportScreen extends StatefulWidget {
  static const routeName = '/cutomer-support-screen';
  @override
  _CustomerSupportScreenState createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {

    });
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
    final name = routeArgs['name'];
    final email = routeArgs['email'];
    final photourl = routeArgs['photourl'];
    final phone = routeArgs['phone'];

    crisp.initialize(
      websiteId: '60f0e9b0-fe79-423f-a11f-c037e0ca92cc',
      //locale: 'pt-br',
    );

    crisp.register(
      CrispUser(
        email: email,
        avatar: photourl,
        nickname: name,
        phone: phone,
      ),
    );
    crisp.setMessage("Hi");

    return Scaffold(
      body : Material(
          child: Stack(
            children: <Widget>[
              SafeArea(
                child: CrispView(
                  loadingWidget: Center(
                    child: CircularProgressIndicator( valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),),
                  ),
                ),
              ),
/*              SafeArea(
                child: Positioned(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back_ios,),
                  ),
                ),
              ),*/

            ],
          ),
      ),
    );
/*    Scaffold(
      body: CrispView(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        loadingWidget: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );*/
  }
}
