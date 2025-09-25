// Dart core libraries
import 'dart:async';
import 'dart:convert';
import 'dart:io';

// Flutter framework
import 'package:flutter/material.dart';

// Firebase packages
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// Third-party packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController phoneController = TextEditingController();

  SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PHCash Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('Enter your mobile number',
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                prefixText: '+66 ',
                border: OutlineInputBorder(),
                hintText: '9123456789',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final phone = phoneController.text;

                if (phone.isNotEmpty && phone.length >= 10) {
                  const simulatedOTP = '123456';

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OTPVerificationScreen(
                          expectedOTP: simulatedOTP),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter a valid mobile number')),
                  );
                }
              },
              child: const Text('Send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}

class OTPVerificationScreen extends StatefulWidget {
  final String expectedOTP;

  const OTPVerificationScreen({super.key, required this.expectedOTP});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  int _secondsRemaining = 60;
  bool _canResend = false;
  late String _currentOTP;

  @override
  void initState() {
    super.initState();
    _currentOTP = widget.expectedOTP;
    _startCountdown();
  }

  void _startCountdown() {
    _canResend = false;
    _secondsRemaining = 60;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        setState(() {
          _canResend = true;
        });
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  void _resendOTP() {
    setState(() {
      _currentOTP = '654321'; // Simulate new OTP
      _startCountdown();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('New OTP sent: $_currentOTP')),
    );
  }

  void _verifyOTP() {
    if (otpController.text == _currentOTP) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP Verified!')),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MPINSetupScreen()),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('Enter the 6-digit OTP sent to your number'),
            const SizedBox(height: 10),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter OTP',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyOTP,
              child: const Text('Verify'),
            ),
            const SizedBox(height: 20),
            Text(
              _canResend
                  ? 'Didn’t receive the code?'
                  : 'Resend available in $_secondsRemaining seconds',
              style: const TextStyle(color: Colors.grey),
            ),
            if (_canResend)
              TextButton(
                onPressed: _resendOTP,
                child: const Text('Resend OTP'),
              ),
          ],
        ),
      ),
    );
  }
}

class MPINSetupScreen extends StatefulWidget {
  const MPINSetupScreen({super.key});

  @override
  State<MPINSetupScreen> createState() => _MPINSetupScreenState();
}

class _MPINSetupScreenState extends State<MPINSetupScreen> {
  final TextEditingController mpinController = TextEditingController();

  Future<void> _saveUserData(String mpin) async {
    if (Platform.isAndroid || Platform.isIOS) {
      const storage = FlutterSecureStorage(); // Secure storage for MPIN
      await storage.write(key: 'mpin', value: mpin); // 🔐 Save MPIN securely
    } else {
      debugPrint('Secure storage not supported on this platform');
    }

    final prefs = await SharedPreferences.getInstance(); // Regular storage
    await prefs.setDouble('balance', 1000.00);
    await prefs.setString('transactions', jsonEncode([]));
  }

  void _submitMPIN() {
    final mpin = mpinController.text;

    if (mpin.length == 4 && int.tryParse(mpin) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('MPIN set successfully!')),
      );
      _saveUserData(mpin);
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(
              initialBalance: 1000.00,
              initialTransactions: [],
            ),
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 4-digit MPIN')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Your MPIN')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('Create a 4-digit MPIN for secure login'),
            const SizedBox(height: 10),
            TextField(
              controller: mpinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '••••',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitMPIN,
              child: const Text('Confirm MPIN'),
            ),
          ],
        ),
      ),
    );
  }
}

class MPINLoginScreen extends StatefulWidget {
  final double savedBalance;
  final List<Map<String, String>> savedTransactions;
  final String savedMPIN; // ← Add this

  const MPINLoginScreen({
    super.key,
    required this.savedBalance,
    required this.savedTransactions,
    required this.savedMPIN, // ← Add this
  });

  @override
  State<MPINLoginScreen> createState() => _MPINLoginScreenState();
}

class _MPINLoginScreenState extends State<MPINLoginScreen> {
  final TextEditingController mpinController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void dispose() {
    mpinController.dispose();
    super.dispose();
  }

  String? storedMPIN;

  @override
  void initState() {
    super.initState();
    _loadSavedMPIN();
  }

