import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:unittest/unittest.dart';

import 'package:bee/components/popover.dart';

void runPopoverTests() {
  group("b-popover", () {

    Element host;

    setUp(() {
      host = new Element.html('<div is="b-popover"><span class="launch-area">here</span><div class="body">yeah</div></div>');
      var popover = new PopoverComponent()
        ..host = host;
      var component = new ComponentItem(popover)..create();
      document.body.nodes.add(popover.host);
      component.insert();
    });

    tearDown(() {
      host.remove();
    });

    test("contents are rendered properly", () {
      expect(query('.launch-area').innerHtml, equals('here'));
      expect(query('.body').innerHtml, equals('yeah'));
    });

  });
}