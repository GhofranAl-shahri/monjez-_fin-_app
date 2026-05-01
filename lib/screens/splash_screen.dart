import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // إعداد الحركة (الظهور التدريجي)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    // الانتقال التلقائي لصفحة التسجيل بعد 3 ثوانٍ
    Timer(const Duration(seconds: 3), () {
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        Navigator.pushReplacementNamed(context, '/login');
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
    final emeraldGreen = Theme.of(context).primaryColor;

    return Scaffold(
      // استخدام اللون الزمردي كخلفية كاملة
      backgroundColor: emeraldGreen,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة مؤقتة أو شعار التطبيق
              const Icon(
                Icons.account_balance_wallet_rounded,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              // اسم التطبيق بخط المراعي
              Text(
                'مُنجز مالي',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Monjez Fin',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 50),
              // مؤشر تحميل بسيط وأنيق
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}