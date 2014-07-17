import 'package:polymer/polymer.dart';
import 'dart:async';
import 'dart:html';

@CustomTag('b-secret')
class BeeSecret extends PolymerElement {

  @published String placeholder = 'Enter password here';
  @published String value;
  @published String name = 'secret';
  @published bool required = false;  
  
  DivElement _passwordWrapper;
  DivElement _textWrapper;
  bool _passwordActive = true;
  bool _hasFocus = false;
  int _selectionStart = 0;
  int _selectionEnd = 0;
  
  BeeSecret.created() : super.created() {
  }

  void attached() {
    
    _passwordWrapper = shadowRoot.querySelector('.q-b-secret-password-wrapper');
    _textWrapper =  shadowRoot.querySelector('.q-b-secret-text-wrapper');
    _updateState();
  }

  void focus() {
    _activeInput.focus();
  }

  void hideSecret() {
    _passwordActive = true;
    _updateState();
  }

  void toggleShowSecret (event) {
    event.preventDefault();
    // retrieve the current selection before the field is toggled
    // after the toggle the same selection will be applied again
    _retrieveSelection();
    _passwordActive = !this._passwordActive;
    _updateState();
    _activeInput.focus();
    _updateSelection();
  }
  void _updateState() {
    if (_passwordActive) {
      _passwordWrapper.style.display = 'block';
      _textWrapper.style.display = 'none';
    } else {
      _passwordWrapper.style.display = 'none';
      _textWrapper.style.display = 'block';
    }
  }
    
  void handleInput() {
    dispatchEvent(new CustomEvent("input"));
  }

  void handleBlur(event) {
    // TODO find a better way
    // figure out if the user toggled the password or blurred the password field
    // by checking which element is focused

    // in Chrome Version 26.0.1410.65 the focus event gets fired around 12x milli seconds after the blur event
    // in Firefox the focus event is fired before the blur event
    // in IE9 the focus event is fired around 9x milliseconds after the blur event
    // picked 200 milliseconds for our timer to be on the safe side
    new Timer(new Duration(milliseconds:200), () {
      Element textField = shadowRoot.querySelector('.q-text-field');
      Element passwordField = shadowRoot.querySelector('.q-password-field');
      if (document.activeElement != textField && document.activeElement != passwordField) {
        dispatchEvent(new CustomEvent("blur"));
        _hasFocus = false;
      }
    });
  }

  void handleFocus(event) {
    _hasFocus = true;
  }

  String _retrieveSelection() {
    _selectionStart = _activeInput.selectionStart;
    _selectionEnd = _activeInput.selectionEnd;
    return '';
  }

  String _updateSelection() {
    _activeInput.selectionStart = _selectionStart;
    _activeInput.selectionEnd = _selectionEnd;
    return '';
  }
    
  InputElement get _activeInput {
    if (_passwordActive) {
      return shadowRoot.querySelector('.q-password-field');
    } else {
      return shadowRoot.querySelector('.q-text-field');
    }
  }
  get focusClass {
    if (_hasFocus) {
      return 'secret-has-focus';
    } else {
      return '';
    }
  }

}