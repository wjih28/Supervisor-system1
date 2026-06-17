import 'dart:io';
import 'dart:convert';

void main() {
  try {
    final file = File('openapi.json').readAsStringSync();
    final json = jsonDecode(file);
    if (json.containsKey('definitions')) {
      final defs = json['definitions'];
      if (defs != null) {
        if (defs.containsKey('stage 6 (trio discussion)')) {
          print('Stage 6 cols:');
          print(defs['stage 6 (trio discussion)']['properties']?.keys?.toList());
        } else {
          print('stage 6 not found in definitions');
        }
        if (defs.containsKey('sprvsr_grades')) {
          print('sprvsr_grades cols:');
          print(defs['sprvsr_grades']['properties']?.keys?.toList());
        } else {
          print('sprvsr_grades not found in definitions');
        }
      }
    } else {
      print('definitions key not found');
      print(json.keys.toList());
      print(json);
    }
  } catch (e) {
    print('Error: $e');
  }
}
