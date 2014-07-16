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
    _tooltip.classes.add('b-hover-tooltip-show');
    new Timer(const Duration(milliseconds: 10), _toggleAnimation);
  }
  
  void _toggleAnimation() {
    _tooltip.classes.toggle('b-hover-tooltip-animate');
  }

  void hideTooltip(MouseEvent event) {
    _toggleAnimation();
    new Timer(const Duration(milliseconds: 200), () {
      if (_tooltip.classes.contains('b-hover-tooltip-animate')) {
        // abort if there's an animation in progress after 200ms timeout
        return;
      }
      _tooltip.classes.remove('b-hover-tooltip-show');
    });  
  }
}
