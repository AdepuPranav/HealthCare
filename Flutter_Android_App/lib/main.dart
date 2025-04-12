import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
import 'health_tips_screen.dart';

void main() {
  runApp(HealthBotApp());
}

class HealthBotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Bot',
      theme: ThemeData(fontFamily: 'NotoSans', primarySwatch: Colors.teal),
      home: SplashScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/chat': (context) => ChatScreen(),
        '/tips': (context) => HealthTipsScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Create a scale animation that pops up and slightly overshoots
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.1),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0),
        weight: 30,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Create opacity animation for fading in and out
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 30,
      ),
    ]).animate(_controller);

    // Start the animation as soon as the widget is built
    _controller.forward();

    // Navigate to home screen when the animation completes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Center(
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Image.asset(
                  'assets/health.png', // Replace with your actual logo path
                  width: 150,
                  height: 150,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}