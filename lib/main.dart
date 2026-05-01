import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:app_links/app_links.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

// الاستيرادات الخاصة بالثيم والشاشات
import 'theme/app_theme.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/income_details_screen.dart';
import 'screens/unpaid_invoices_screen.dart';
import 'screens/CreateInvoiceScreen.dart';
import 'screens/my_invoices_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/security_screen.dart';
import 'screens/payment_web_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// نموذج بيانات الفاتورة مع دعم التحويل لـ JSON
class InvoiceModel {
  final String id;
  final String name;
  final double amount;
  final String date;
  final String phone;
  final String service;
  bool isPaid;

  InvoiceModel({
    required this.id, required this.name, required this.amount,
    required this.date, required this.phone, this.service = "خدمة عامة", this.isPaid = false,
  });

  // تحويل الكائن إلى Map للحفظ المحلي
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'date': date,
      'phone': phone,
      'service': service,
      'isPaid': isPaid,
    };
  }

  // استعادة الكائن من الذاكرة المحلية
  factory InvoiceModel.fromMap(Map<String, dynamic> map) {
    return InvoiceModel(
      id: map['id'],
      name: map['name'],
      amount: (map['amount'] as num).toDouble(),
      date: map['date'],
      phone: map['phone'],
      service: map['service'] ?? "خدمة عامة",
      isPaid: map['isPaid'] ?? false,
    );
  }
}

class NotificationModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final double amount;
  final DateTime timestamp;

  NotificationModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.amount,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      customerName: map['customerName'],
      customerPhone: map['customerPhone'],
      amount: (map['amount'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

// مدير بيانات التطبيق (المحرك الرئيسي للتخزين والمزامنة)
class AppData {
  static final ValueNotifier<int> updateNotifier = ValueNotifier(0);
  static List<InvoiceModel> invoices = [];
  static List<NotificationModel> notifications = [];

  static void notify() {
    updateNotifier.value++;
  }

  // --- دالة الحفظ الدائم في ذاكرة الهاتف ---
  static Future<void> saveInvoices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String encodedData = jsonEncode(invoices.map((inv) => inv.toMap()).toList());
      await prefs.setString('monjez_saved_invoices', encodedData);
      debugPrint("✅ تم حفظ الفواتير محلياً");
    } catch (e) {
      debugPrint("❌ خطأ في الحفظ المحلي: $e");
    }
  }

  // --- دالة تحميل البيانات عند فتح التطبيق ---
  static Future<void> loadInvoices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString('monjez_saved_invoices');
      if (jsonString != null) {
        List<dynamic> decodedData = jsonDecode(jsonString);
        invoices = decodedData.map((item) => InvoiceModel.fromMap(item)).toList();
        notify();
        debugPrint("✅ تم تحميل ${invoices.length} فاتورة من الذاكرة");
      }
    } catch (e) {
      debugPrint("❌ خطأ في تحميل البيانات: $e");
    }
  }

  static Future<void> saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String encodedData = jsonEncode(notifications.map((n) => n.toMap()).toList());
      await prefs.setString('monjez_saved_notifications', encodedData);
      debugPrint("✅ تم حفظ الإشعارات محلياً");
    } catch (e) {
      debugPrint("❌ خطأ في الحفظ المحلي للإشعارات: $e");
    }
  }

  static Future<void> loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString('monjez_saved_notifications');
      if (jsonString != null) {
        List<dynamic> decodedData = jsonDecode(jsonString);
        notifications = decodedData.map((item) => NotificationModel.fromMap(item)).toList();
        debugPrint("✅ تم تحميل ${notifications.length} إشعار من الذاكرة");
      }
    } catch (e) {
      debugPrint("❌ خطأ في التحميل المحلي للإشعارات: $e");
    }
  }

  // معالجة تحديثات الدفع (تحديث الحالة + حفظ محلي + إشعار)
  static Future<void> processPaymentUpdate(String phone) async {
    bool isUpdated = false;
    double paidAmount = 0;
    String customerName = "";

    for (var inv in invoices) {
      // التحقق من تطابق الرقم (الرقم المخزن قد يحتوي على مفتاح الدولة أو لا)
      if (inv.phone.contains(phone) || phone.contains(inv.phone)) {
        if (inv.isPaid) continue; // إذا كانت مدفوعة مسبقاً نتخطاها
        inv.isPaid = true;
        paidAmount = inv.amount;
        customerName = inv.name;
        isUpdated = true;
      }
    }

    if (isUpdated) {
      await saveInvoices(); // حفظ التغيير فوراً في الذاكرة الدائمة
      
      // إنشاء الإشعار الجديد وحفظه
      final newNotification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerName: customerName,
        customerPhone: phone,
        amount: paidAmount,
        timestamp: DateTime.now(),
      );
      notifications.insert(0, newNotification); // إضافته في بداية القائمة
      await saveNotifications();

      notify(); // تحديث الواجهات (مثل شاشة الإحصائيات)

      // تشغيل صوت النجاح
      try {
        final player = AudioPlayer();
        await player.play(AssetSource('sounds/success_pay.mp3'));
      } catch (e) { debugPrint("Sound Error: $e"); }

      // إظهار إشعار Awesome Notification الاحترافي
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'payment_channel',
          title: 'تم استلام مبلغ جديد! ✅',
          body: 'العميل $customerName دفع مبلغ $paidAmount SAR بنجاح',
          notificationLayout: NotificationLayout.Default,
          backgroundColor: const Color(0xFF2ECC71),
        ),
      );
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppData.loadNotifications();

  // 1. تهيئة Firebase
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint("Firebase Init Error: $e");
  }

  // 2. تحميل الفواتير المخزنة محلياً قبل بناء الواجهة
  await AppData.loadInvoices();

  // 3. تهيئة إشعارات Awesome Notifications
  AwesomeNotifications().initialize(
    null, // أيقونة التطبيق الافتراضية
    [
      NotificationChannel(
        channelGroupKey: 'payment_channel_group',
        channelKey: 'payment_channel',
        channelName: 'تنبيهات الدفع',
        channelDescription: 'إشعارات عند استلام مبالغ مالية',
        defaultColor: const Color(0xFF2ECC71),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        playSound: true,
        enableVibration: true,
      )
    ],
  );

  // طلب إذن الإشعارات
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });

  runApp(const MonjezFinApp());
}

