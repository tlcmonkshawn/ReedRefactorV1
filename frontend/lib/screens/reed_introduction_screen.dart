import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bootiehunter/providers/auth_provider.dart';
import 'package:bootiehunter/screens/phone_screen.dart';
import 'package:bootiehunter/screens/home_screen.dart';

class ReedIntroductionScreen extends StatefulWidget {
  const ReedIntroductionScreen({super.key});

  @override
  State<ReedIntroductionScreen> createState() => _ReedIntroductionScreenState();
}

class _ReedIntroductionScreenState extends State<ReedIntroductionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  int _currentTextIndex = 0;

  final List<String> _introTexts = [
    'R.E.E.D. 8',
    'Rapid Estimation & Entry Droid',
    'The Cool Record Store Expert',
    'I speak in Movie Quotes, Music Lyrics, and Sarcasm',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
    _controller.forward();

    // Animate text appearance
    _animateText();
  }

  void _animateText() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && _currentTextIndex < _introTexts.length - 1) {
        setState(() {
          _currentTextIndex++;
        });
        _animateText();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToPhone() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const PhoneScreen(),
      ),
    );
  }

  void _navigateToHome() async {
    // Mark onboarding as complete
    final authProvider = context.read<AuthProvider>();
    await authProvider.markOnboardingComplete();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
              Colors.pink.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated avatar/icon
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.shade400,
                              Colors.purple.shade400,
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.smart_toy,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 48),
                // Animated text introduction
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _buildTextSection(),
                ),
                const SizedBox(height: 60),
                // Personality traits
                _buildPersonalityTraits(),
                const Spacer(),
                // Call-to-action buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _navigateToPhone,
                        icon: const Icon(Icons.phone),
                        label: const Text('Call Reed'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _navigateToHome,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Get Started'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextSection() {
    final text = _introTexts[_currentTextIndex];
    final isTitle = _currentTextIndex == 0;
    final isSubtitle = _currentTextIndex == 1;
    final isRole = _currentTextIndex == 2;
    final isCatchphrase = _currentTextIndex == 3;

    return TweenAnimationBuilder<double>(
      key: ValueKey(_currentTextIndex),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          if (isTitle)
            Text(
              text,
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            )
          else if (isSubtitle)
            Text(
              text,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            )
          else if (isRole)
            Text(
              text,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
              textAlign: TextAlign.center,
            )
          else if (isCatchphrase)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Text(
                '"$text"',
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.orange.shade900,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPersonalityTraits() {
    final traits = [
      'Knowledgeable',
      'Confident',
      'Playfully Flirty',
      'Sarcastic Wit',
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: traits.map((trait) {
        return Chip(
          label: Text(trait),
          backgroundColor: Colors.blue.shade50,
          side: BorderSide(color: Colors.blue.shade200),
        );
      }).toList(),
    );
  }
}