  Future<void> _loadSavedMPIN() async {
    const storage = FlutterSecureStorage();
    storedMPIN = await storage.read(key: 'mpin');
    if (storedMPIN != null && storedMPIN!.isNotEmpty) {
      _authenticateWithBiometrics();
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final isAvailable = await auth.canCheckBiometrics;
      final isDeviceSupported = await auth.isDeviceSupported();

      if (isAvailable && isDeviceSupported) {
        final didAuthenticate = await auth.authenticate(
          localizedReason: 'Use fingerprint to access PHCash',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );

        if (didAuthenticate) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(
                initialBalance: widget.savedBalance,
                initialTransactions: widget.savedTransactions,
              ),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Authentication Failed'),
              content: const Text('Try entering your MPIN instead.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric authentication not available'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biometric authentication failed. Please try again.'),
        ),
      );
    }
  }

  void _verifyMPIN() {
    if (mpinController.text == storedMPIN) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(
            initialBalance: widget.savedBalance,
            initialTransactions: widget.savedTransactions,
          ),
        ),
      );
    } else {
      mpinController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect MPIN')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter MPIN')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Enter your 4-digit MPIN to continue'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: mpinController,
                    obscureText: true,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '••••',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _verifyMPIN,
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _authenticateWithBiometrics,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Login with Biometrics'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final double initialBalance;
  final List<Map<String, String>> initialTransactions;

  const DashboardScreen({
    super.key,
    required this.initialBalance,
    required this.initialTransactions,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late double balance;
  late List<Map<String, String>> transactions;

  bool showTransactions = false;

  @override
  void initState() {
    super.initState();
    balance = widget.initialBalance;
    transactions = widget.initialTransactions;
    _loadStoredTransactions(); // 🔄 Load latest transactions
  }

  void _handleTransaction(double newBalance, Map<String, String> transaction) {
    setState(() {
      balance = newBalance;
      transactions.insert(0, transaction);
    });
    _updateStorage(); // ✅ Call it here to persist changes
  }

  Future<void> _updateStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('balance', balance);
    await prefs.setString('transactions', jsonEncode(transactions));
  }

  Future<void> _loadStoredTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final txJson = prefs.getString('transactions');
    if (txJson != null) {
      final decoded = jsonDecode(txJson) as List;
      setState(() {
        transactions = decoded.map((e) => Map<String, String>.from(e)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PHCash Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Left Column: Buttons + Sections
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Balance: ₱${balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildNavButton('Send', Icons.send, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SendMoneyScreen(
                                currentBalance: balance,
                                onTransactionComplete: _handleTransaction,
                              ),
                            ),
                          );
                        }),
                        _buildNavButton('Bills', Icons.receipt, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PayBillsScreen(
                                currentBalance: balance,
                                onTransactionComplete: _handleTransaction,
                              ),
                            ),
                          );
                        }),
                        _buildNavButton('Top-Up', Icons.account_balance_wallet,
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddBalanceScreen(
                                currentBalance: balance,
                                onTransactionComplete: _handleTransaction,
                              ),
                            ),
                          );
                        }),
                        _buildNavButton('Live', Icons.live_tv, () {
                          // Optional: scroll to live section
                        }),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SocialFeedWidget(),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showTransactions = !showTransactions;
                        });
                      },
                      child: Row(
                        children: [
                          const Text(
                            'Recent Transactions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            showTransactions
                                ? Icons.expand_less
                                : Icons.expand_more,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (showTransactions)
                      transactions.isEmpty
                          ? const Text('No transactions yet')
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                final tx = transactions[index];
                                final timestamp = tx['timestamp'];
                                final amount = tx['amount'];
                                final type = tx['type'];
                                return ListTile(
                                  leading: Icon(
                                    type != null && type.contains('Received')
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: type != null &&
                                            type.contains('Received')
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  title: Text(type ?? 'Unknown'),
                                  subtitle: Text(
                                    timestamp != null
                                        ? DateFormat('MMM d, yyyy – h:mm a')
                                            .format(DateTime.parse(timestamp)
                                                .toLocal())
                                        : 'No timestamp',
                                  ),
                                  trailing: Text(
                                    amount ?? '₱0.00',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                );
                              },
                            ),
                    const SizedBox(height: 30),
                    const Text(
                      'Travel & Booking',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildBookingButton('Hotels', Icons.hotel, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => HotelBookingScreen()),
                          );
                        }),
                        _buildBookingButton('Cars', Icons.directions_car, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => CarRentalScreen()),
                          );
                        }),
                        _buildBookingButton('Boats', Icons.directions_boat, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => BoatTicketScreen()),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Job Hiring',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildBookingButton('Job Hiring', Icons.work, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => JobHiringScreen()),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 🔸 Right Column: Live Stream Grid
            const SizedBox(width: 20),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Live Streamers',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SizedBox(
                          height: 500,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('live_users')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No live users yet',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                );
                              }

                              final fetchedLiveUsers =
                                  snapshot.data!.docs.map((doc) {
                                return LiveUser(
                                  name: doc['name'],
                                  thumbnailUrl: doc['thumbnailUrl'],
                                  viewers: doc['viewers'],
                                );
                              }).toList();

                              return LiveStreamGrid(
                                  liveUsers: fetchedLiveUsers);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ✅ Floating "Go Live" button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GoLiveScreen()),
          );
        },
        icon: const Icon(Icons.videocam),
        label: const Text('Go Live'),
      ),
    );
  }

  Widget _buildNavButton(String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildBookingButton(String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}

class SocialFeedWidget extends StatefulWidget {
  const SocialFeedWidget({super.key});

  @override
  _SocialFeedWidgetState createState() => _SocialFeedWidgetState();
}

class _SocialFeedWidgetState extends State<SocialFeedWidget> {
  bool isMinimized = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.people),
          title: const Text('Community Feed'),
          trailing: IconButton(
            icon: Icon(isMinimized ? Icons.expand_more : Icons.expand_less),
            onPressed: () {
              setState(() {
                isMinimized = !isMinimized;
              });
            },
          ),
        ),
        if (!isMinimized)
          SizedBox(
            height: 200,
            child: ListView(
              children: const [
                PostCard(user: 'Alice', content: 'Just landed a new job! 🎉'),
                PostCard(user: 'Bob', content: 'Looking for a Flutter mentor.'),
              ],
            ),
          ),
      ],
    );
  }
}

