/*
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:talkfootball/constants.dart';
//import '../widgets/do_not_ask_again_dialog.dart';
//import 'package:talkfootball/models/app_version.dart';
import '../widgets/do_not_show_again_dialog.dart';

class UpdateApp extends StatefulWidget {
  final Widget child;

  UpdateApp({this.child});

  @override
  _UpdateAppState createState() => _UpdateAppState();
}

class _UpdateAppState extends State<UpdateApp> {
  @override
  void initState() {
    super.initState();

    checkLatestVersion(context);
  }

  checkLatestVersion(context) async {
    await Future.delayed(Duration(seconds: 5));

    //Add query here to get the minimum and latest app version

    //Change
    //Here is a sample query to ParseServer(open-source NodeJs server with MongoDB database)
    var queryBuilder = QueryBuilder<AppVersion>(AppVersion())
      ..orderByDescending("publishDate")
      ..setLimit(1);

    var response = await queryBuilder.query();

    if (response.success) {
      //Change
      //Parse the result here to get the info
      AppVersion appVersion = response.results[0] as AppVersion;
      Version minAppVersion = Version.parse(appVersion.minAppVersion);
      Version latestAppVersion = Version.parse(appVersion.version);

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      Version currentVersion = Version.parse(packageInfo.version);

      if (minAppVersion > currentVersion) {
        _showCompulsoryUpdateDialog(
          context,
          "Please update the app to continue\n${appVersion.about ?? ""}",
        );
      } else if (latestAppVersion > currentVersion) {
        SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

        bool showUpdates = false;
        showUpdates = sharedPreferences.getBool(kUpdateDialogKeyName);
        if (showUpdates != null && showUpdates == false) {
          return;
        }

        _showOptionalUpdateDialog(
          context,
          "A newer version of the app is available\n${appVersion.about ?? ""}",
        );
        print('Update available');
      } else {
        print('App is up to date');
      }
    }
  }

  _showOptionalUpdateDialog(context, String message) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        String title = "App Update Available";
        String btnLabel = "Update Now";
        String btnLabelCancel = "Later";
        String btnLabelDontAskAgain = "Don't ask me again";
        return DoNotAskAgainDialog(
          kUpdateDialogKeyName,
          title,
          message,
          btnLabel,
          btnLabelCancel,
          _onUpdateNowClicked,
          doNotAskAgainText:
          Platform.isIOS ? btnLabelDontAskAgain : 'Never ask again',
        );
      },
    );
  }

  _onUpdateNowClicked() {
    print('On update app clicked');
  }

  _showCompulsoryUpdateDialog(context, String message) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "App Update Available";
        String btnLabel = "Update Now";
        return Platform.isIOS
            ? new CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(
                btnLabel,
              ),
              isDefaultAction: true,
              onPressed: _onUpdateNowClicked,
            ),
          ],
        )
            : new AlertDialog(
          title: Text(
            title,
            style: TextStyle(fontSize: 22),
          ),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text(btnLabel),
              onPressed: _onUpdateNowClicked,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}*/
