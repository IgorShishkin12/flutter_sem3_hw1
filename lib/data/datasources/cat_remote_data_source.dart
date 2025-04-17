import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class CatRemoteDataSource {
  Future<Map<String, dynamic>> getRandomCat();

  Future<Map<String, dynamic>> getCatDetails(String id);
}

class CatRemoteDataSourceImpl implements CatRemoteDataSource {
  final http.Client client;

  CatRemoteDataSourceImpl(this.client);

  @override
  Future<Map<String, dynamic>> getRandomCat() async {
    final response = await client.get(
      Uri.parse('https://api.thecatapi.com/v1/images/search?has_breeds=1'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)[0];
    } else {
      throw Exception('Failed to load cat');
    }
  }

  @override
  Future<Map<String, dynamic>> getCatDetails(String id) async {
    final response = await client.get(
      Uri.parse('https://api.thecatapi.com/v1/images/$id'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load cat details');
    }
  }
}
