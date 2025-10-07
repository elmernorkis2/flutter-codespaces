import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, Map<String, List<String>>>> fetchLocationData() async {
  final url =
      Uri.parse('https://phcash-a8f69.web.app/countries_states_cities.json');
  print('🚀 fetchLocationData() started');

  final response = await http.get(url);
  if (response.statusCode == 200) {
    try {
      final List<dynamic> raw = json.decode(response.body);
      final Map<String, Map<String, List<String>>> locationMap = {};

      for (final country in raw) {
        final countryName = country['name'];
        final List<dynamic> states = country['states'] ?? [];

        final Map<String, List<String>> stateMap = {};
        for (final state in states) {
          final stateName = state['name'];
          final List<dynamic> cities = state['cities'] ?? [];

          final cityNames =
              cities.map((city) => city['name'] as String).toList();
          stateMap[stateName] = cityNames;
        }

        locationMap[countryName] = stateMap;
      }

      print('✅ Parsed location map with ${locationMap.length} countries');
      return locationMap;
    } catch (e) {
      print('❌ JSON parsing error: $e');
      throw Exception('Invalid location data format');
    }
  } else {
    print('❌ Failed to load location data: ${response.statusCode}');
    throw Exception('Failed to load location data');
  }
}
