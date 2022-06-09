import 'dart:ui';

typedef MyTypedef(bool value);

class SessionDataController {
  // VoidCallback myFunction;
  // VoidCallback mySecondFunction;
  bool canDelete;

  void dispose() {
    //Remove any data that's will cause a memory leak/render errors in here
    // myFunction = null;
    // mySecondFunction = null;
    canDelete=false;
    ;
  }
}
