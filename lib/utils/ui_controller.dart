import 'package:flutter/material.dart';




class UiController {
  BuildContext context;



  UiController({
    required this.context
  });



  void showDialogBox(Map<String, dynamic> obj) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text(obj["title"]),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (obj["message"] != null) Text(obj["message"]),
              ],
            ),
            actions: [
              if (obj["onConfirm"] != null)
              TextButton(
                onPressed: () {
                  obj["onConfirm"]();
                  Navigator.of(dialogContext).pop();
                },
                child: Text(obj["confirmText"] ?? "OK"),
              ),
              if (obj["onCancel"] != null)
              TextButton(
                onPressed: () {
                  obj["onCancel"]();
                  Navigator.of(dialogContext).pop();
                },
                child: Text(obj["onCancelText"] ?? "Ακύρωση"),
              ),
              if (obj["onCancel"] == null && obj["onConfirm"] == null)
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text("Εντάξει"),
              ),
            ],
          );
        },
      );
    }
}