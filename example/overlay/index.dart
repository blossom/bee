import 'package:polymer/polymer.dart';
import 'dart:html';

// manually initialize Polymer
void main() {
  initPolymer().run(() {});

  Polymer.onReady.then((e) {
    print("weee");
    querySelector('#launch').onClick.listen((MouseEvent event) {
      querySelector('.q-example-overlay').show();
    });
  });
}