class MonjezFinApp extends StatefulWidget {
  const MonjezFinApp({super.key});
  @override
  State<MonjezFinApp> createState() => _MonjezFinAppState();
}

class _MonjezFinAppState extends State<MonjezFinApp> {
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    initSystemListeners();
  }

  void initSystemListeners() {
    // أ: مراقبة الروابط الخارجية (Deep Links)
    _appLinks = AppLinks();
    _appLinks.uriLinkStream.listen((uri) => handleIncomingLink(uri));

    // ب: مراقبة قاعدة بيانات Firebase للتحديثات اللحظية
    FirebaseDatabase.instance.ref('invoices').onChildChanged.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        final bool isPaidFromCloud = data['isPaid'] ?? false;
        if (isPaidFromCloud) {
          final String phone = event.snapshot.key ?? '';
          AppData.processPaymentUpdate(phone);
        }
      }
    });
  }

  void handleIncomingLink(Uri uri) {
    // monjez://payment_done?phone=967...
    if (uri.scheme == 'monjez' && uri.host == 'payment_done') {
      final phone = uri.queryParameters['phone'];
      if (phone != null) {
        AppData.processPaymentUpdate(phone);
        if (mounted) setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monjez Fin | مُنجز مالي',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/income_details': (context) => const IncomeDetailsScreen(),
        '/unpaid_invoices': (context) => const UnpaidInvoicesScreen(),
        '/create_invoice': (context) => const CreateInvoiceScreen(),
        '/my_invoices': (context) => const MyInvoicesScreen(),
        '/statistics': (context) => const StatisticsScreen(),
        '/security': (context) => const SecurityScreen(),
      },
      // معالجة الروابط لصفحة الدفع عبر الويب داخل التطبيق
      onGenerateRoute: (settings) {
        if (settings.name != null && settings.name!.startsWith('/pay')) {
          final uri = Uri.parse(settings.name!);
          String phone = uri.queryParameters['phone'] ?? '';
          return MaterialPageRoute(
            builder: (context) => PaymentWebPage(phone: phone),
            settings: settings,
          );
        }
        return null;
      },
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
    );
  }
}