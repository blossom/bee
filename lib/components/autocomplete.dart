import 'dart:async';
import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:escape_handler/escape_handler.dart';


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

@observable
class AutocompleteComponent extends WebComponent {

  static const EventStreamProvider<CustomEvent> selectEvent = const EventStreamProvider<CustomEvent>('select');

  String maxHeight = "200px";
  String width = "200px";
  String addText = "Add &#8230;";
  String placeholder = "";
  String fontSize = "14px";

  StreamSubscription _keyUp;
  String _elementTimestamp = "0";
  EscapeHandler _escapeHandler = new EscapeHandler();
  @observable String _filterQuery = "";
  List _entries = toObservable([]);
  List _filteredEntries = toObservable([]);
  AutocompleteEntry _activeEntry = null;
  State _state = State.INACTIVE;
  Timer updateDataSourceTimer;

  void inserted() {
    _keyUp = document.onKeyUp.listen(null);
    _keyUp.onData(_keyUpHandler);
    updateEntriesFromDataSource();
    this._setCssStyles();
  }

  void _setCssStyles() {
    Element mainArea = getShadowRoot('b-autocomplete').query('.q-autocomplete-main-area');
    mainArea.style.width = width;
  }

  void activate(Event event) {
    event.preventDefault();
    if (_state != State.ACTIVE) {
      _state = State.ACTIVE;
      Element field = getShadowRoot('b-autocomplete').querySelector('.q-autocomplete-activation-area');
      field.style.display = 'none';
    }
  }

  void updateEntriesFromDataSource() {
    _entries.clear();
    Element dataSource = getShadowRoot('b-autocomplete').querySelector('.data-source');
    if (dataSource != null) {
      for (Element element in dataSource.children) {
        bool containsText = element.dataset.containsKey('text');
        bool containsID = element.dataset.containsKey('id');
        if (containsText && containsID) {
          _entries.add(new AutocompleteEntry(element.dataset['id'],
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
    _filterQuery = "";
    _filteredEntries.clear();
  }

  void reset() {
    _filterQuery = "";
    _updateFilteredEntries();
  }

  void removeSourceEntry(String dataID) {
    _entries.removeWhere((AutocompleteEntry entry) => entry.id == dataID);
    _updateFilteredEntries();
  }

  String focusOnInput() {
    Element field = getShadowRoot('b-autocomplete').querySelector('.q-autocomplete-form-input');
    field.focus();
    return '';
  }

  Stream<CustomEvent> get onSelect => selectEvent.forTarget(this);

  void _focused() {
    _elementTimestamp = new DateTime.now().millisecondsSinceEpoch.toString();
    var deactivateFuture = _escapeHandler.addWidget(int.parse(_elementTimestamp));
    deactivateFuture.then((_) {
      _blurred();
    });
    _updateFilteredEntries();
  }

  void _blurred() {
    _escapeHandler.removeWidget(int.parse(_elementTimestamp));
    // the element is deactive and we give it 0 as timestamp to make sure
    // you can't find it by getting the max of all elements with the data attribute
    _elementTimestamp = "0";
    clear();
    _state = State.INACTIVE;
    Element field = getShadowRoot('b-autocomplete').querySelector('.q-autocomplete-activation-area');
    field.style.display = 'block';
  }

  void _setToActiveEntry(AutocompleteEntry entry) {
    _activeEntry = entry;
  }

  void _select(Event event) {
    event.preventDefault();
    var detail = {'id': _activeEntry.id, 'text': _activeEntry.searchableText};
    dispatchEvent(new CustomEvent("select", detail: detail));
    reset();
    focusOnInput();
  }

  void _updateFilteredEntries() {
    var sanitizedQuery = _filterQuery.trim().toLowerCase();
    var filteredEntries = [];
    if (sanitizedQuery == "") {
      filteredEntries = new List.from(_entries);
    } else {
      filteredEntries = _entries.where((AutocompleteEntry entry) {
        return entry.searchableText.trim().toLowerCase().contains(sanitizedQuery);
      });
    }
    _filteredEntries.clear();
    _filteredEntries.addAll(filteredEntries);
    if (_filteredEntries.isNotEmpty) {
      _activeEntry = _filteredEntries.first;
    }
  }

  void _keyUpHandler(KeyboardEvent event) {
    Element input = getShadowRoot('b-autocomplete').querySelector('.q-autocomplete-form-input');
    if (document.activeElement == input) {
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
    var tmp = _filteredEntries.reversed.skipWhile((entry) => entry != _activeEntry);
    if (tmp.length >= 2) {
      _activeEntry = tmp.elementAt(1);
    }
  }

  _moveDown() {
    var tmp = _filteredEntries.skipWhile((entry) => entry != _activeEntry);
    if (tmp.length >= 2) {
      _activeEntry = tmp.elementAt(1);
    }
  }

  void removed() {
    if (this._keyUp != null) { try { this._keyUp.cancel(); } on StateError {}; }
  }
}