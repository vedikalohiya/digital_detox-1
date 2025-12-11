import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class GamificationPage extends StatefulWidget {
  const GamificationPage({super.key});

  @override
  State<GamificationPage> createState() => _GamificationPageState();
}

class _GamificationPageState extends State<GamificationPage> with TickerProviderStateMixin {
  // Theme Colors
  static const Color kSpaceBlack = Color(0xFF0B0E14);
  static const Color kStarGold = Color(0xFFFFD700);
  static const Color kNeonBlue = Color(0xFF00BFFF);

  // State
  int _selectedIndex = 0; // 0 = Stargaze, 1 = Sky Map
  
  // Timer State
  Timer? _timer;
  int _targetDuration = 20 * 60; // Default 20 mins
  int _currentDuration = 0;
  bool _isGazing = false;
  List<Point<double>> _stars = [];
  
  // Constellation Logic
  final List<String> _constellationNames = [
    "The Phoenix", "The Archer", "The Great Bear", "The Swan", "The Dragon", "The Lyre"
  ];
  List<Map<String, dynamic>> _mySkyMap = []; // Unlocked constellations

  late AnimationController _twinkleController;

  @override
  void initState() {
    super.initState();
    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _twinkleController.dispose();
    super.dispose();
  }

  void _startGazing() {
    setState(() {
      _isGazing = true;
      _currentDuration = 0;
      _stars.clear();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _currentDuration++;
        
        // Add a new star every few seconds (visual only)
        if (_currentDuration % 5 == 0) {
          _stars.add(Point(
            Random().nextDouble(), 
            Random().nextDouble(),
          ));
        }

        if (_currentDuration >= _targetDuration) {
          _finishGazing();
        }
      });
    });
  }

  void _finishGazing() {
    _timer?.cancel();
    setState(() => _isGazing = false);

    // Unlock a random constellation
    final newConstellation = {
      'name': _constellationNames[Random().nextInt(_constellationNames.length)],
      'stars': List.from(_stars), // Save the pattern
      'date': DateTime.now(),
      'duration': _targetDuration ~/ 60,
    };

    setState(() {
      _mySkyMap.insert(0, newConstellation);
    });

    _showDiscoveryDialog(newConstellation);
  }

  void _cancelGazing() {
    _timer?.cancel();
    setState(() {
      _isGazing = false;
      _stars.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Stargazing interrupted. The sky fades to black..."),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _showDiscoveryDialog(Map<String, dynamic> constellation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: kSpaceBlack,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: kNeonBlue, width: 2),
        ),
        title: const Text(
          "Constellation Discovered!",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, color: kStarGold, size: 60),
            const SizedBox(height: 16),
            Text(
              constellation['name'],
              style: const TextStyle(
                color: kNeonBlue, 
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                fontFamily: 'Serif', // Adds a mystical feel
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You focused for ${constellation['duration']} minutes.",
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Add to Sky Map", style: TextStyle(color: kStarGold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSpaceBlack,
      body: _isGazing ? _buildGazingMode() : _buildMainUI(),
    );
  }

  Widget _buildMainUI() {
    return Column(
      children: [
        // Custom App Bar
        Container(
          padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kSpaceBlack, Colors.blueGrey.shade900],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Clarity Sky",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Collect stars through focus",
                    style: TextStyle(color: Colors.blueGrey.shade200, fontSize: 14),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kNeonBlue.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.nights_stay, color: kNeonBlue),
              ),
            ],
          ),
        ),

        // Toggle Tabs
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                _buildTabBtn("Stargaze", 0),
                _buildTabBtn("My Sky Map", 1),
              ],
            ),
          ),
        ),

        Expanded(
          child: _selectedIndex == 0 ? _buildStargazeSetup() : _buildSkyMap(),
        ),
      ],
    );
  }

  Widget _buildTabBtn(String title, int index) {
    bool isActive = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? kNeonBlue.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? kNeonBlue : Colors.transparent,
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStargazeSetup() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white12, width: 2),
              gradient: RadialGradient(
                colors: [Colors.blueGrey.shade900, kSpaceBlack],
              ),
            ),
            child: const Icon(Icons.rocket_launch, size: 80, color: Colors.white24),
          ),
          const SizedBox(height: 40),
          const Text(
            "Choose Focus Duration",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 20),
          Slider(
            value: _targetDuration.toDouble(),
            min: 60, // 1 min (for testing)
            max: 60 * 60, // 60 mins
            activeColor: kNeonBlue,
            inactiveColor: Colors.white12,
            onChanged: (val) {
              setState(() => _targetDuration = val.toInt());
            },
          ),
          Text(
            "${(_targetDuration / 60).toStringAsFixed(0)} Minutes",
            style: const TextStyle(
              color: kNeonBlue,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _startGazing,
            style: ElevatedButton.styleFrom(
              backgroundColor: kNeonBlue,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text(
              "Start Journey",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGazingMode() {
    return Stack(
      children: [
        // Starry Background Painter
        CustomPaint(
          size: Size.infinite,
          painter: StarFieldPainter(_stars, _twinkleController.value),
        ),
        
        // UI Overlay
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "Focusing...",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 24,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const Spacer(),
              // Time Display
              Text(
                "${(_currentDuration ~/ 60).toString().padLeft(2, '0')}:${(_currentDuration % 60).toString().padLeft(2, '0')}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 60,
                  fontWeight: FontWeight.w200,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Target: ${(_targetDuration / 60).toInt()} min",
                style: const TextStyle(color: Colors.white38),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: TextButton.icon(
                  onPressed: _showExitConfirmation,
                  icon: const Icon(Icons.close, color: Colors.white54),
                  label: const Text(
                    "Abort Journey",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kSpaceBlack,
        title: const Text("Stop Stargazing?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "If you leave now, you will lose progress on this constellation.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Stay Focused"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelGazing();
            },
            child: const Text("Exit", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSkyMap() {
    if (_mySkyMap.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.nights_stay_outlined, size: 80, color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 16),
            const Text(
              "Your sky is empty",
              style: TextStyle(color: Colors.white54, fontSize: 18),
            ),
            const Text(
              "Complete focus sessions to reveal stars",
              style: TextStyle(color: Colors.white24, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _mySkyMap.length,
      itemBuilder: (context, index) {
        final item = _mySkyMap[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, color: kStarGold, size: 40),
              const SizedBox(height: 12),
              Text(
                item['name'],
                style: const TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${item['duration']} mins",
                style: const TextStyle(color: kNeonBlue, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                "${(item['date'] as DateTime).day}/${(item['date'] as DateTime).month}",
                style: const TextStyle(color: Colors.white24, fontSize: 10),
              ),
            ],
          ),
        );
      },
    );
  }
}

class StarFieldPainter extends CustomPainter {
  final List<Point<double>> stars;
  final double twinkle;

  StarFieldPainter(this.stars, this.twinkle);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw background stars (faint)
    for (int i = 0; i < 50; i++) {
        // Random static stars
        final x = (i * 137.5) % size.width;
        final y = (i * 293.6) % size.height;
        paint.color = Colors.white.withOpacity(0.1);
        canvas.drawCircle(Offset(x, y), 1.0, paint);
    }

    // Draw collected stars (bright)
    for (var i = 0; i < stars.length; i++) {
      final point = stars[i];
      final x = point.x * size.width;
      final y = point.y * size.height;
      
      // Twinkle effect
      final opacity = 0.5 + (0.5 * sin(twinkle * 2 * pi + i));
      paint.color = Colors.white.withOpacity(opacity.clamp(0.2, 1.0));
      
      // Draw star glow
      canvas.drawCircle(Offset(x, y), 3.0, paint);
      
      // Draw star core
      paint.color = Colors.white;
      canvas.drawCircle(Offset(x, y), 1.0, paint);
    }
    
    // Draw connection lines if enough stars
    if (stars.length > 2) {
      final linePaint = Paint()
        ..color = const Color(0xFF00BFFF).withOpacity(0.3)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
        
      final path = Path();
      path.moveTo(stars[0].x * size.width, stars[0].y * size.height);
      for (int i = 1; i < stars.length; i++) {
        path.lineTo(stars[i].x * size.width, stars[i].y * size.height);
      }
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(StarFieldPainter oldDelegate) => true;
}
