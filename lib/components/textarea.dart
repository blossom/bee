import 'package:web_ui/web_ui.dart';
import 'dart:html';
import 'dart:math';
import 'dart:async';
import 'dart:convert';

class TextareaComponent extends WebComponent {
  static const EventStreamProvider<CustomEvent> blurEvent = const EventStreamProvider<CustomEvent>('blur');
  static const EventStreamProvider<CustomEvent> focusEvent = const EventStreamProvider<CustomEvent>('focus');
  @observable String value;
  @observable String placeholder = '';
  String minHeight;
  String paddingTop = '0';
  String paddingRight = '0';
  String paddingBottom = '0';
  String paddingLeft = '0';
  String fontSize = '14';
  String lineHeight = '21';
  String color = "505050";

  var _windowResize;
  var _textarea;
  var _shadow;
  final _htmlEscape = new HtmlEscape();

  void focus() {
    if (_textarea != null) {
      _textarea.focus();
    }
  }

  void inserted() {
    _textarea = getShadowRoot('b-textarea').query('.q-textarea-textarea');
    _shadow = getShadowRoot('b-textarea').query('.q-textarea-shadow');

    _textarea.style.paddingTop = '${paddingTop}px';
    _textarea.style.paddingRight = '${paddingRight}px';
    _textarea.style.paddingBottom = '${paddingBottom}px';
    _textarea.style.paddingLeft = '${paddingLeft}px';
    _textarea.style.fontSize = '${fontSize}px';
    _textarea.style.color = '#${color}';
    if (lineHeight == 'normal' || lineHeight == 'inherit') {
      _textarea.style.lineHeight = lineHeight;
    } else {
      _textarea.style.lineHeight = '${lineHeight}px';
    }

    if (minHeight != null) {
      _textarea.style.minHeight = '${minHeight}px';
      _shadow.style.minHeight = '${minHeight}px';
    }

    _shadow.style.fontSize = _textarea.getComputedStyle().fontSize;
    _shadow.style.fontFamily = _textarea.getComputedStyle().fontFamily;
    _shadow.style.fontWeight = _textarea.getComputedStyle().fontWeight;
    _shadow.style.lineHeight = _textarea.getComputedStyle().lineHeight;
    _shadow.style.paddingTop = _textarea.getComputedStyle().paddingTop;
    _shadow.style.paddingRight = _textarea.getComputedStyle().paddingRight;
    _shadow.style.paddingBottom = _textarea.getComputedStyle().paddingBottom;
    _shadow.style.paddingLeft = _textarea.getComputedStyle().paddingLeft;


    // when the text field span the whole window the width the real
    // width might change after resizing the window
    _windowResize = window.onResize.listen((_) {
      resize();
    });

    // run resize once to set the correct size
    resize();
  }

  /*
   * Allow to set the selection range of the text carret.
   */
  setSelectionRange(int start, int end) {
    _textarea = getShadowRoot('b-textarea').query('.q-textarea-textarea');
    _textarea.setSelectionRange(start, end);
  }

  /*
   * Resizing the textarea after every change of the value or in case the textarea has been resized.
   * Only works in case the window has been resized.
   *
   * The content of the shadow div used to calculate the size gets sanitzied since the provided
   * value could also include content from someone else then the currently editing user.
   *
   * Note:
   * If you fill a text area only with spaces end you reach the right side it won't break the line.
   * This can lead to unexpected behaviour for the autogrowing. Didn't find any solution
   * and Facebook has the same issue.
   */
  void resize() {
    _shadow.style.width = _textarea.getComputedStyle().width;
    var validator = new NodeValidatorBuilder()..allowElement('br');
    _shadow.setInnerHtml(_sanitizeInput(value), validator: validator);
    var _shadowHeight = _shadow.getComputedStyle().height;

    // Wait with the resize until the widget is rendered in the DOM. A textarea
    // has the height auto if it isn't a block element or not in the DOM.
    // Scheduling a microtask is fast enough to resize the textarea before it is
    // shown and delayed enough to get the proper pixel height.
    if (_shadowHeight == 'auto') {
      scheduleMicrotask(() => resize());
      return;
    }

    var newHeight;
    if (minHeight != null) {
      // There are edge cases where pixel values can have decimal places. That's
      // why we parse the num and then round to int.
      var height = num.parse(_shadowHeight.replaceAll('px', '')).round();
      newHeight = '${max(height, num.parse(minHeight).round())}px';
    } else {
      newHeight = _shadowHeight;
    }
    _textarea.style.height = newHeight;
  }

  void removed() {
    _windowResize.cancel();
  }

  Stream<CustomEvent> get onBlur => blurEvent.forTarget(this);

  _blur(Event event) {
    dispatchEvent(new CustomEvent("blur"));
  }

  Stream<CustomEvent> get onFocus => focusEvent.forTarget(this);

  _focus(Event event) {
    dispatchEvent(new CustomEvent("focus"));
  }

  /*
   * Sanitizes the input.
   *
   * The input gets escaped based on
   * https://www.owasp.org/index.php/XSS_%28Cross_Site_Scripting%29_Prevention_Cheat_Sheet#RULE_.231_-_HTML_Escape_Before_Inserting_Untrusted_Data_into_HTML_Element_Content
   *
   * Further whitespaces and new lines are used to create a container with a proper height.
   */
  String _sanitizeInput(input) {
    var computedHtml;
    if (input != null) {
      var escaptedHtml = _htmlEscape.convert(input);
      computedHtml = escaptedHtml
          .replaceAll(new RegExp(r'\n$'), '<br>&nbsp;')
          .replaceAll('\n', '<br>');
      // fill in at least one space to make sure the textarea is at least one line high
      if (computedHtml.length == 0) {
        computedHtml = "&nbsp;";
      }
      // fill in a non-breaking space in case there is only one whitespace
      // regex taken from http://stackoverflow.com/a/3469155/837709
      if (computedHtml.length == 1 && new RegExp(r'[^\S\n]').hasMatch(computedHtml)) {
        computedHtml = "&nbsp;";
      }
    } else {
      computedHtml = "&nbsp;";
    }
    return computedHtml;
  }

}