class LiveUser {
  final String name;
  final String thumbnailUrl;
  final int viewers;

  LiveUser({
    required this.name,
    required this.thumbnailUrl,
    required this.viewers,
  });
}

class LiveStreamGrid extends StatelessWidget {
  final List<LiveUser> liveUsers;

  const LiveStreamGrid({
    super.key,
    required this.liveUsers,
  });

  @override
  Widget build(BuildContext context) {
    if (liveUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No live users yet',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Be the first to sign up and go live!',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      itemCount: liveUsers.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final user = liveUsers[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LiveRoomScreen(user: user),
              ),
            );
          },
          child: Stack(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          user.thumbnailUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.broken_image,
                              size: 100,
                              color: Colors.grey,
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${user.viewers} watching',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class LiveRoomScreen extends StatelessWidget {
  final LiveUser user;

  const LiveRoomScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${user.name} is Live')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${user.name} is streaming now!',
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            Image.network(user.thumbnailUrl),
            const SizedBox(height: 20),
            Text('${user.viewers} viewers watching'),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close),
              label: const Text('Leave Room'),
            ),
          ],
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final String user;
  final String content;

  const PostCard({super.key, required this.user, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(child: Text(user[0])),
        title: Text(user),
        subtitle: Text(content),
        trailing: const Icon(Icons.chat),
      ),
    );
  }
}

class AddBalanceScreen extends StatefulWidget {
  final double currentBalance;
  final Function(double, Map<String, String>) onTransactionComplete;

  const AddBalanceScreen({
    super.key,
    required this.currentBalance,
    required this.onTransactionComplete,
  });

  @override
  State<AddBalanceScreen> createState() => _AddBalanceScreenState();
}

class _AddBalanceScreenState extends State<AddBalanceScreen> {
  final TextEditingController _amountController = TextEditingController();
  String selectedProvider = 'Bank Transfer';

  @override
  void dispose() {
    _amountController.dispose(); // Clean up the controller
    super.dispose();
  }

