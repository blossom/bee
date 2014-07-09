import 'package:polymer/polymer.dart';
import 'dart:html';

@CustomTag('b-loading')
class BeeLoading extends PolymerElement {

  @published String color;
  String _defaultColor = "#505050";

  BeeLoading.created() : super.created() {
     polymerCreated();
  }

  void attached() {
    // Setting the color to the default color in case no color
    // has been provided through the color attribute.
    if (color == null) {
      updateColor(_defaultColor);
    }
  }

  void colorChanged(String oldValue, String newValue) {
    updateColor(newValue);
  }

  void updateColor(String value) {
    shadowRoot.querySelector('.q-b-loading').style.color = value;
  }
}