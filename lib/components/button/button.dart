import 'package:polymer/polymer.dart';
import 'dart:html';

@CustomTag('b-button')
class BeeButton extends ButtonElement with Polymer, Observable {

  @published String size = "medium";
  @published String look = "default";
  
  
  BeeButton.created() : super.created() {
     polymerCreated();
  }
  

}