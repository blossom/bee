import 'package:escape_handler/escape_handler.dart';
import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';


class State {
  static const ACTIVE = const State._(0);
  static const INACTIVE = const State._(1);

  final int value;
  const State._(this.value);
}

class AutocompleteEntry {

  final String id;
  final String searchableText;
  final Element _element;

  AutocompleteEntry(this.id, this.searchableText, this._element) {
    // remove the data-id and data-text since we don't need them in the html
    _element.dataset.remove('text');
    _element.dataset.remove('id');
  }

  get sanitizedHtml {
    var validator = new NodeValidatorBuilder()..allowHtml5();
    var documentFragment = document.body.createFragment(_element.outerHtml, validator: validator);
    return documentFragment;
  }
}

@CustomTag('b-autocomplete')
class BeeAutocompleteComponent extends PolymerElement {
  
  String maxHeight = "200px";
  String width = "200px";
  String addText = "Add &#8230;";
  String placeholder = "";
  String fontSize = "14px";
  
  
  State state = State.INACTIVE;
  int _elementTimestamp = 0;
  EscapeHandler _escapeHandler = new EscapeHandler();
  AutocompleteEntry activeEntry = null;
  StreamSubscription _keyUp;
  
  @observable List entries = new List();
  @observable List filteredEntries = new List();
  @observable String filterQuery;
  
  BeeAutocompleteComponent.created(): super.created();
  
  void attached() {
    _keyUp = document.onKeyUp.listen(null);
    _keyUp.onData(keyUpHandler);
    updateEntriesFromDataSource();
    this._setCssStyles();
  }

  void _setCssStyles() {
    Element mainArea = shadowRoot.querySelector('.q-autocomplete-main-area');
    mainArea.style.width = width;
  }
  
  String focusOnInput() {
    Element field = shadowRoot.querySelector('.q-autocomplete-form-input');
    field.focus();
    return '';
  }
  
  void updateEntriesFromDataSource() {
    entries.clear();
    Element dataSource = shadowRoot.querySelector('.data-source');
    if (dataSource != null) {
      for (Element element in dataSource.children) {
        bool containsText = element.dataset.containsKey('text');
        bool containsID = element.dataset.containsKey('id');
        if (containsText && containsID) {
          entries.add(new AutocompleteEntry(element.dataset['id'],
              element.dataset['text'], element.clone(true)));
        } else if (dataSource.children.first is TemplateElement) {
        } else {
          print("Missing data-text or data-id from an source entry.");
        }
      }
    } else {
      print("Missing a data source like <div class=\"data-source\"><div data-text=\"dart\">Dart</div></div>");
    }
  }
  
  void clear() {
    filterQuery = '';
    filteredEntries.clear();
  }
  
  void reset() {
    filterQuery = '';
    _updateFilteredEntries();
  }
  
  
  void activate(Event event) {
    event.preventDefault();
    if (state != State.ACTIVE) {
      state = State.ACTIVE;
      Element field = shadowRoot.querySelector('.q-autocomplete-activation-area');
      field.style.display = 'none';
    }
  }
  
  void select(Event event) {
    event.preventDefault();
    var detail = {'id': activeEntry.id, 'text': activeEntry.searchableText};
    dispatchEvent(new CustomEvent("select", detail: detail));
    reset();
    focusOnInput();
  }
  
  void blurred() {
    _escapeHandler.removeWidget(_elementTimestamp);
    // the element is deactive and we give it 0 as timestamp to make sure
    // you can't find it by getting the max of all elements with the data attribute
    _elementTimestamp = 0;
    clear();
    state = State.INACTIVE;
    Element field = shadowRoot.querySelector('.q-autocomplete-activation-area');
    field.style.display = 'block';
  }
  
  void focused() {
    _elementTimestamp = new DateTime.now().millisecondsSinceEpoch;
    var deactivateFuture = _escapeHandler.addWidget(_elementTimestamp);
    deactivateFuture.then((_) {
      blurred();
    });
    _updateFilteredEntries();
  }
  
  void _setToActiveEntry(AutocompleteEntry entry) {
    activeEntry = entry;
  }
  
  void _updateFilteredEntries() {
    var sanitizedQuery = filterQuery.trim().toLowerCase();
    var filteredEntries = [];
    if (sanitizedQuery == "") {
      filteredEntries = new List.from(entries);
    } else {
      filteredEntries = entries.where((AutocompleteEntry entry) {
        return entry.searchableText.trim().toLowerCase().contains(sanitizedQuery);
      });
    }
    filteredEntries.clear();
    filteredEntries.addAll(filteredEntries);
    if (filteredEntries.isNotEmpty) {
      activeEntry = filteredEntries.first;
    }
  }
  
  void keyUpHandler(KeyboardEvent event) {
    Element input = shadowRoot.querySelector('.q-autocomplete-form-input');
    // @TODO: 
    // check non-shadowdom node
    if (document.activeElement.hashCode == input.hashCode) {
      switch (new KeyEvent.wrap(event).keyCode) {
        case KeyCode.UP:
          _moveUp();
          break;
        case KeyCode.DOWN:
          _moveDown();
          break;
      }
    }
  }
  _moveUp() {
    var tmp = filteredEntries.reversed.skipWhile((entry) => entry != activeEntry);
    if (tmp.length >= 2) {
      activeEntry = tmp.elementAt(1);
    }
  }

  _moveDown() {
    var tmp = filteredEntries.skipWhile((entry) => entry != activeEntry);
    if (tmp.length >= 2) {
      activeEntry = tmp.elementAt(1);
    }
  }

  void removed() {
    if (this._keyUp != null) { try { this._keyUp.cancel(); } on StateError {}; }
  }
}