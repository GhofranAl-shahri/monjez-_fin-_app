import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  // دالة إرسال رابط إعادة التعيين
  Future<void> _sendResetLink() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال بريد إلكتروني صحيح')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // محاكاة عملية الإرسال (هنا يتم ربط Firebase أو API مستقبلاً)
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    // إظهار رسالة نجاح للمستخدم (نفس تجربة التطبيقات العالمية)
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.mark_email_read_outlined, color: AppTheme.emeraldGreen, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("تحقق من بريدك الإلكتروني",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text("لقد أرسلنا رابط إعادة تعيين كلمة المرور إلى ${_emailController.text}",
                textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // إغلاق الحوار
              Navigator.pop(context); // العودة لصفحة الدخول
            },
            child: const Text("العودة لتسجيل الدخول", style: TextStyle(color: AppTheme.emeraldGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.emeraldGreen,
        title: const Text("استعادة كلمة المرور", style: TextStyle(fontSize: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("لا تقلق..", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen)),
            const SizedBox(height: 10),
            const Text(
              "أدخل بريدك الإلكتروني المسجل وسنرسل لك رابطاً لتغيير كلمة المرور الخاصة بك.",
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(height: 40),

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: AppTheme.emeraldGreen, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.emeraldGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: _isLoading ? null : _sendResetLink,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('إرسال الرابط', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}