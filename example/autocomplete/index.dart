import 'package:polymer/polymer.dart';
import 'dart:html';

void main() {
  // manually initialize Polymer
  initPolymer().run(() {});
  
  Polymer.onReady.then((e) {
      querySelector('b-autocomplete').onSelect.listen((CustomEvent event) {
        querySelector('.selected-item').innerHtml = 'Selected: ' + event.detail.toString();
      });
  });
}
