import 'package:polymer/polymer.dart';
import 'dart:html';

void main() {
  // manually initialize Polymer
  initPolymer().run(() {});

  Polymer.onReady.then((e) {
    querySelector('#launch').onClick.listen((MouseEvent event) {
      querySelector('.q-example-overlay').show();
    });
  });
}