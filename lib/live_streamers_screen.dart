import 'package:flutter/material.dart';
import 'live_room_screen.dart';
import 'live_user.dart';

class LiveStreamersScreen extends StatelessWidget {
  final List<LiveUser> streamers;

  LiveStreamersScreen({super.key})
      : streamers = [
          LiveUser(
            name: 'StreamerOne',
            thumbnailUrl: 'https://via.placeholder.com/150',
            viewers: 12,
          ),
          LiveUser(
            name: 'StreamerTwo',
            thumbnailUrl: 'https://via.placeholder.com/150',
            viewers: 45,
          ),
        ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Streamers')),
      body: streamers.isEmpty
          ? const Center(child: Text('No one is live right now.'))
          : ListView.builder(
              itemCount: streamers.length,
              itemBuilder: (context, index) {
                final user = streamers[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            user.thumbnailUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.arrow_drop_down),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              LiveRoomScreen(user: user),
                                        ),
                                      );
                                    },
                                    child: const Text('Watch'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('${user.viewers} viewers'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
