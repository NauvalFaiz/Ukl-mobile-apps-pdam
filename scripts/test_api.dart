import 'dart:convert';
import 'dart:io';

void main() async {
  final request = await HttpClient().postUrl(Uri.parse('https://learn.smktelkom-mlg.sch.id/pdam/app-owners/auth'));
  request.headers.set('content-type', 'application/json');
  request.add(utf8.encode(jsonEncode({'email':'Nauval@gmail.com', 'password':'12345678'})));
  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();
  print('STATUS: ${response.statusCode}');
  print('BODY: $responseBody');
}
