import 'package:polymer/builder.dart';

void main(List<String> args) {
 var entryPoints = ['example/button/index.html',
                    'example/loading/index.html',
                    'example/popover/index.html'];
 lint(entryPoints: entryPoints, options: parseOptions(args));
}