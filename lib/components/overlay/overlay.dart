import 'package:polymer/polymer.dart';
import 'dart:async';
import 'dart:html';
import 'package:escape_handler/escape_handler.dart';

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

@CustomTag('b-overlay')
class BeeOverlay extends PolymerElement {
  static const EventStreamProvider<CustomEvent> showEvent = const EventStreamProvider<CustomEvent>('show');
  static const EventStreamProvider<CustomEvent> hideEvent = const EventStreamProvider<CustomEvent>('hide');
  StreamSubscription _clickSubscription;
  // Listen to touch start for improved UX. Some Browsers like iOS Safari have a
  // delay until the click event is fired which is not desired for elements like
  // links or buttons.
  StreamSubscription _touchSubscription;
  @published String width = "600px";
  DivElement _backdrop;
  @published String elementTimestamp = "0";
  State _state = State.DEACTIVE;
  EscapeHandler _escapeHandler = new EscapeHandler();

  BeeOverlay.created() : super.created() {}

  void attached() {
    _add_scrollbar_info();
    _backdrop = shadowRoot.querySelector('.q-b-overlay-backdrop');
    _updateState(_state);
    shadowRoot.querySelector('.q-overlay').style.width = width;
  }

  void hide() {
    _updateState(State.DEACTIVE);
  }

  void show() {
    _updateState(State.ACTIVE);
  }

  void detached() {
    _hide();
  }

  Stream<CustomEvent> get onShow => showEvent.forTarget(this);
  Stream<CustomEvent> get onHide => hideEvent.forTarget(this);

  /*
   * Scollbar width detection. Adds either the class scrollbar0, scrollbar15 or scrollbar20
   * to the body element.
   *
   * See http://jdsharp.us/jQuery/minute/calculate-scrollbar-width.php
   */
  void _add_scrollbar_info() {
    var validator = new NodeValidatorBuilder()..allowElement('div', attributes: ['style']);
    var template = """
    <div style="width:50px;height:50px;overflow:hidden;position:absolute;top:-200px;left:-200px;">
      <div style="height:100px;">
    </div>
    """;
    Element div = new Element.html(template, validator: validator);
    // append the div, do the calculation and then remove it
    querySelector('body').append(div);
    int width1 = div.clientWidth;
    div.style.overflowY = 'scroll';
    int width2 = div.clientWidth;
    div.remove();
    int scrollbarWidth = width1 - width2;
    switch (scrollbarWidth) {
      case 0:
        querySelector('body').classes.add('scrollbar0');
        break;
      case 20:
        querySelector('body').classes.add('scrollbar20');
        break;
      default:
        querySelector('body').classes.add('scrollbar15');
    }
  }

  /*
   * Close the overlay in case the user clicked outside of the overlay
   * content area.
   */
  void _removeClickHandler(event) {
    Element backdrop;
    if (event.target.classes.contains('q-b-overlay-backdrop')) {
      backdrop = event.target;
    } else if (event.target.classes.contains('q-b-overlay-backdrop-close')) {
      backdrop = event.target.parent;
    }
    if (backdrop != null && backdrop.contains(shadowRoot.querySelector('.q-overlay'))) {
      event.preventDefault();
      _updateState(State.DEACTIVE);
    }
  }

  _updateState(var newState) {
    _state = newState;
    if (_state == State.ACTIVE) {
      _show();
    } else {
      _hide();
    }
  }

  void _show() {
    _backdrop.style.display = 'block';
    // the attribute elementTimestamp represents the time the popover was activated which is important for 2 reasons
    // * identify the overlay in the dom
    // * find out which layer/element to close on esc
    // this implmentation assumes that multiple elements can't be activated at the exact same millisecond
    elementTimestamp = new DateTime.now().millisecondsSinceEpoch.toString();
    var hideFuture = _escapeHandler.addWidget(int.parse(elementTimestamp));
    hideFuture.then((_) {
      _updateState(State.DEACTIVE);
    });
    querySelector("html").classes.add('overlay-backdrop-active');
    _clickSubscription = document.onClick.listen(null);
    _clickSubscription.onData(_removeClickHandler);
    _touchSubscription = document.onTouchStart.listen(null);
    _touchSubscription.onData(_removeClickHandler);
    dispatchEvent(new CustomEvent("show"));
  }

  void _hide() {
    _backdrop.style.display = 'none';
    _escapeHandler.removeWidget(int.parse(elementTimestamp));
    // the element is deactive and we give it 0 as timestamp to make sure
    // you can't find it by getting the max of all elements with the data attribute
    elementTimestamp = "0";
    if (_clickSubscription != null) { try { _clickSubscription.cancel(); } on StateError {}; }
    if (_touchSubscription != null) { try { _touchSubscription.cancel(); } on StateError {}; }
    List<Element> backdrops = querySelectorAll('.q-b-overlay-backdrop');
    // TODO check for visible getter in the future, see https://code.google.com/p/dart/issues/detail?id=6526
    Iterable<Element> visibleBackdrops = backdrops.where((Element backdrop) => backdrop.style.display != 'none');
    if (visibleBackdrops.length == 0) {
      // to reenable scrolling we reset the body's style attribute (but only if we are hiding the last overlay)
      querySelector("html").classes.remove('overlay-backdrop-active');
    }
    dispatchEvent(new CustomEvent("hide"));
  }
}