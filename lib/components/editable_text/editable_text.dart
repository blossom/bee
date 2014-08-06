import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:async';
import 'package:css_animation/css_animation.dart';
import 'package:escape_handler/escape_handler.dart';


@CustomTag('b-editable-text')
class BeeEditableText extends PolymerElement {

  static const EventStreamProvider<CustomEvent> updateEvent = const EventStreamProvider<CustomEvent>('update');
  static const EventStreamProvider<CustomEvent> editEvent = const EventStreamProvider<CustomEvent>('edit');

  @published
  String value = "";
  @published
  bool allowNewline = false;
  @observable
  bool inEditMode = false;

  String fontSize = '14';
  String lineHeight = '21';
  String placeholder = '';
  String color = '505050';
  String _previousValue;
  String _elementTimestamp = "0";
  StreamSubscription _keyDownSubscription;
  EscapeHandler _escapeHandler = new EscapeHandler();

  BeeEditableText.created() : super.created() {}

  void attached() {
    var _contentArea = shadowRoot.querySelector('.q-editable-text-contentarea');
    _contentArea.style.fontSize = '${fontSize}px';
    _contentArea.style.lineHeight = '${lineHeight}px';
    _contentArea.style.color = '#${color}';
  }

  int _calculateEditIconTopPosition() {
    int editIconHeight = 13;
    // There are edge cases where pixel values can have decimal places. That's
    // why we parse the num and then round to int.
    double distanceToFontTop = (num.parse(lineHeight).round() - num.parse(fontSize).round()) / 2;
    double distanceInsideFont = (num.parse(fontSize).round() - editIconHeight) / 2;
    return (distanceToFontTop + distanceInsideFont - (editIconHeight / 2) ).toInt();
  }

  void edit(event) {
    value = _sanitizeValue(value);
    _previousValue = value;
    inEditMode = true;

    var start = 0, end = 0;
    if (event != null) {
      // Retrieve the selection range.
      // see http://stackoverflow.com/a/17966995/837709
      var range = window.getSelection().getRangeAt(0);
      var selectionLength = range.endOffset - range.startOffset;
      // By setting the start element we can get the end selection
      // even if our display element contains other elements and not only
      // text. This doesn't work for a selection range over multiple elements.
      range.setStart(event.target, 0);
      end = range.toString().length;
      start = end - selectionLength;
      event.preventDefault();
    }

    _keyDownSubscription = window.onKeyDown.listen(null);
    _keyDownSubscription.onData(this._keyDownHandler);

    // need to wait a bit until the templates have been updated since we switched to EDIT
    // TODO investigate if a Future.delay is good enough
    new Timer(new Duration(milliseconds:50), () {
      var textarea = shadowRoot.querySelector('.q-editable-text-textarea');
      if (textarea != null) {
        textarea.focus();
        textarea.setSelectionRange(start, end);

        _elementTimestamp = new DateTime.now().millisecondsSinceEpoch.toString();
        var deactivateFuture = _escapeHandler.addWidget(int.parse(_elementTimestamp));
        deactivateFuture.then((_) {
          value = _previousValue;
          _switchToVisual();
        });
        textarea.dataset['element-timestamp'] = _elementTimestamp;
        dispatchEvent(new CustomEvent("edit"));
      }
    });
  }

  void update(event) {
    if (event != null) { event.preventDefault(); }
    _switchToVisual();
    highlight();
  }

  void _switchToVisual() {
    if (!allowNewline) {
      // creating newlines should be prevented, but people still can paste text
      // containing newlines which we want to clean up
      value = value.replaceAll('\n', ' ');
    }
    _escapeHandler.removeWidget(int.parse(_elementTimestamp));
    inEditMode = false;
    if (_keyDownSubscription != null) { try { _keyDownSubscription.cancel(); } on StateError {}; }
    dispatchEvent(new CustomEvent("update"));
  }

  get valueIsEmpty {
    return value == null || value == '';
  }

  get placeholderIsEmpty {
    return placeholder == null || placeholder == '';
  }

  void removed() {
    if (_keyDownSubscription != null) { try { _keyDownSubscription.cancel(); } on StateError {}; }
  }

  Stream<CustomEvent> get onUpdate => EditableTextComponent.updateEvent.forTarget(this);

  Stream<CustomEvent> get onEdit => EditableTextComponent.editEvent.forTarget(this);

  void highlight({String color: "#fffddd"}) {
    Element content = shadowRoot.querySelector('.q-editable-text-contentarea');
    content.style.backgroundColor = color;
    var animation = new CssAnimation('background-color', color, "transparent");
    animation.apply(content, duration: 2000);
  }

  void _keyDownHandler(KeyboardEvent event) {
    if (event.keyCode == KeyCode.ENTER) {
      bool optionKey = event.shiftKey || event.altKey || event.altGraphKey || event.ctrlKey;
      if (!(allowNewline && optionKey)) {
        event.preventDefault();
        update(null);
      }
    }
  }

  String _sanitizeValue(value) {
    if (value == null) {
      return "";
    } else {
      return value;
    }
  }
}