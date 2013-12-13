import 'package:web_ui/web_ui.dart';
import 'dart:html';

class BeeButtonComponent extends WebComponent {
  /*
   * look = default, primary, link
   * size = default, small, medium
   * type = button, submit
   */
  String type = 'button';
  String look = 'default';
  String size = 'default';
  bool disabled = false;

  String paddingLeft;
  String paddingRight;
  String paddingTop;
  String paddingBottom;

  void inserted() {
    this._setStyles();
  }

  void _setStyles() {
    Element button = getShadowRoot('b-button').query('.q-b-button');
    if (paddingLeft != null) { button.style.paddingLeft = "${paddingLeft}px"; }
    if (paddingRight != null) { button.style.paddingRight = "${paddingRight}px"; }
    if (paddingTop != null) { button.style.paddingTop = "${paddingTop}px"; }
    if (paddingBottom != null) { button.style.paddingBottom = "${paddingBottom}px"; }
  }

  void focus() {
    getShadowRoot('b-button').query('.q-b-button').focus();
  }
}