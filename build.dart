import 'package:polymer/builder.dart';

void main(List<String> args) {
 var entryPoints = ['example/button/index.html',
                    'example/editable_text/index.html',
                    'example/secret/index.html',
                    'example/loading/index.html',
                    'example/popover/index.html',
                    'example/tooltip/index.html',
                    'example/overlay/index.html',
                    'example/hide-tooltip/index.html',
                    'example/textarea/index.html'];
 lint(entryPoints: entryPoints, options: parseOptions(args));
}