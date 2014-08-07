import 'dart:async';
import "dart:html";
import "package:polymer/polymer.dart";

/* 
 * <b-safe-html> based on Guenter Zoechbauer's feedback on stackoverflow.
 * Thank you! ( http://stackoverflow.com/a/20869025/837709 )
 * 
 */


@CustomTag("b-safe-html")
class SafeHtml extends PolymerElement  {

  @published String model;

  NodeValidator nodeValidator;
  bool isInitialized = false;

  SafeHtml.created() : super.created() {
    nodeValidator = new NodeValidatorBuilder()
    ..allowHtml5();
  }

  void modelChanded(old) {
    if(isInitialized) {
      _addFragment();
    }
  }

  void _addFragment() {
    var fragment = new DocumentFragment.html(model, validator: nodeValidator);
    $["container"].nodes
    ..clear()
    ..add(fragment);

  }

  @override
  void attached() {
    super.attached();
    Timer.run(() {
      _addFragment();
      isInitialized = true;
    });
  }
}