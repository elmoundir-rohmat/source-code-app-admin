/*
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:talkfootball/constants.dart';

class DoNotAskAgainDialog extends StatefulWidget {
  final String title, subTitle, positiveButtonText, negativeButtonText;
  final Function onPositiveButtonClicked;
  final String doNotAskAgainText;
  final String dialogKeyName;

  DoNotAskAgainDialog(
      this.dialogKeyName,
      this.title,
      this.subTitle,
      this.positiveButtonText,
      this.negativeButtonText,
      this.onPositiveButtonClicked, {
        this.doNotAskAgainText = 'Never ask again',
      });

  @override
  _DoNotAskAgainDialogState createState() => _DoNotAskAgainDialogState();
}

class _DoNotAskAgainDialogState extends State<DoNotAskAgainDialog> {
  bool doNotAskAgain = false;

  _updateDoNotShowAgain() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(kUpdateDialogKeyName, false);
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoAlertDialog(
        title: Text(widget.title),
        content: Text(widget.subTitle),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(
              widget.positiveButtonText,
            ),
            onPressed: widget.onPositiveButtonClicked,
          ),
          CupertinoDialogAction(
            child: Text(
              widget.doNotAskAgainText,
            ),
            onPressed: () {
              Navigator.pop(context);
              _updateDoNotShowAgain();
            },
          ),
          CupertinoDialogAction(
            child: Text(
              widget.negativeButtonText,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    }
    return AlertDialog(
      title: Text(
        widget.title,
        style: TextStyle(fontSize: 24),
      ),
      content: FittedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(widget.subTitle),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: doNotAskAgain,
                    onChanged: (val) {
                      setState(() {
                        doNotAskAgain = val;
                      });
                    },
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      doNotAskAgain = doNotAskAgain == false;
                    });
                  },
                  child: Text(
                    widget.doNotAskAgainText,
                    style: TextStyle(color: Colors.grey,
                  ),
                ),
                ),],
            )
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(widget.positiveButtonText),
          onPressed: doNotAskAgain ? null : widget.onPositiveButtonClicked,
        ),
        FlatButton(
          child: Text(
            widget.negativeButtonText,
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () async {
            Navigator.pop(context);
            if (doNotAskAgain) {
              _updateDoNotShowAgain();
            }
          },
        ),
      ],
    );
  }
}*/
