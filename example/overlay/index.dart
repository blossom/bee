import 'package:polymer/polymer.dart';
import 'dart:html';

void main() {
  // manually initialize Polymer
  initPolymer().run(() {});

  Polymer.onReady.then((e) {
    querySelector('#launch-example1').onClick.listen((MouseEvent event) {
      querySelector('.q-example1-overlay').show();
    });

    querySelector('#launch-example2').onClick.listen((MouseEvent event) {
      querySelector('.q-example2-overlay').show();
    });

    querySelector('.q-example3-overlay').onHide.listen((CustomEvent event) {
      window.alert('Overlay closed.');
    });
    querySelector('.q-example3-overlay').onShow.listen((CustomEvent event) {
      window.alert('Overlay opened.');
    });
    querySelector('#launch-example3').onClick.listen((MouseEvent event) {
      querySelector('.q-example3-overlay').show();
    });
  });
}