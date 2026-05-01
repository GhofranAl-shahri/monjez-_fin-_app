import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // المتحكمات لإدارة النصوص المدخلة
  final TextEditingController _identifierController = TextEditingController(); // للإيميل أو الرقم
  final TextEditingController _passwordController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();

  bool _obscurePassword = true;
  bool _isPasswordEmpty = true;

  @override
  void initState() {
    super.initState();
    _loadSavedData(); // تحميل البيانات المحفوظة عند فتح الصفحة

    // مراقبة حقل كلمة المرور لتغيير الأيقونة (بصمة أو عين)
    _passwordController.addListener(() {
      setState(() {
        _isPasswordEmpty = _passwordController.text.isEmpty;
      });
    });
  }

  // تحميل البيانات المحفوظة (إيميل أو رقم) من الذاكرة
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _identifierController.text = prefs.getString('saved_user_id') ?? "";
    });
  }

  // حفظ البيانات عند تسجيل الدخول الناجح
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_user_id', _identifierController.text);
  }

  // تفعيل نافذة البصمة تماماً كالصورة
  Future<void> _authenticateWithBiometrics() async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isDeviceSupported = await auth.isDeviceSupported();

      if (canCheckBiometrics && isDeviceSupported) {
        bool authenticated = await auth.authenticate(
          localizedReason: 'استخدم البصمة للاستمرار',
          authMessages: const [
            AndroidAuthMessages(
              signInTitle: 'بصمة الإصبع', // العنوان العلوي
              biometricHint: 'استخدم البصمة للاستمرار',
              cancelButton: 'استخدم كلمة المرور', // الخيار السفلي
            ),
          ],
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );

        if (authenticated) {
          await _saveData();
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      }
    } catch (e) {
      debugPrint("Biometric Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 80.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // شعار "مُنجز مالي" بتصميم أنيق
              const Text("مُنجز مالي",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen)),
              const SizedBox(height: 10),
              const Text("مرحباً بعودتك.. قم بتسجيل الدخول",
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 60),

              // حقل الإيميل أو رقم الموبايل (مرن)
              TextField(
                controller: _identifierController,
                keyboardType: TextInputType.emailAddress, // يدعم النصوص والأرقام
                decoration: InputDecoration(
                  labelText: 'رقم الموبايل أو البريد الإلكتروني',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: AppTheme.emeraldGreen, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // حقل كلمة المرور مع منطق الأيقونة المتغيرة
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: AppTheme.emeraldGreen, width: 2),
                  ),
                  // المنطق المطلوب: إذا الحقل فارغ تظهر البصمة، وإذا بدأ الكتابة تظهر العين
                  suffixIcon: _isPasswordEmpty
                      ? IconButton(
                    icon: const Icon(Icons.fingerprint, color: AppTheme.emeraldGreen, size: 32),
                    onPressed: _authenticateWithBiometrics,
                  )
                      : IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // زر تسجيل الدخول
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.emeraldGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 2,
                  ),
                  onPressed: () async {
                    if (_identifierController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                      await _saveData(); // حفظ الهوية عند النجاح
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('يرجى إدخال البيانات كاملة')),
                      );
                    }
                  },
                  child: const Text('تسجيل الدخول',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/forgot_password'),
                child: const Text("نسيت كلمة المرور؟", style: TextStyle(color: AppTheme.emeraldGreen)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}