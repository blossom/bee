import 'dart:async';
import 'dart:html';
import 'package:web_ui/web_ui.dart';
import '../utils/html_helpers.dart';

class State {
  static const ACTIVE = const State._(0);
  static const DEACTIVE = const State._(1);

  final int value;
  const State._(this.value);
}

@observable
class PopoverComponent extends WebComponent {

  StreamSubscription documentClick;
  StreamSubscription documentTouch;
  StreamSubscription toggleClick;
  StreamSubscription toggleTouch;
  StreamSubscription keySubscription;
  String elementTimestamp;
  String width;
  State state = State.DEACTIVE;
  DivElement _popoverWrapper;

  // CSS Styles
  String left;
  String right;
  String top;
  String bottom;
  String arrowLeft;
  String arrowRight;
  String arrowTop;
  String arrowBottom;

  void inserted() {
    this._popoverWrapper = getShadowRoot('b-popover').query('.q-b-popover-wrapper');
    this._updateState(this.state);
    this._setCssStyles();
    this.documentClick = document.onClick.listen(null);
    this.documentClick.onData(this._hideClickHandler);
    this.documentTouch = document.onTouchStart.listen(null);
    this.documentTouch.onData(this._hideClickHandler);
    this.toggleClick = getShadowRoot('b-popover').query('.q-launch-area').onClick.listen(null);
    this.toggleClick.onData(this.toggle);
    this.toggleTouch = getShadowRoot('b-popover').query('.q-launch-area').onTouchStart.listen(null);
    this.toggleTouch.onData(this.toggle);
    this.keySubscription = window.onKeyUp.listen(null);
    this.keySubscription.onData(this._keyHandler);
  }

  void removed() {
    if (this.documentClick != null) { try { this.documentClick.cancel(); } on StateError {}; }
    if (this.documentTouch != null) { try { this.documentTouch.cancel(); } on StateError {}; }
    if (this.toggleClick != null) { try { this.toggleClick.cancel(); } on StateError {}; }
    if (this.toggleTouch != null) { try { this.toggleTouch.cancel(); } on StateError {}; }
  }

  void toggle(event) {
    if (event != null) {event.preventDefault(); }
    if (this.state == State.ACTIVE) {
      _updateState(State.DEACTIVE);
    } else {
      _updateState(State.ACTIVE);
    }
  }

  void _setCssStyles() {
    Element arrow = getShadowRoot('b-popover').query('.q-b-popover-arrow');
    if (this.left != null) { this._popoverWrapper.style.left = this.left; }
    if (this.right != null) { this._popoverWrapper.style.right = this.right; }
    if (this.top != null) { this._popoverWrapper.style.top = this.top; }
    if (this.bottom != null) { this._popoverWrapper.style.bottom = this.bottom; }
    if (this.arrowLeft != null) { arrow.style.left = this.arrowLeft; }
    if (this.arrowRight != null) { arrow.style.right = this.arrowRight; }
    if (this.arrowTop != null) { arrow.style.top = this.arrowTop; }
    if (this.arrowBottom != null) { arrow.style.bottom = this.arrowBottom; }
  }

  void _hideClickHandler(event) {
    // close the overlay in case the user clicked outside of the overlay content area
    // only exception is when the user clicked on the toggle area (this case is handled by toggle)
    bool clickOutsidePopover = !insideOrIsNodeWhere(event.target, (element) => element.dataset['element-timestamp'] == this.elementTimestamp);
    bool clickOnToggleArea = insideOrIsNodeWhere(event.target, (element) => element.classes.contains('q-launch-area'));
    if (clickOutsidePopover && !clickOnToggleArea) {
      _updateState(State.DEACTIVE);
    }
  }

  _updateState(var state) {
    this.state = state;
    if (this.state == State.ACTIVE) {
      this._popoverWrapper.style.display = 'block';
      // the attribute elementTimestamp represents the time the popover was activated which is important for 2 reasons
      // * identify the popover in the dom
      // * find out which layer to close on esc
      // this implmentation assumes that multiple elements can't be activated at the exact same millisecond
      this.elementTimestamp = new DateTime.now().millisecondsSinceEpoch.toString();
    } else {
      this._popoverWrapper.style.display = 'none';
      // the element is deactive and we give it 0 as timestamp to make sure
      // you can't find it by getting the max of all elements with the data attribute
      this.elementTimestamp = "0";
    }
  }

  void _keyHandler(KeyboardEvent event) {
    // expected app behavior: when ESC is pressed only the latest active element handles ESC
    //
    // this function removes this popover in case it is the youngest in the dom
    // which is determinded by the data attribute elementTimestamp
    //
    // TODO: potential race condition!
    // if we have two overlays (A & B) and the topmost overlay (A) manages to
    // remove itself from the dom before the second overlay (B) can query for all overlays (A & B)
    // it will remove itself
    if (event.keyCode == 27) {
      Iterable<int> escElements = queryAll('[data-element-timestamp]').map((element) => int.parse(element.dataset['element-timestamp']));
      String youngestEscElement = escElements.fold(0, (prev, element) => (prev > element) ? prev : element).toString();
      if (youngestEscElement == this.elementTimestamp) {
        this._updateState(State.DEACTIVE);
      }
    }
  }
}