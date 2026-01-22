import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked_services/stacked_services.dart';
import 'firebase_options.dart';
import 'gemini_service.dart';
import 'ui/views/splash/splash_view.dart';
import 'app/app.locator.dart';
import 'app/app.router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setupLocator();
  
  runApp(const GaiaApp());
}

class GaiaApp extends StatelessWidget {
  const GaiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: StackedService.navigatorKey,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white),
      ),
      home: const _InitialScreen(),
    );
  }
}

class _InitialScreen extends StatelessWidget {
  const _InitialScreen();

  @override
  Widget build(BuildContext context) {
    final profileRef = FirebaseDatabase.instance.ref('plants/gaia_01/profile');

    return FutureBuilder<DataSnapshot>(
      future: profileRef.get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        //if naa profile, go to dashboard na agad
        if (snapshot.hasData && snapshot.data!.exists) {
          return const DashboardScreen();
        }

        //first time user go splash
        return const SplashView();
      },
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('plants/gaia_01');
  
  String gaiaThought = "Tap the bubble to hear me speak...";
  bool isThinking = false;

  void askGaia(double temp, int moisture) async {
    setState(() => isThinking = true);
    String response = await GeminiService.getPlantThoughts(temp, moisture);
    setState(() {
      gaiaThought = response;
      isThinking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PROJECT GAIA"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: _dbRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
            final double temp = (data['temperature'] as num).toDouble();
            final int moisture = (data['soil_moisture'] as num).toInt();

            return Column(
              children: [
                GestureDetector(
                  onTap: () => askGaia(temp, moisture),
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withOpacity(0.5)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.eco, size: 80, color: Colors.green),
                        const SizedBox(height: 10),
                        isThinking 
                          ? const CircularProgressIndicator(color: Colors.green)
                          : Text(
                              "\"$gaiaThought\"",
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                            ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(10),
                    children: [
                      _buildCard("Moisture", "$moisture%", Icons.water_drop, Colors.blue),
                      _buildCard("Temperature", "$temp°C", Icons.thermostat, Colors.orange),
                    ],
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.white54)),
          Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}