import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  // متغيرات الحالة العامة للربط مع باقي التطبيق
  static bool useBiometricForLogin = false;
  static bool useBiometricForTransactions = true;

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {

  // دالة إظهار نافذة تغيير كلمة المرور (النموذج الأولي)
  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "تغيير كلمة المرور",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.emeraldGreen, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField("كلمة المرور القديمة"),
            const SizedBox(height: 10),
            _buildDialogField("كلمة المرور الجديدة"),
            const SizedBox(height: 10),
            _buildDialogField("تأكيد الكلمة الجديدة"),
          ],
        ),
        actions: [
          Center(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.emeraldGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context); // إغلاق النافذة
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("تم تغيير كلمة المرور بنجاح ✅", textAlign: TextAlign.center),
                      backgroundColor: AppTheme.emeraldGreen,
                    ),
                  );
                },
                child: const Text("تأكيد التغيير", style: TextStyle(color: Colors.white)),
              ),
            ),
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
        title: const Text("الخصوصية والأمان"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.emeraldGreen,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildSectionTitle("إعدادات الوصول الحيوية"),
            const SizedBox(height: 10),

            // خيارات البصمة بألوان مُنجز
            _buildSwitchOption(
              Icons.fingerprint,
              "البصمة لتسجيل الدخول",
              SecurityScreen.useBiometricForLogin,
                  (val) => setState(() => SecurityScreen.useBiometricForLogin = val),
            ),
            _buildSwitchOption(
              Icons.security_update_good,
              "البصمة لتأكيد العمليات",
              SecurityScreen.useBiometricForTransactions,
                  (val) => setState(() => SecurityScreen.useBiometricForTransactions = val),
            ),

            const Divider(height: 40),
            _buildSectionTitle("إعدادات الحماية"),

            // زر تغيير كلمة المرور الذي يفتح النافذة
            ListTile(
              onTap: _showChangePasswordDialog,
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lock_reset_rounded, color: AppTheme.emeraldGreen),
              ),
              title: const Text("تغيير كلمة المرور", style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // أدوات مساعدة للتصميم
  Widget _buildSectionTitle(String title) => Text(
    title,
    style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold),
  );

  Widget _buildSwitchOption(IconData icon, String title, bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppTheme.emeraldGreen),
      title: Text(title),
      trailing: Switch(
        value: value,
        activeColor: AppTheme.emeraldGreen,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDialogField(String hint) {
    return TextField(
      obscureText: false, // يظهر الأرقام كما طلبتِ
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}