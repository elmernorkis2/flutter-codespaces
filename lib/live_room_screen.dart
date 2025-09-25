import 'package:flutter/material.dart';
import 'live_user.dart';

class LiveRoomScreen extends StatelessWidget {
  final LiveUser user;

  const LiveRoomScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(user.thumbnailUrl),
            const SizedBox(height: 20),
            Text('${user.viewers} viewers watching'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add stream logic here
              },
              child: const Text('Join Stream'),
            ),
          ],
        ),
      ),
    );
  }
}
