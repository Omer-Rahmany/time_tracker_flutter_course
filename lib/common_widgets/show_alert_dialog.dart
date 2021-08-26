import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<bool> showAlertDialog(
  BuildContext context, {
  @required title,
  @required content,
  @required defaultActionText,
  cancelActionText,
}) {
  if (!Platform.isIOS) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            if (cancelActionText != null)
              TextButton(
                child: Text(cancelActionText),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            TextButton(
              child: Text(defaultActionText),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );
  } else {
    return showCupertinoDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              if (cancelActionText != null)
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(cancelActionText)),
              TextButton(
                child: Text(defaultActionText),
                onPressed: () => Navigator.of(dialogContext).pop(true),
              ),
            ],
          );
        });
  }
}
