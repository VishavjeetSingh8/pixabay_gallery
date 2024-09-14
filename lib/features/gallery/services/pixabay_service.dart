import 'dart:convert';
import 'package:http/http.dart' as http;

class PixabayService {
  final String _apiKey = '45979263-3c19f5537500c12c93eeeee6e'; // Replace with your Pixabay API key
  final String _baseUrl = 'https://pixabay.com/api/';

  Future<Map<String, dynamic>> fetchImages(String query, int page) async {
    final response = await http.get(Uri.parse(
        '$_baseUrl?key=$_apiKey&q=$query&page=$page&image_type=photo&per_page=100'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {'hits':[]};
    }
  }
}