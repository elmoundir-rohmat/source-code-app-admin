/*


import 'package:flutter_login_facebook/flutter_login_facebook.dart';

class AppAuth{
  final facebookLogin = FacebookLogin();

  Future<FacebookLoginResult> facebooklogin(context)async{
    return await facebookLogin.logIn(
        permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,]);
    }
  Future<bool> logout()async {
Future<bool> returns;
    facebookLogin.logOut().then((value) {
      returns = Future.value(true);
    }).onError((error, stackTrace) {
      returns = Future.value(false);
    });
    return returns;
  }
  }

final auth = AppAuth();*/
