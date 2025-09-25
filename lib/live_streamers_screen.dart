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
                  child: ListTile(
                    leading: Image.network(user.thumbnailUrl),
                    title: Text(user.name),
                    subtitle: Text('${user.viewers} viewers'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LiveRoomScreen(user: user),
                          ),
                        );
                      },
                      child: const Text('Watch'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
