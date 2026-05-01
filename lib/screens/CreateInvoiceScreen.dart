import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:local_auth/local_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../theme/app_theme.dart';
import '../main.dart'; // الوصول إلى AppData و InvoiceModel

class CreateInvoiceScreen extends StatefulWidget {
  final String? initialName;
  final String? initialAmount;
  final String? initialService;
  final String? initialDue;
  final String? initialPhone;
  final String? initialNotes;

  const CreateInvoiceScreen({
    super.key,
    this.initialName,
    this.initialAmount,
    this.initialService,
    this.initialDue,
    this.initialPhone,
    this.initialNotes,
  });

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final LocalAuthentication auth = LocalAuthentication();

  // التحكم في المدخلات
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _serviceController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  late String _selectedDue;
  final List<String> _dueOptions = ['يوم واحد', 'بعد 3 أيام', 'بعد أسبوع', 'بعد شهر'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _phoneController = TextEditingController(text: widget.initialPhone ?? '');
    _serviceController = TextEditingController(text: widget.initialService ?? '');
    _amountController = TextEditingController(text: widget.initialAmount ?? '');
    _notesController = TextEditingController(text: widget.initialNotes ?? '');
    
    // تأكد من أن القيمة الممررة موجودة في الخيارات
    if (widget.initialDue != null && _dueOptions.contains(widget.initialDue)) {
      _selectedDue = widget.initialDue!;
    } else {
      _selectedDue = 'يوم واحد';
    }
  }

  // دالة التحقق من البصمة (البيومترية) لضمان الأمان قبل إصدار الفاتورة
  Future<bool> _authenticate() async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isDeviceSupported = await auth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) return true;

      return await auth.authenticate(
        localizedReason: 'يرجى تأكيد هويتك لإصدار وإرسال الفاتورة',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      debugPrint("Error Auth: $e");
      return false;
    }
  }

  // دالة توليد وحفظ وإرسال الفاتورة (التخزين المحلي + Firebase)
  void _generateAndSendInvoice() async {
    if (_formKey.currentState!.validate()) {

      // 1. طلب البصمة أولاً
      bool isAuthenticated = await _authenticate();

      if (!isAuthenticated) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("فشل التحقق من الهوية، لم يتم إرسال الفاتورة")),
          );
        }
        return;
      }

      // 2. تجهيز بيانات الفاتورة بصيغة موحدة
      final now = DateTime.now();
      final month = now.month.toString().padLeft(2, '0');
      final day = now.day.toString().padLeft(2, '0');
      final formattedDate = "${now.year}/$month/$day";

      final newInvoice = InvoiceModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        amount: double.tryParse(_amountController.text) ?? 0.0,
        phone: _phoneController.text.trim(),
        service: _serviceController.text.isEmpty ? "خدمة عامة" : _serviceController.text,
        date: formattedDate,
        isPaid: false,
      );

      // 3. الرفع إلى Firebase (للمزامنة مع بوابة الدفع الويب)
      try {
        await FirebaseDatabase.instance.ref('invoices/${newInvoice.phone}').set({
          'clientName': newInvoice.name,
          'amount': newInvoice.amount,
          'isPaid': false,
          'walletType': '',
          'timestamp': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('Firebase upload error: $e');
      }

      // 4. الحفظ المحلي (Local Storage) لضمان بقاء البيانات في التطبيق
      setState(() {
        AppData.invoices.add(newInvoice);
      });

      // حفظ الفاتورة في ذاكرة الهاتف (SharedPreferences) فوراً
      await AppData.saveInvoices();

      // إبلاغ المستمعين (الإحصائيات والداشبورد) بوجود بيانات جديدة
      AppData.notify();

      // 5. تجهيز روابط الدفع ورسالة الواتساب للعميل
      String paymentLink = "https://flutter-ai-playground-8da85.web.app/#/pay?phone=${_phoneController.text.trim()}";

      String whatsappMessage =
          "مرحباً ${_nameController.text}،\n"
          "تم إصدار فاتورة جديدة لك من Monjez Fin.\n"
          "الخدمة: ${_serviceController.text}\n"
          "المبلغ: ${_amountController.text} SAR\n"
          "تاريخ الاستحقاق: $_selectedDue\n\n"
          "يمكنك الدفع بسهولة عبر الرابط التالي:\n$paymentLink";

      String whatsappUrl = "https://wa.me/${_phoneController.text.trim()}?text=${Uri.encodeComponent(whatsappMessage)}";

      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("تم التحقق ✅ وحفظ فاتورة لـ ${_nameController.text}"),
              backgroundColor: AppTheme.emeraldGreen,
            ),
          );
        }
      } else {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("تم حفظ الفاتورة في النظام، لكن تعذر فتح الواتساب")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("بيانات الفاتورة الجديدة"),
        backgroundColor: AppTheme.emeraldGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel("اسم العميل"),
              _buildTextField(_nameController, "مثلاً: أحمد علي"),

              _buildFieldLabel("رقم الواتساب (مثال: 967770000000)"),
              _buildTextField(_phoneController, "967...", isPhone: true),

              _buildFieldLabel("نوع الخدمة"),
              _buildTextField(_serviceController, "تصميم تطبيق، استشارة.."),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel("المبلغ (SAR)"),
                        _buildTextField(_amountController, "0.00", isNumber: true),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel("الاستحقاق"),
                        DropdownButtonFormField<String>(
                          value: _selectedDue,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          items: _dueOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: const TextStyle(fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedDue = val!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              _buildFieldLabel("ملاحظات إضافية"),
              _buildTextField(_notesController, "اكتبي أي تفاصيل تظهر للعميل", maxLines: 2),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _generateAndSendInvoice,
                  icon: const Icon(Icons.fingerprint, color: Colors.white),
                  label: const Text("تأكيد البصمة وإرسال",
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.emeraldGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 15),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
  );

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false, bool isPhone = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : (isPhone ? TextInputType.phone : TextInputType.text),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.emeraldGreen, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (val) => val!.isEmpty ? "هذا الحقل مطلوب" : null,
    );
  }
}