library htmlHelpers;

import 'dart:html';

bool insideNodeWhere(Element element, bool f(Element element)) {
  if (element.parent != null) {
    if (f(element.parent)) {
      return true;
    } else {
      return insideNodeWhere(element.parent, f);
    }
  } else {
    return false;
  }
}

bool insideOrIsNodeWhere(Element element, bool f(Element element)) {
  if (f(element)) {
    return true;
  } else {
    return insideNodeWhere(element, f);
  }
}