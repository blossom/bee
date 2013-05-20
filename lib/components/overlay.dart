import 'dart:async';
import 'dart:html';
import 'package:web_ui/web_ui.dart';

/*
 *
 * tests:
 *
 * test esc behavior -> should close on esc of no younger element is active
 * test scrollbar callculation
 * test should hide itself,
 * test if provided closeCallback gets calles
 * test if component still work without provided closeCallback
 * test component still works but shows a warning if closeCallback is not callable
 *
 */

class State {
  static const ACTIVE = const State._(0);
  static const DEACTIVE = const State._(1);

  final int value;
  const State._(this.value);
}

@observable
class OverlayComponent extends WebComponent {

  StreamSubscription clickSubscription;
  StreamSubscription touchSubscription;
  StreamSubscription keySubscription;
  String elementTimestamp;
  String width = "600px";
  DivElement _backdrop;
  State state = State.DEACTIVE;

  void created() {
    this._add_scrollbar_info();
  }

  void inserted() {
    this._backdrop = getShadowRoot('b-overlay').query('.q-b-overlay-backdrop');
    this._updateState(this.state);
    getShadowRoot('b-overlay').query('.q-overlay').style.width = this.width;
  }

  void hide() {
    _updateState(State.DEACTIVE);
  }

  void show() {
    _updateState(State.ACTIVE);
  }

  void removed() {
    this._hide();
  }

  void _add_scrollbar_info() {
    // scrollbar width detection
    // http://jdsharp.us/jQuery/minute/calculate-scrollbar-width.php
    Element div = new Element.html('<div style="width:50px;height:50px;overflow:hidden;position:absolute;top:-200px;left:-200px;"><div style="height:100px;"></div>');
    // append the div, do the calculation and then remove it
    query('body').append(div);
    int width1 = div.clientWidth;
    div.style.overflowY = 'scroll';
    int width2 = div.clientWidth;
    div.remove();
    int scrollbarWidth = width1 - width2;
    switch (scrollbarWidth) {
      case 0:
        query('body').classes.add('scrollbar0');
        break;
      case 20:
        query('body').classes.add('scrollbar20');
        break;
      default:
        query('body').classes.add('scrollbar15');
    }
  }

  void _removeClickHandler(event) {
    // close the overlay in case the user clicked outside of the overlay content area
    Element backdrop;
    if (event.target.classes.contains('q-b-overlay-backdrop')) {
      backdrop = event.target;
    } else if (event.target.classes.contains('q-b-overlay-backdrop-close')) {
      backdrop = event.target.parent;
    }
    if (backdrop != null && backdrop.contains(getShadowRoot('b-overlay').query('.q-overlay[data-element-timestamp="${this.elementTimestamp}"]'))) {
      event.preventDefault();
      _updateState(State.DEACTIVE);
    }
  }

  _updateState(var state) {
    this.state = state;
    if (this.state == State.ACTIVE) {
      this._backdrop.style.display = 'block';
      // the attribute elementTimestamp represents the time the popover was activated which is important for 2 reasons
      // * identify the overlay in the dom
      // * find out which layer/element to close on esc
      // this implmentation assumes that multiple elements can't be activated at the exact same millisecond
      this.elementTimestamp = new DateTime.now().millisecondsSinceEpoch.toString();
      query("html").classes.add('overlay-backdrop-active');
      this.clickSubscription = document.onClick.listen(null);
      this.clickSubscription.onData(this._removeClickHandler);
      this.touchSubscription = document.onTouchStart.listen(null);
      this.touchSubscription.onData(this._removeClickHandler);
      this.keySubscription = window.onKeyUp.listen(null);
      this.keySubscription.onData(this._keyHandler);
    } else {
      this._hide();
    }
  }

  void _hide() {
    this._backdrop.style.display = 'none';
    // the element is deactive and we give it 0 as timestamp to make sure
    // you can't find it by getting the max of all elements with the data attribute
    this.elementTimestamp = "0";
    if (this.clickSubscription != null) { try { this.clickSubscription.cancel(); } on StateError {}; }
    if (this.touchSubscription != null) { try { this.touchSubscription.cancel(); } on StateError {}; }
    if (this.keySubscription != null) { try { this.keySubscription.cancel(); } on StateError {}; }
    List<Element> backdrops = queryAll('.q-b-overlay-backdrop');
    // TODO check for visible getter in the future, see https://code.google.com/p/dart/issues/detail?id=6526
    Iterable<Element> visibleBackdrops = backdrops.where((Element backdrop) => backdrop.style.display != 'none');
    if (visibleBackdrops.length == 0) {
      // to reenable scrolling we reset the body's style attribute (but only if we are hiding the last overlay)
      query("html").classes.remove('overlay-backdrop-active');
    }
  }

  void _keyHandler(KeyboardEvent event) {
    // expected app behavior: when ESC is pressed only the latest active element handles ESC
    //
    // this function removes this overlay in case it is the youngest in the dom
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