import 'package:continua/core/const/app_color.dart';
import 'package:continua/features/home/data/models/course_progress_model.dart';
import 'package:continua/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:continua/core/di/injection_container.dart' as di;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // نستنى أول frame فعلي يترسم قبل ما نبدأ السباق بين الاتنين
    WidgetsBinding.instance.addPostFrameCallback((_) => _runSplashSequence());
  }

  /// التحميل الحقيقي (Hive + DI) لوحده، من غير أي مهلة تعسفية
  Future<void> _runInitialization() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CourseProgressModelAdapter());
    }
    await Hive.openBox<CourseProgressModel>('course_progress_box');
    await di.init();
  }

  /// بتستنى التحميل والـ animation مع بعض، وتنتقل لما **الأطول منهم** يخلص
  Future<void> _runSplashSequence() async {
    setState(() => _errorMessage = null);

    try {
      await Future.wait([_controller.forward(), _runInitialization()]);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'حصل خطأ أثناء تشغيل التطبيق، حاول تاني';
      });
    }
  }

  void _retry() {
    _controller.reset();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runSplashSequence());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: SvgPicture.asset(
                'assets/images/splash_second_logo.svg',
                width: 120,
                height: 120,
              ),
            ),
            const SizedBox(height: 15),
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Text(
                'Learning evry day',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Appcolor.textcolor,
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (_errorMessage == null)
              const CircularProgressIndicator()
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _retry,
                      child: const Text('Tray again'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
