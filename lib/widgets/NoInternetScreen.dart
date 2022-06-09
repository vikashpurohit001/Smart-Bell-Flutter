
import 'package:flutter/material.dart';
import 'package:smart_bell/utilities/TextStyles.dart';

class NoInternetScreen extends StatelessWidget {
  Function() onPressed;
   NoInternetScreen({Key key,@required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 8.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Please check internet connection",
                style: TextStyles().black18Normal),
            SizedBox(height: 5,),
            ElevatedButton(child: Text('Retry',style: TextStyles.white18Normal,),onPressed: onPressed,)
          ],
        ),
      ),
    );
  }
}
