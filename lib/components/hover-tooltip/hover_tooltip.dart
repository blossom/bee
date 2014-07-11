import 'dart:html';
import 'dart:async';

import 'package:polymer/polymer.dart';

@CustomTag('b-hover-tooltip')
class BeeHoverTooltip extends PolymerElement {
  StreamSubscription _mouseEnterStream;
  StreamSubscription _mouseLeaveStream;
  Element _tooltip;
  Element _hoverArea;

  
  BeeHoverTooltip.created() : super.created() {}

  void attached() {
    _tooltip = shadowRoot.querySelector('.b-hover-tooltip-tooltip-wrapper');
    _hoverArea = shadowRoot.querySelector('.q-hover-tooltip-hover-area-wrapper');
        
    _mouseEnterStream = _hoverArea.onMouseEnter.listen(null)..onData(showTooltip);
    _mouseLeaveStream = _hoverArea.onMouseLeave.listen(null)..onData(hideTooltip);
  }

  void showTooltip(MouseEvent event) {
    _tooltip.style.display = 'block';
  }

  void hideTooltip(MouseEvent event) {
    _tooltip.style.display = 'none';
  }
}
