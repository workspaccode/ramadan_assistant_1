import 'dart:convert';

import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://api.alquran.cloud/v1/ayah/1/ar.tajweed');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    print(jsonDecode(response.body)['data']['text']);
  } else {
    print('Failed');
  }
}