  final List<String> providers = [
    'Bank Transfer',
    'Asdra',
    'Bank of the Philippine Islands (BPI)',
    'BDO Unibank',
    'Cebuana Lhuillier Pera Padala',
    'China Bank',
    'CIMB Bank Philippines',
    'Coins.ph',
    'DeeMoney',
    'Development Bank of the Philippines',
    'EastWest Bank',
    'GCash Remit',
    'LBC Instant Peso Padala',
    'Land Bank of the Philippines',
    'Metrobank',
    'ML Kwarta Padala',
    'MoneyGram',
    'Palawan Express Pera Padala',
    'PayMaya',
    'PayPal',
    'Philippine National Bank (PNB)',
    'Philippine Veterans Bank',
    'RCBC',
    'Remitly',
    'Ria Money Transfer',
    'SMARTSWIFT',
    'Smart Padala',
    'Security Bank',
    'TrueMoney',
    'UnionBank',
    'Western Union',
    'Xoom',
  ];

  void _confirmTopUp() async {
    print('Confirm Top-Up button pressed'); // Step 1: Confirm button is wired

    final amount = double.tryParse(_amountController.text);
    print('Entered amount: $amount'); // Step 2: Check if amount is valid

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final newBalance = widget.currentBalance + amount;
    final transaction = {
      'type': 'Top-Up',
      'amount': amount.toStringAsFixed(2), // convert double to string
      'provider': selectedProvider,
      'timestamp': DateTime.now().toIso8601String(), // already a string
    };

    print('New balance: $newBalance'); // Step 3: Confirm balance calculation
    print('Transaction: $transaction'); // Step 4: Confirm transaction object

    widget.onTransactionComplete(newBalance, transaction);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('₱$amount added via $selectedProvider')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Balance')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Provider',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedProvider,
              isExpanded: true,
              items: providers.map((provider) {
                return DropdownMenuItem(
                  value: provider,
                  child: Text(provider),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedProvider = value;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            const Text('Enter Amount',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g. 500.00',
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: _confirmTopUp,
                icon: const Icon(Icons.check_circle),
                label: const Text('Confirm Top-Up'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SendMoneyScreen extends StatefulWidget {
  final double currentBalance;
  final Function(double, Map<String, String>) onTransactionComplete;

  const SendMoneyScreen({
    super.key,
    required this.currentBalance,
    required this.onTransactionComplete,
  });

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final TextEditingController recipientController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  String selectedChannel = 'PHCash Wallet';
  final List<String> channels = ['PHCash Wallet', 'GCash', 'Bank Transfer'];

  String selectedBank = 'BDO';
  final List<String> banks = ['BDO', 'BPI', 'Metrobank', 'UnionBank'];

  void _sendMoney() {
    final recipient = recipientController.text;
    final amount = double.tryParse(amountController.text);

    if (recipient.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid recipient and amount')),
      );
      return;
    }

    if (amount > widget.currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient balance')),
      );
      return;
    }

    final newBalance = widget.currentBalance - amount;
    final transaction = {
      'type': 'Send Money to $selectedChannel',
      'amount': '-₱${amount.toStringAsFixed(2)}',
      'timestamp': DateTime.now().toIso8601String(),
      if (selectedChannel == 'Bank Transfer') 'bank': selectedBank,
    };

    widget.onTransactionComplete(newBalance, transaction);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Money')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedChannel,
              items: channels.map((channel) {
                return DropdownMenuItem(
                  value: channel,
                  child: Text(channel),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedChannel = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Transfer Method',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (selectedChannel == 'PHCash Wallet') ...[
              TextField(
                controller: recipientController,
                decoration: const InputDecoration(
                  labelText: 'Recipient PHCash Mobile Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ] else if (selectedChannel == 'GCash') ...[
              TextField(
                controller: recipientController,
                decoration: const InputDecoration(
                  labelText: 'GCash Account Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ] else if (selectedChannel == 'Bank Transfer') ...[
              TextField(
                controller: recipientController,
                decoration: const InputDecoration(
                  labelText: 'Bank Account Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: selectedBank,
                items: banks.map((bank) {
                  return DropdownMenuItem(
                    value: bank,
                    child: Text(bank),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedBank = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Select Bank',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount to Send',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendMoney,
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}

class PayBillsScreen extends StatefulWidget {
  final double currentBalance;
  final Function(double, Map<String, String>) onTransactionComplete;

  const PayBillsScreen({
    super.key,
    required this.currentBalance,
    required this.onTransactionComplete,
  });

  @override
  State<PayBillsScreen> createState() => _PayBillsScreenState();
}

class _PayBillsScreenState extends State<PayBillsScreen> {
  final TextEditingController amountController = TextEditingController();
  String? selectedBiller;

  final List<String> billers = [
    'Meralco',
    'Maynilad',
    'Globe Telecom',
    'Smart Communications',
    'PLDT Home',
    'Manila Water',
    'PhilHealth',
    'SSS',
    'Pag-IBIG Fund',
    'GSIS',
    'BDO',
    'BPI',
    'Metrobank',
    'Landbank',
    'UnionBank',
    'RCBC',
    'Security Bank',
    'PNB',
    'EastWest Bank',
    'Tonik',
  ];

  void _payBill() {
    final amount = double.tryParse(amountController.text);

    if (selectedBiller == null || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Select a biller and enter a valid amount')),
      );
      return;
    }

    if (amount > widget.currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient balance')),
      );
      return;
    }

    final newBalance = widget.currentBalance - amount;
    final transaction = {
      'type': 'Pay Bills - $selectedBiller',
      'amount': '-₱${amount.toStringAsFixed(2)}',
      'timestamp': DateTime.now().toIso8601String(),
    };

    widget.onTransactionComplete(newBalance, transaction);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pay Bills')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedBiller,
              items: billers
                  .map((biller) => DropdownMenuItem(
                        value: biller,
                        child: Text(biller),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => selectedBiller = value),
              decoration: const InputDecoration(
                labelText: 'Select Biller',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount to Pay',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _payBill,
              child: const Text('Pay'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();

  final mobileNumber = prefs.getString('mobile'); // Check if mobile is saved
  final savedMPIN = prefs.getString('mpin');
  final savedBalance = prefs.getDouble('balance') ?? 1000.00;
  final txJson = prefs.getString('transactions');
  final savedTransactions = txJson != null
      ? (jsonDecode(txJson) as List)
          .map((e) => Map<String, String>.from(e as Map))
          .toList()
      : <Map<String, String>>[];

  Widget initialScreen;

  if (mobileNumber == null) {
    initialScreen = const OTPVerificationScreen(expectedOTP: '123456');
  } else if (savedMPIN == null) {
    initialScreen = const MPINSetupScreen();
  } else {
    initialScreen = MPINLoginScreen(
      savedMPIN: savedMPIN,
      savedBalance: savedBalance,
      savedTransactions: savedTransactions,
    );
  }

  runApp(MaterialApp(
    home: initialScreen,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GCash Clone',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: SignUpScreen(),
    );
  }
}

class HotelBookingScreen extends StatelessWidget {
  const HotelBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a Hotel')),
      body: const Center(child: Text('Hotel booking options coming soon')),
    );
  }
}

class CarRentalScreen extends StatelessWidget {
  const CarRentalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rent a Car')),
      body: const Center(child: Text('Car rental options coming soon')),
    );
  }
}

class BoatTicketScreen extends StatelessWidget {
  const BoatTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a Boat')),
      body: const Center(child: Text('Boat ticket options coming soon')),
    );
  }
}

List<Map<String, String>> globalJobs = [
  {
    'title': 'Flutter Developer',
    'company': 'TechNova Co.',
    'location': 'Thailand',
    'description': 'Build mobile apps using Flutter.',
    'isFeatured': 'true',
  },
  {
    'title': 'Customer Support Agent',
    'company': 'PHCash Services',
    'location': 'Thailand',
    'description': 'Assist customers via chat and email.',
    'isFeatured': 'true',
  },
  {
    'title': 'Marketing Specialist',
    'company': 'BrandBoost Ltd.',
    'location': 'Thailand',
    'description': 'Develop marketing campaigns.',
    'isFeatured': 'false',
  },
];

class JobHiringScreen extends StatelessWidget {
  final List<String> countries;
  final List<Map<String, String>> featuredJobs;

  const JobHiringScreen({super.key})
      : countries = const [
          'Afghanistan',
          'Albania',
          'Algeria',
          'Andorra',
          'Angola',
          'Antigua and Barbuda',
          'Argentina',
          'Armenia',
          'Australia',
          'Austria',
          'Azerbaijan',
          'Bahamas',
          'Bahrain',
          'Bangladesh',
          'Barbados',
          'Belarus',
          'Belgium',
          'Belize',
          'Benin',
          'Bhutan',
          'Bolivia',
          'Bosnia and Herzegovina',
          'Botswana',
          'Brazil',
          'Brunei',
          'Bulgaria',
          'Burkina Faso',
          'Burundi',
          'Cabo Verde',
          'Cambodia',
          'Cameroon',
          'Canada',
          'Central African Republic',
          'Chad',
          'Chile',
          'China',
          'Colombia',
          'Comoros',
          'Congo (Brazzaville)',
          'Congo (Kinshasa)',
          'Costa Rica',
          'Croatia',
          'Cuba',
          'Cyprus',
          'Czech Republic',
          'Denmark',
          'Djibouti',
          'Dominica',
          'Dominican Republic',
          'Ecuador',
          'Egypt',
          'El Salvador',
          'Equatorial Guinea',
          'Eritrea',
          'Estonia',
          'Eswatini',
          'Ethiopia',
          'Fiji',
          'Finland',
          'France',
          'Gabon',
          'Gambia',
          'Georgia',
          'Germany',
          'Ghana',
          'Greece',
          'Grenada',
          'Guatemala',
          'Guinea',
          'Guinea-Bissau',
          'Guyana',
          'Haiti',
          'Honduras',
          'Hungary',
          'Iceland',
          'India',
          'Indonesia',
          'Iran',
          'Iraq',
          'Ireland',
          'Israel',
          'Italy',
          'Ivory Coast',
          'Jamaica',
          'Japan',
          'Jordan',
          'Kazakhstan',
          'Kenya',
          'Kiribati',
          'Kuwait',
          'Kyrgyzstan',
          'Laos',
          'Latvia',
          'Lebanon',
          'Lesotho',
          'Liberia',
          'Libya',
          'Liechtenstein',
          'Lithuania',
          'Luxembourg',
          'Madagascar',
          'Malawi',
          'Malaysia',
          'Maldives',
          'Mali',
          'Malta',
          'Marshall Islands',
          'Mauritania',
          'Mauritius',
          'Mexico',
          'Micronesia',
          'Moldova',
          'Monaco',
          'Mongolia',
          'Montenegro',
          'Morocco',
          'Mozambique',
          'Myanmar',
          'Namibia',
          'Nauru',
          'Nepal',
          'Netherlands',
          'New Zealand',
          'Nicaragua',
          'Niger',
          'Nigeria',
          'North Korea',
          'North Macedonia',
          'Norway',
          'Oman',
          'Pakistan',
          'Palau',
          'Palestine',
          'Panama',
          'Papua New Guinea',
          'Paraguay',
          'Peru',
          'Philippines',
          'Poland',
          'Portugal',
          'Qatar',
          'Romania',
          'Russia',
          'Rwanda',
          'Saint Kitts and Nevis',
          'Saint Lucia',
          'Saint Vincent and the Grenadines',
          'Samoa',
          'San Marino',
          'Sao Tome and Principe',
          'Saudi Arabia',
          'Senegal',
          'Serbia',
          'Seychelles',
          'Sierra Leone',
          'Singapore',
          'Slovakia',
          'Slovenia',
          'Solomon Islands',
          'Somalia',
          'South Africa',
          'South Korea',
          'South Sudan',
          'Spain',
          'Sri Lanka',
          'Sudan',
          'Suriname',
          'Sweden',
          'Switzerland',
          'Syria',
          'Taiwan',
          'Tajikistan',
          'Tanzania',
          'Thailand',
          'Timor-Leste',
          'Togo',
          'Tonga',
          'Trinidad and Tobago',
          'Tunisia',
          'Turkey',
          'Turkmenistan',
          'Tuvalu',
          'Uganda',
          'Ukraine',
          'United Arab Emirates',
          'United Kingdom',
          'United States',
          'Uruguay',
          'Uzbekistan',
          'Vanuatu',
          'Vatican City',
          'Venezuela',
          'Vietnam',
          'Yemen',
          'Zambia',
          'Zimbabwe',
        ],
        featuredJobs = const [
          {
            'title': 'Senior Flutter Developer',
            'company': 'PHCash Premium',
            'location': 'Remote',
          },
          {
            'title': 'Operations Manager',
            'company': 'GlobalPay Inc.',
            'location': 'Singapore',
          },
        ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Job Hiring'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Countries'),
              Tab(text: 'Featured Jobs'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Countries Tab
            ListView.builder(
              itemCount: countries.length,
              itemBuilder: (context, index) {
                final country = countries[index];
                return ListTile(
                  title: Text(country),
                  onTap: () {
                    // Navigate to country-specific job listings
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CountryJobScreen(countryName: country),
                      ),
                    );
                  },
                );
              },
            ),
            // Featured Jobs Tab
            ListView.builder(
              itemCount: featuredJobs.length,
              itemBuilder: (context, index) {
                final job = featuredJobs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(job['title'] ?? ''),
                    subtitle: Text('${job['company']} • ${job['location']}'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // Navigate to application form or job details
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CountryJobScreen extends StatelessWidget {
  final String countryName;

  const CountryJobScreen({super.key, required this.countryName});

  @override
  Widget build(BuildContext context) {
    final jobsInCountry =
        globalJobs.where((job) => job['location'] == countryName).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Jobs in $countryName')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Featured Jobs in $countryName',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: jobsInCountry.isEmpty
                  ? const Center(child: Text('No jobs available yet'))
                  : ListView.builder(
                      itemCount: jobsInCountry.length,
                      itemBuilder: (context, index) {
                        final job = jobsInCountry[index];
                        final isFeatured = job['isFeatured'] == 'true';
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          color: isFeatured ? Colors.yellow[100] : null,
                          child: ListTile(
                            title: Text(job['title'] ?? ''),
                            subtitle: Text('${job['company']} • $countryName'),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ApplyJobScreen(job: job),
                                  ),
                                );
                              },
                              child: const Text('Apply'),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostJobScreen(country: countryName),
                    ),
                  );
                },
                icon: const Icon(Icons.post_add),
                label: const Text('Post a Job'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostJobScreen extends StatefulWidget {
  final String country;

  const PostJobScreen({super.key, required this.country});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool isFeatured = false;

  void _submitJob() {
    final title = titleController.text.trim();
    final company = companyController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty || company.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final job = {
      'title': title,
      'company': company,
      'location': widget.country,
      'description': description,
      'isFeatured': isFeatured.toString(),
    };

    globalJobs.add(job); // ✅ This adds the job to the shared list

    titleController.clear();
    companyController.clear();
    descriptionController.clear();
    setState(() {
      isFeatured = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Job posted for ${widget.country}')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Post a Job in ${widget.country}')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Job Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: companyController,
              decoration: const InputDecoration(
                labelText: 'Company Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Job Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            CheckboxListTile(
              value: isFeatured,
              onChanged: (value) {
                setState(() {
                  isFeatured = value ?? false;
                });
              },
              title: const Text('Mark as Featured'),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _submitJob,
              icon: const Icon(Icons.send),
              label: const Text('Submit Job'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ApplyJobScreen extends StatefulWidget {
  final Map<String, String> job;

  const ApplyJobScreen({super.key, required this.job});

  @override
  State<ApplyJobScreen> createState() => _ApplyJobScreenState();
}

class _ApplyJobScreenState extends State<ApplyJobScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  void _submitApplication() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final message = messageController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and email are required')),
      );
      return;
    }

    final application = {
      'jobTitle': widget.job['title'],
      'company': widget.job['company'],
      'location': widget.job['location'],
      'applicantName': name,
      'email': email,
      'message': message,
    };

    print('New Application: $application'); // Replace with Firebase later

    nameController.clear();
    emailController.clear();
    messageController.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Your application has been submitted!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Scaffold(
      appBar: AppBar(title: Text('Apply for ${job['title']}')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Text('${job['title']} at ${job['company']}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: messageController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Message or Cover Letter (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _submitApplication,
              icon: const Icon(Icons.send),
              label: const Text('Submit Application'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoLiveScreen extends StatefulWidget {
  const GoLiveScreen({super.key});

  @override
  State<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends State<GoLiveScreen> {
  final TextEditingController _titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Go Live')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Start Your Live Stream',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Stream Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                final title = _titleController.text.trim();
                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter a stream title')),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LiveRoomScreen(
                      user: LiveUser(
                        name: title,
                        thumbnailUrl:
                            'https://images.unsplash.com/photo-1607746882042-944635dfe10e?auto=format&fit=crop&w=800&q=80',
                        viewers: 0,
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.videocam),
              label: const Text('Go Live'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
