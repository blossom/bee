import 'dart:html';
import 'package:web_ui/web_ui.dart';

class LoadingComponent extends WebComponent {
  String color = "#505050";

  void inserted() {
    getShadowRoot('b-loading').query('.q-b-loading').style.color = this.color;
  }
}