import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = "Rehab Ali Sabr";
    _jobController.text = "مهندسة برمجيات | مُنجز مالي";
    _emailController.text = "rehab@monjez.com";
    _bankAccountController.text = "7000123456";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _jobController.dispose();
    _emailController.dispose();
    _bankAccountController.dispose();
    super.dispose();
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("تسجيل الخروج",
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.bold)
          ),
          content: const Text("هل أنتِ متأكدة من رغبتكِ في تسجيل الخروج من تطبيق مُنجز مالي؟",
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 15)
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              child: const Text("خروج", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _saveProfile() {
    setState(() {
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحديث ملفك الشخصي بنجاح ✅', textAlign: TextAlign.center),
        backgroundColor: AppTheme.emeraldGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('الهوية المالية'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppTheme.emeraldGreen,
        actions: [
          TextButton(
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
            child: Text(
              _isEditing ? 'حفظ' : 'تعديل',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            _buildProfileImage(),
            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildEditableField(
                    label: 'الاسم الكامل',
                    controller: _nameController,
                    icon: Icons.person_outline,
                    enabled: _isEditing,
                  ),
                  _buildEditableField(
                    label: 'المسمى الوظيفي',
                    controller: _jobController,
                    icon: Icons.work_outline,
                    enabled: _isEditing,
                  ),
                  _buildEditableField(
                    label: 'البريد الإلكتروني',
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    enabled: _isEditing,
                  ),
                  _buildEditableField(
                    label: 'رقم الحساب البنكي',
                    controller: _bankAccountController,
                    icon: Icons.account_balance_wallet_outlined,
                    enabled: _isEditing,
                    isNumeric: true,
                  ),

                  const Divider(height: 40),

                  // تم الإبقاء على خيار الأمان فقط وحذف اللغة
                  _buildSimpleOption(Icons.security_rounded, 'الأمان وكلمة المرور', () {
                    Navigator.pushNamed(context, '/security');
                  }),

                  const SizedBox(height: 30),

                  // زر تسجيل الخروج
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15)
                    ),
                    child: ListTile(
                      onTap: _showLogoutDialog,
                      leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                      title: const Text('تسجيل الخروج',
                          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.redAccent),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 65,
            backgroundColor: AppTheme.mintGreen.withOpacity(0.2),
            child: const Icon(Icons.person, size: 85, color: AppTheme.emeraldGreen),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.emeraldGreen,
            child: IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
    bool isNumeric = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppTheme.emeraldGreen, size: 22),
              filled: !enabled,
              fillColor: enabled ? Colors.white : Colors.grey.withOpacity(0.05),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: AppTheme.emeraldGreen),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: AppTheme.emeraldGreen, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.emeraldGreen),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}