import 'package:escape_handler/escape_handler.dart';
import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'dart:js' as js;


class AutocompleteEntry {

  final String id;
  final String searchableText;
  final Element _element;

  AutocompleteEntry(this.id, this.searchableText, this._element) {
    // remove the data-id and data-text since we don't need them in the html
    _element.dataset.remove('text');
    _element.dataset.remove('id');
  }

  get elementHtml {
    return _element.outerHtml;
  }
}

@CustomTag('b-autocomplete')
class BeeAutocompleteComponent extends PolymerElement {
  
  static const EventStreamProvider<CustomEvent> selectEvent = const EventStreamProvider<CustomEvent>('select');
  Stream<CustomEvent> get onSelect => selectEvent.forTarget(this);
  
  @published
  String maxHeight = "200px";
  @published
  String width = "200px";
  @published
  String addText = "Add &#8230;";
  @published
  String placeholder = "";
  @published
  String fontSize = "14px";
  
  int _elementTimestamp = 0;
  EscapeHandler _escapeHandler = new EscapeHandler();
  @observable AutocompleteEntry activeEntry = null;
  StreamSubscription _keyUp;
  
  @observable bool isActive = false;
  ObservableList<AutocompleteEntry> entries = new ObservableList<AutocompleteEntry>();
  ObservableList<AutocompleteEntry> filteredEntries = new ObservableList<AutocompleteEntry>();
  @observable String filterQuery = '';
  
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
  
  void focusOnInput(var x) {
    Element field = shadowRoot.querySelector('.q-autocomplete-form-input');
    field.focus();
  }
  
  void updateEntriesFromDataSource() {
    entries.clear();
    Element dataSource = this.querySelector('.data-source');
    
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
    updateFilteredEntries();
  }
  
  
  void activate(Event event, var details, Node node) {
    event.preventDefault();
    if (!isActive) {
      isActive = true;
      Element field = shadowRoot.querySelector('.q-autocomplete-activation-area');
      field.style.display = 'none';

      new Future(() => null).then(focusOnInput);
    }
  }
  
  void select(Event event, var details, Node node) {
    if (event != null) {
      event.preventDefault();
    }
    var detail = {'id': activeEntry.id, 'text': activeEntry.searchableText};
    dispatchEvent(new CustomEvent("select", detail: detail));
    filterQuery = activeEntry.searchableText;
    // clear suggestions because entry has been chosen.
    filteredEntries.clear();
    focusOnInput(null);
  }
  
  void blurred(Event event, var details, Node node) {
    _escapeHandler.removeWidget(_elementTimestamp);
    // the element is deactive and we give it 0 as timestamp to make sure
    // you can't find it by getting the max of all elements with the data attribute
    _elementTimestamp = 0;
    clear();
    isActive = false;
    Element field = shadowRoot.querySelector('.q-autocomplete-activation-area');
    field.style.display = 'block';
  }
  
  void focused() {
    _elementTimestamp = new DateTime.now().millisecondsSinceEpoch;
    var deactivateFuture = _escapeHandler.addWidget(_elementTimestamp);
    deactivateFuture.then((_) {
      blurred(null, {}, null);
    });
    updateFilteredEntries();
  }
  
  void setToActiveEntry(Event event, var details, Node node) {
    activeEntry = filteredEntries.singleWhere((entry) => entry.id == node.dataset['entry-id']);
  }
  
  void updateFilteredEntries() {
    var sanitizedQuery = filterQuery.trim().toLowerCase();
    var tmpFilteredEntries = [];
    if (sanitizedQuery == "") {
      tmpFilteredEntries = new List.from(entries);
    } else {
      tmpFilteredEntries = entries.where((AutocompleteEntry entry) {
        return entry.searchableText.trim().toLowerCase().contains(sanitizedQuery);
      });
    }
    filteredEntries.clear();
    filteredEntries.addAll(tmpFilteredEntries);

    if (filteredEntries.isNotEmpty) {
      activeEntry = filteredEntries.first;
    }
  }
  
  void keyUpHandler(KeyboardEvent event) {
    Element input = shadowRoot.querySelector('.q-autocomplete-form-input');
    var activeElement = js.context.callMethod('wrap',
             [document.activeElement]);

    if (activeElement == this || activeElement == input) {
      switch (new KeyEvent.wrap(event).keyCode) {
        case KeyCode.UP:
          _moveUp();
          break;
        case KeyCode.DOWN:
          _moveDown();
          break;
        case KeyCode.ENTER:
          select(null, null, null);
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