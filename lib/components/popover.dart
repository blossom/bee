import 'dart:async';
import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:escape_handler/escape_handler.dart';
import '../utils/html_helpers.dart';

class State {
  static const ACTIVE = const State._(0);
  static const DEACTIVE = const State._(1);

  final int value;
  const State._(this.value);
}

@observable
class PopoverComponent extends WebComponent {
  static const EventStreamProvider<CustomEvent> showEvent = const EventStreamProvider<CustomEvent>('show');
  static const EventStreamProvider<CustomEvent> hideEvent = const EventStreamProvider<CustomEvent>('hide');

  StreamSubscription documentClick;
  StreamSubscription documentTouch;
  StreamSubscription toggleClick;
  StreamSubscription toggleTouch;
  String elementTimestamp = "0";
  String width;
  State state = State.DEACTIVE;
  DivElement _popoverWrapper;
  EscapeHandler _escapeHandler = new EscapeHandler();

  // CSS Styles
  String position = "relative";
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

  Stream<CustomEvent> get onShow => showEvent.forTarget(this);
  Stream<CustomEvent> get onHide => hideEvent.forTarget(this);

  void _setCssStyles() {
    Element arrow = getShadowRoot('b-popover').query('.q-b-popover-arrow');
    if (this.position != null) { this._popoverWrapper.style.position = this.position; }
    if (this.left != null) { this._popoverWrapper.style.left = this.left; }
    if (this.right != null) { this._popoverWrapper.style.right = this.right; }
    if (this.top != null) { this._popoverWrapper.style.top = this.top; }
    if (this.bottom != null) { this._popoverWrapper.style.bottom = this.bottom; }
    if (this.arrowLeft != null) { arrow.style.left = this.arrowLeft; }
    if (this.arrowRight != null) { arrow.style.right = this.arrowRight; }
    if (this.arrowTop != null) { arrow.style.top = this.arrowTop; }
    if (this.arrowBottom != null) { arrow.style.bottom = this.arrowBottom; }
  }

  void _hideClickHandler(Event event) {
    // close the overlay in case the user clicked outside of the overlay content area
    // only exception is when the user clicked on the toggle area (this case is handled by toggle)
    bool clickOutsidePopover = !insideOrIsNodeWhere(event.target, (element) => element.hashCode == _popoverWrapper.hashCode);
    Element launchArea = getShadowRoot('b-popover').query('.q-launch-area');
    bool clickOnToggleArea = insideOrIsNodeWhere(event.target, (element) => element.hashCode == launchArea.hashCode);
    if (clickOutsidePopover && !clickOnToggleArea) {
      _updateState(State.DEACTIVE);
    }
  }

  void _updateState(var newState) {
    state = newState;
    if (state == State.ACTIVE) {
      this._popoverWrapper.style.display = 'block';
      // the attribute elementTimestamp represents the time the popover was activated which is important for 2 reasons
      // * identify the popover in the dom
      // * find out which layer to close on esc
      // this implmentation assumes that multiple elements can't be activated at the exact same millisecond
      this.elementTimestamp = new DateTime.now().millisecondsSinceEpoch.toString();
      var deactivateFuture = _escapeHandler.addWidget(int.parse(elementTimestamp));
      deactivateFuture.then((_) {
        _updateState(State.DEACTIVE);
      });
      dispatchEvent(new CustomEvent("show"));
    } else {
      _popoverWrapper.style.display = 'none';
      _escapeHandler.removeWidget(int.parse(elementTimestamp));
      // the element is deactive and we give it 0 as timestamp to make sure
      // you can't find it by getting the max of all elements with the data attribute
      elementTimestamp = "0";
      dispatchEvent(new CustomEvent("hide"));
    }
  }
}