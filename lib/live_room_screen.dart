import 'package:flutter/material.dart';
import 'live_user.dart';

class LiveRoomScreen extends StatelessWidget {
  final LiveUser user;

  const LiveRoomScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🎥 Full-screen background using thumbnail
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(user.thumbnailUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🧑‍🎤 Streamer info bar
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(user.thumbnailUrl),
                  radius: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_drop_down, color: Colors.white),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.remove_red_eye,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${user.viewers}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 🚪 Exit button
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // 💬 Live chat panel
          Positioned(
            bottom: 120,
            left: 16,
            right: 16,
            child: Container(
              height: 120,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView(
                children: const [
                  Text('User123: Hello!',
                      style: TextStyle(color: Colors.white)),
                  Text('FanGirl: You’re amazing!',
                      style: TextStyle(color: Colors.white)),
                  Text('ViewerX: 🔥🔥🔥',
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),

          // 🧩 Chat input
          Positioned(
            bottom: 70,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Send a message...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // 🎁 Gift & interaction buttons
          Positioned(
            bottom: 10,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'gift',
                  mini: true,
                  backgroundColor: Colors.pink,
                  child: const Icon(Icons.card_giftcard),
                  onPressed: () {},
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'like',
                  mini: true,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.favorite),
                  onPressed: () {},
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'share',
                  mini: true,
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.share),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // 🎬 Join Stream button
          Positioned(
            bottom: 10,
            left: 16,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(Icons.live_tv),
              label: const Text('Join Stream', style: TextStyle(fontSize: 16)),
              onPressed: () {
                // Add stream logic here
              },
            ),
          ),
        ],
      ),
    );
  }
}
