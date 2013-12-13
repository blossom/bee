import 'package:web_ui/web_ui.dart';
import 'dart:async';
import 'dart:html';

@observable
class SecretComponent extends WebComponent {
  static const EventStreamProvider<CustomEvent> inputEvent = const EventStreamProvider<CustomEvent>('input');
  static const EventStreamProvider<CustomEvent> blurEvent = const EventStreamProvider<CustomEvent>('blur');
  static const EventStreamProvider<CustomEvent> focusEvent = const EventStreamProvider<CustomEvent>('focus');
  String placeholder = '';
  String name = 'secret';
  bool required = false;
  String value = '';
  bool _hasFocus = false;
  int _selectionStart = 0;
  int _selectionEnd = 0;
  bool _passwordActive = true;
  DivElement _passwordWrapper;
  DivElement _textWrapper;

  void inserted() {
    this._passwordWrapper = getShadowRoot('b-secret').query('.q-b-secret-password-wrapper');
    this._textWrapper = getShadowRoot('b-secret').query('.q-b-secret-text-wrapper');
    this._updateState();
  }

  void focus() {
    this._activeInput.focus();
  }

  void hideSecret() {
    this._passwordActive = true;
    this._updateState();
  }

  void _toggleShowSecret (event) {
    event.preventDefault();
    // retrieve the current selection before the field is toggled
    // after the toggle the same selection will be applied again
    this._retrieveSelection();
    this._passwordActive = !this._passwordActive;
    this._updateState();
    this._activeInput.focus();
    this._updateSelection();
  }

  _updateState() {
    if (this._passwordActive) {
      this._passwordWrapper.style.display = 'block';
      this._textWrapper.style.display = 'none';
    } else {
      this._passwordWrapper.style.display = 'none';
      this._textWrapper.style.display = 'block';
    }
  }

  void _input() {
    this.dispatchEvent(new CustomEvent("input"));
  }

  void _blur(event) {
    // TODO find a better way
    // figure out if the user toggled the password or blurred the password field
    // by checking which element is focused

    // in Chrome Version 26.0.1410.65 the focus event gets fired around 12x milli seconds after the blur event
    // in Firefox the focus event is fired before the blur event
    // in IE9 the focus event is fired around 9x milliseconds after the blur event
    // picked 200 milliseconds for our timer to be on the safe side
    new Timer(new Duration(milliseconds:200), () {
      Element textField = getShadowRoot('b-secret').query('.q-text-field');
      Element passwordField = getShadowRoot('b-secret').query('.q-password-field');
      if (document.activeElement != textField && document.activeElement != passwordField) {
        this.dispatchEvent(new CustomEvent("blur"));
        this._hasFocus = false;
      }
    });
  }

  void _focus(event) {
    if (!this._hasFocus) {
      this.dispatchEvent(new CustomEvent("focus"));
    }
    this._hasFocus = true;
  }

  String _retrieveSelection() {
    this._selectionStart = this._activeInput.selectionStart;
    this._selectionEnd = this._activeInput.selectionEnd;
    return '';
  }

  String _updateSelection() {
    this._activeInput.selectionStart = this._selectionStart;
    this._activeInput.selectionEnd = this._selectionEnd;
    return '';
  }

  InputElement get _activeInput {
    if (_passwordActive) {
      return getShadowRoot('b-secret').query('.q-password-field');
    } else {
      return getShadowRoot('b-secret').query('.q-text-field');
    }
  }

  get _focusClass {
    if (_hasFocus) {
      return 'secret-has-focus';
    } else {
      return '';
    }
  }

  Stream<CustomEvent> get onInput => inputEvent.forTarget(this);
  Stream<CustomEvent> get onBlur => blurEvent.forTarget(this);
  Stream<CustomEvent> get onFocus => focusEvent.forTarget(this);
}