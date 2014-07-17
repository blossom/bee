import 'package:polymer/builder.dart';

void main(List<String> args) {
 lint(entryPoints: ['example/button/index.html',
                    'example/button/index.html'], options: parseOptions(args));
}