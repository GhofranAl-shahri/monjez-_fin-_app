import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../theme/app_theme.dart';

class PaymentWebPage extends StatefulWidget {
  final String phone;

  const PaymentWebPage({super.key, required this.phone});

  @override
  State<PaymentWebPage> createState() => _PaymentWebPageState();
}

class _PaymentWebPageState extends State<PaymentWebPage> {
  Map<String, dynamic>? invoiceData;
  bool isLoading = true;
  bool isPaid = false;
  String selectedMethod = 'Al-Kuraimi';
  final List<String> paymentMethods = ['Al-Kuraimi', 'Jawali', 'Mobile Money', 'Bank Transfer'];

  @override
  void initState() {
    super.initState();
    _fetchInvoice();
  }

  Future<void> _fetchInvoice() async {
    if (widget.phone.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final snapshot = await FirebaseDatabase.instance.ref('invoices/${widget.phone}').get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          invoiceData = data;
          isPaid = data['isPaid'] ?? false;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching invoice: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _confirmPayment() async {
    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseDatabase.instance.ref('invoices/${widget.phone}').update({
        'isPaid': true,
        'walletType': selectedMethod,
      });

      setState(() {
        isPaid = true;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error updating payment: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('بوابة الدفع | Monjez Fin'),
        centerTitle: true,
        backgroundColor: AppTheme.emeraldGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.emeraldGreen),
      );
    }

    if (widget.phone.isEmpty || invoiceData == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
            SizedBox(height: 16),
            Text(
              'الفاتورة غير موجودة أو رقم الهاتف غير صحيح.',
              style: TextStyle(fontSize: 18, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (isPaid) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 80, color: AppTheme.emeraldGreen),
            const SizedBox(height: 20),
            const Text(
              'تم الدفع بنجاح!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen),
            ),
            const SizedBox(height: 10),
            Text(
              'شكراً لك يا ${invoiceData!['clientName']} لتعاملك معنا.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'تفاصيل الفاتورة',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        _buildDetailRow('اسم العميل:', invoiceData!['clientName'] ?? 'غير متوفر'),
        const Divider(),
        _buildDetailRow('رقم الهاتف:', widget.phone),
        const Divider(),
        _buildDetailRow('المبلغ المطلوب:', '${invoiceData!['amount']} SAR', isHighlight: true),
        const SizedBox(height: 30),
        const Text(
          'اختر طريقة الدفع',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedMethod,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: AppTheme.emeraldGreen),
              items: paymentMethods.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    selectedMethod = val;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _confirmPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.emeraldGreen,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: const Text(
            'تأكيد الدفع',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 20 : 16,
              fontWeight: FontWeight.bold,
              color: isHighlight ? Colors.redAccent : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
