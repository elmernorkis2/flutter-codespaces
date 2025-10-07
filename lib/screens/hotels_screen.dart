import 'package:flutter/material.dart';
import 'hotel_details_screen.dart';
import 'hotel_booking_screen.dart';
import 'dart:math';
import 'package:flutter_app/services/location_service.dart';
import 'package:flutter_app/screens/host_hotel_form.dart';

class HotelsScreen extends StatefulWidget {
  const HotelsScreen({super.key});

  @override
  State<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  Map<String, Map<String, List<String>>> locationData = {};
  final List<Map<String, dynamic>> allHotels = [];

  final List<String> hotelImages = [
    'https://images.unsplash.com/photo-1582719478175-ff1f4f9c9f6f?w=600',
    'https://images.unsplash.com/photo-1560347876-aeef00ee58a1?w=600',
    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600',
    'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=600',
    'https://images.unsplash.com/photo-1576671081837-4c3b1b3b3b3b?w=600',
    'https://images.unsplash.com/photo-1582719478181-2f7c9e7f9f6f?w=600',
    'https://images.unsplash.com/photo-1582719478182-3f7c9e7f9f6f?w=600',
    'https://images.unsplash.com/photo-1582719478183-4f7c9e7f9f6f?w=600',
    'https://images.unsplash.com/photo-1582719478184-5f7c9e7f9f6f?w=600',
    'https://images.unsplash.com/photo-1582719478185-6f7c9e7f9f6f?w=600',
  ];

  final List<String> hotelTags = [
    'Beachfront',
    'Luxury',
    'Budget',
    'Family-Friendly',
    'Business',
    'Romantic',
    'Eco-Friendly',
    'Pet-Friendly',
  ];

  String? selectedCountry;
  String? selectedCity;
  String? selectedTown;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLocationData().then((rawData) {
      print('✅ Location data loaded: ${rawData.length} countries');

      setState(() {
        locationData = rawData;
        generateHotelsFromLocationData();
        isLoading = false;
      });
    }).catchError((error) {
      print('❌ Error loading location data: $error');

      locationData = {
        "Thailand": {
          "Bangkok": ["Phra Khanong", "Sukhumvit"],
          "Chiang Mai": ["Old City", "Nimman"]
        },
        "Japan": {
          "Tokyo": ["Shibuya", "Shinjuku"],
          "Osaka": ["Namba", "Umeda"]
        }
      };
      generateHotelsFromLocationData();
      isLoading = false;
    });
  }

  void generateHotelsFromLocationData() {
    final random = Random();

    locationData.forEach((country, cities) {
      cities.forEach((city, towns) {
        for (final town in towns) {
          allHotels.add({
            'name': 'Hotel ${allHotels.length + 1}',
            'image': hotelImages[random.nextInt(hotelImages.length)],
            'price': '₱${(random.nextInt(30) + 10) * 100}/night',
            'rating':
                double.parse((random.nextDouble() * 2 + 3).toStringAsFixed(1)),
            'country': country,
            'location': city,
            'town': town,
            'favorite': random.nextBool(),
            'tag': hotelTags[random.nextInt(hotelTags.length)],
          });
        }
      });
    });
  }

  List<Map<String, dynamic>> get filteredHotels {
    return allHotels.where((hotel) {
      final matchCountry =
          selectedCountry == null || hotel['country'] == selectedCountry;
      final matchCity =
          selectedCity == null || hotel['location'] == selectedCity;
      final matchTown = selectedTown == null || hotel['town'] == selectedTown;
      return matchCountry && matchCity && matchTown;
    }).toList();
  }

  Widget buildStarRating(double rating) {
    final fullStars = rating.floor();
    final hasHalfStar = rating - fullStars >= 0.5;

    return Row(
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(Icons.star, color: Colors.amber, size: 16);
        } else if (index == fullStars && hasHalfStar) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 16);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 16);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hotels')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final countries = locationData.keys.toList();
    final citiesByCountry =
        selectedCountry != null && locationData.containsKey(selectedCountry)
            ? locationData[selectedCountry]!
            : {};
    final townsByCity =
        selectedCity != null && citiesByCountry.containsKey(selectedCity)
            ? citiesByCountry[selectedCity]!
            : [];
    final hotels = filteredHotels;

    return Scaffold(
      appBar: AppBar(title: const Text('Hotels')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                children: [
                  DropdownButton<String>(
                    hint: const Text('Select Country'),
                    value: selectedCountry,
                    items: countries.map((country) {
                      return DropdownMenuItem<String>(
                        value: country,
                        child: Text(country),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCountry = value;
                        selectedCity = null;
                        selectedTown = null;
                      });
                    },
                  ),
                  if (selectedCountry != null)
                    DropdownButton<String>(
                      hint: const Text('Select City'),
                      value: selectedCity,
                      items: citiesByCountry.keys.map((city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCity = value;
                          selectedTown = null;
                        });
                      },
                    ),
                  if (selectedCity != null)
                    DropdownButton<String>(
                      hint: const Text('Select Town'),
                      value: selectedTown,
                      items: townsByCity.map((town) {
                        return DropdownMenuItem<String>(
                          value: town,
                          child: Text(town),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedTown = value;
                        });
                      },
                    ),
                ],
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.home_work),
              label: const Text('Become a Host'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HostHotelForm()),
                );
              },
            ),
            const SizedBox(height: 16),
            Flexible(
              child: hotels.isEmpty
                  ? const Center(child: Text('No hotels match your filters.'))
                  : ListView.builder(
                      itemCount: hotels.length,
                      itemBuilder: (context, index) {
                        final hotel = hotels[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  leading: Image.network(
                                    hotel['image'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image,
                                                size: 50),
                                  ),
                                  title: Text(hotel['name']),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '${hotel['location']} • ${hotel['town']}'),
                                      Text(hotel['tag'],
                                          style: const TextStyle(
                                              color: Colors.blueGrey,
                                              fontSize: 12)),
                                      buildStarRating(hotel['rating']),
                                    ],
                                  ),
                                  trailing: Text(hotel['price']),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            HotelDetailsScreen(hotel: hotel),
                                      ),
                                    );
                                  },
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              HotelBookingScreen(hotel: hotel),
                                        ),
                                      );
                                    },
                                    child: const Text('Book Now'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
