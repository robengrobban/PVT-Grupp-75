import 'package:flutter/material.dart';
import 'package:flutter_app/theme.dart' as Theme;

class BigGradientDialogShell extends StatelessWidget {
  final Widget child;
  final String title;
  final bool showArrow;
  final double titleSize;

  const BigGradientDialogShell({Key key, this.child, this.title, this.showArrow = true, this.titleSize = 16}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
      contentPadding: EdgeInsets.all(0),
      content: Container(
        padding: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            gradient: Theme.appGradiant
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: titleSize,),
            ),
            Divider(
              color: Colors.black12,
              indent: 20,
              endIndent: 20,
              thickness: 2,
            ),
            if(showArrow) Align(
              alignment: Alignment.topLeft,
              child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: BackButton(
                    color: Colors.white,
                  )),
            ),
            child
          ],
        ),
      ),
    );
  }

}