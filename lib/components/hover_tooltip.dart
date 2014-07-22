import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:css_animation/css_animation.dart';

class HoverTooltipComponent extends WebComponent {

  /*
   * Returns true if the relatedTarget is or is inside the given Element.
   *
   * This helps to simulate mouseenter and mouseleave event which is not
   * supported by Safari.
   *
   * This has been inspired by jQuery's way to emulate mouseenter & mouseleave
   * event.
   */
  static bool previousElementOfEventIsOrIsInsideElement(Element element, MouseEvent event) {
    if (event.relatedTarget == null) {
      return false;
    }
    return (event.relatedTarget != element &&
        !element.contains(event.relatedTarget));
  }

  void showTooltip(MouseEvent event) {
    Element hoverAreaWrapper = getShadowRoot('b-hover-tooltip').query('.q-hover-tooltip-hover-area-wrapper');
    if (previousElementOfEventIsOrIsInsideElement(hoverAreaWrapper, event)) {
      Element tooltip = getShadowRoot('b-hover-tooltip').query('.q-hover-tooltip-tooltip');
      tooltip.style.display = 'block';
      var animation = new CssAnimation('opacity', 0, 1);
      animation.apply(tooltip, duration: 200);
    }
  }

  void hideTooltip(MouseEvent event) {
    Element hoverAreaWrapper = getShadowRoot('b-hover-tooltip').query('.q-hover-tooltip-hover-area-wrapper');
    if (previousElementOfEventIsOrIsInsideElement(hoverAreaWrapper, event)) {
      Element tooltip = getShadowRoot('b-hover-tooltip').query('.q-hover-tooltip-tooltip');
      var animation = new CssAnimation('opacity', 1, 0);
      animation.apply(tooltip, duration: 100, onComplete: () {
        tooltip.style.display = 'none';
      });
    }
  }
}
