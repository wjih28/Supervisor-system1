import 'dart:io';
import 'dart:convert';

void main() {
  var data = jsonDecode(File('openapi.json').readAsStringSync());
  // ignore: avoid_print
  print(data['definitions']['supervisor']['properties'].keys.toList());
}
