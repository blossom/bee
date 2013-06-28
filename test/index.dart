import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:unittest/unittest.dart';


// Import Tests
import 'popover_test.dart';

void main() {
  useHtmlEnhancedConfiguration();

  runPopoverTests();
}