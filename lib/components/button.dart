import 'package:web_ui/web_ui.dart';

class ButtonSubmitComponent extends WebComponent {
  String type = 'button';
  bool disabled = false;

  void focus() {
    getShadowRoot('x-button').query('.q-x-button').focus();
  }
}