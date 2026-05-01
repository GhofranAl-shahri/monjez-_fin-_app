import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/fab_menu_bottom_sheet.dart';
import '../services/ai_voice_service.dart';
import 'CreateInvoiceScreen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final AiVoiceService _aiVoiceService = AiVoiceService();
  bool _isListening = false;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    // تهيئة مسبقة للمحرك الصوتي ليكون جاهزاً فور الضغط
    _aiVoiceService.initializeSpeech();
  }

  void _startVoiceInvoice() {
    setState(() {
      _isListening = true;
      _isAnalyzing = false;
    });

    String lastRecognizedText = "";

    // عرض القائمة السفلية التي تظهر حالة الاستماع
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (bottomSheetContext) {
        return StatefulBuilder(builder: (statefulContext, setModalState) {
          
          void startAnalysis() async {
            _aiVoiceService.stopListening();
            Navigator.pop(bottomSheetContext); // إغلاق القائمة السفلية
            
            if (lastRecognizedText.trim().isEmpty) {
              setState(() => _isListening = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('لم يتم التعرف على أي صوت!')),
              );
              return;
            }

            setState(() {
              _isListening = false;
              _isAnalyzing = true;
            });

            // إظهار نافذة التحميل
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => const AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(color: AppTheme.emeraldGreen),
                    SizedBox(width: 20),
                    Text("جاري استخراج البيانات بذكاء..."),
                  ],
                ),
              ),
            );

            final result = await _aiVoiceService.parseInvoiceText(lastRecognizedText);
            
            // إغلاق نافذة التحميل
            if (mounted) {
              Navigator.of(context, rootNavigator: true).pop();
            }

            if (result is Map) {
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateInvoiceScreen(
                      initialName: result['name']?.toString() ?? '',
                      initialAmount: result['amount']?.toString() ?? '',
                      initialService: result['service']?.toString() ?? '',
                      initialDue: result['due']?.toString() ?? 'يوم واحد',
                      initialPhone: result['phone']?.toString() ?? '',
                      initialNotes: result['notes']?.toString() ?? '',
                    ),
                  ),
                );
              }
            } else if (result is String) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result),
                    backgroundColor: Colors.red.shade800,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            }
          }

          // بدء الاستماع مع معالجة الخطأ
          _aiVoiceService.startListening(
            (text) {
              setModalState(() {
                lastRecognizedText = text;
              });
            },
            () {
              // التوقف التلقائي (إن حدث) بعد انتهاء مدة الصمت
              if (lastRecognizedText.isNotEmpty) {
                 startAnalysis();
              } else {
                 // إذا توقف ولم يلتقط شيئاً، نغلق النافذة ونعيد الحالة
                 if (mounted) Navigator.pop(bottomSheetContext);
                 setState(() => _isListening = false);
              }
            }
          ).then((success) {
            if (!success && mounted) {
              Navigator.pop(bottomSheetContext);
              setState(() => _isListening = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تعذر تشغيل الميكروفون. تأكد من الصلاحيات وهدوء المكان.')),
              );
            }
          });

          return Container(
            padding: const EdgeInsets.all(25),
            height: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mic, size: 50, color: AppTheme.emeraldGreen),
                const SizedBox(height: 15),
                const Text(
                  "تحدث الآن.. أنا أستمع لفاتورتك",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12)
                    ),
                    width: double.infinity,
                    child: SingleChildScrollView(
                      reverse: true, // ليبقى النص الأخير ظاهراً دائماً
                      child: Text(
                        lastRecognizedText.isEmpty ? "..." : lastRecognizedText,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: lastRecognizedText.isEmpty ? Colors.grey : Colors.black87),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        _aiVoiceService.stopListening();
                        Navigator.pop(context);
                        setState(() => _isListening = false);
                      },
                      child: const Text("إلغاء", style: TextStyle(color: Colors.red, fontSize: 16)),
                    ),
                    ElevatedButton(
                      onPressed: () => startAnalysis(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.emeraldGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("تم", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      // 1. موقع الزر الوسطي (مركز العمليات)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 2. الزر الدائري (الآن هو المكان الوحيد لإضافة الفواتير)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            builder: (context) => const FABMenuBottomSheet(),
          );
        },
        backgroundColor: AppTheme.emeraldGreen,
        elevation: 6,
        shape: const CircleBorder(), // دائري تماماً
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),

      // 3. شريط التنقل السفلي مع الفتحة الانسيابية
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(
                index: 0,
                icon: Icons.home_filled,
                label: 'الرئيسية',
                onTap: () => setState(() => _selectedIndex = 0),
              ),
              const SizedBox(width: 40), // مساحة للزر الدائري
              _buildBottomNavItem(
                index: 1,
                icon: Icons.person_outline_rounded,
                label: 'الملف الشخصي',
                onTap: () {
                  setState(() => _selectedIndex = 1);
                  Navigator.pushNamed(context, '/profile');
                },
              ),
            ],
          ),
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // الهيدر الترحيبي
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Monjez Fin / مُنجز مالي',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.emeraldGreen,
                      ),
                    ),
                    Text(
                      'مرحباً بكِ !',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // زر الذكاء الاصطناعي الجديد (الميكروفون)
                    IconButton(
                      onPressed: _startVoiceInvoice,
                      icon: const Icon(Icons.mic, color: Colors.white, size: 26),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.emeraldGreen,
                        padding: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => Navigator.pushNamed(context, '/notifications'),
                      icon: const Icon(Icons.notifications_active_outlined,
                          color: AppTheme.emeraldGreen, size: 26),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.mintGreen.withOpacity(0.15),
                        padding: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

            // الكروت المالية الرئيسية (فقط الدخل والمستحقات)
            DashboardCard(
              title: 'إجمالي الدخل',
              amount: 'SAR 45,000',
              icon: Icons.account_balance_wallet_rounded,
              isPrimary: true,
              onTap: () => Navigator.pushNamed(context, '/income_details'),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<int>(
              valueListenable: AppData.updateNotifier,
              builder: (context, _, __) {
                final unpaidList = AppData.invoices.where((i) => !i.isPaid).toList();
                double totalPending = unpaidList.fold(0, (sum, item) => sum + item.amount);
                return DashboardCard(
                  title: 'المستحقات غير المدفوعة',
                  amount: 'SAR ${totalPending.toStringAsFixed(2)}',
                  icon: Icons.pending_actions_rounded,
                  isPrimary: false,
                  onTap: () => Navigator.pushNamed(context, '/unpaid_invoices'),
                );
              },
            ),

            // تم حذف كرت "إنشاء فاتورة" من هنا بنجاح
          ],
        ),
      ),
    );
  }

  // ويدجت عناصر التنقل السفلي
  Widget _buildBottomNavItem({required int index, required IconData icon, required String label, required VoidCallback onTap}) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppTheme.emeraldGreen : Colors.grey,
            size: 26,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? AppTheme.emeraldGreen : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}