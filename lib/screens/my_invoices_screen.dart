import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../main.dart';

// المكتبات المطلوبة
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class MyInvoicesScreen extends StatefulWidget {
  const MyInvoicesScreen({super.key});

  @override
  State<MyInvoicesScreen> createState() => _MyInvoicesScreenState();
}

class _MyInvoicesScreenState extends State<MyInvoicesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // دالة توليد محتوى الـ PDF بتنسيق رسمي زمردي
  Future<Uint8List> _generatePdf(InvoiceModel invoice) async {
    final pdf = pw.Document();
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final boldFont = await PdfGoogleFonts.cairoBold();
    final primaryColor = PdfColor.fromInt(AppTheme.emeraldGreen.value);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: arabicFont, bold: boldFont),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  decoration: pw.BoxDecoration(
                    color: primaryColor,
                    borderRadius: const pw.BorderRadius.only(
                      bottomLeft: pw.Radius.circular(10),
                      bottomRight: pw.Radius.circular(10),
                    ),
                  ),
                  child: pw.Text(
                    "فاتورة ضريبية مبسطة",
                    style: pw.TextStyle(fontSize: 22, color: PdfColors.white, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    // تم إبقاء رقم الفاتورة وحذف تاريخ الإصدار من هنا
                    pw.Text("رقم الفاتورة: #${DateTime.now().millisecond}", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    pw.Text("تطبيق منجز مالي", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(thickness: 1, color: primaryColor),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  columnWidths: {0: const pw.FlexColumnWidth(3), 1: const pw.FlexColumnWidth(2)},
                  children: [
                    _buildPdfTableRow("البيان", "التفاصيل", isHeader: true, headerColor: primaryColor),
                    _buildPdfTableRow("اسم العميل", invoice.name),
                    _buildPdfTableRow("رقم العميل", invoice.phone), // إضافة رقم العميل للجدول
                    _buildPdfTableRow("نوع الخدمة", invoice.service), // إضافة نوع الخدمة للجدول
                    _buildPdfTableRow("المبلغ الإجمالي", "${invoice.amount} SAR"),
                    _buildPdfTableRow("تاريخ الفاتورة", invoice.date),
                    _buildPdfTableRow("حالة السداد", invoice.isPaid ? "مدفوعة" : "غير مدفوعة"),
                  ],
                ),
                pw.Spacer(),
                pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                pw.Center(child: pw.Text("شكراً لتعاملكم معنا - نسعد بخدمتكم دائماً", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600))),
              ],
            ),
          );
        },
      ),
    );
    return pdf.save();
  }

  // دالة المشاركة الفورية
  Future<void> _sharePDF(InvoiceModel invoice) async {
    try {
      final bytes = await _generatePdf(invoice);
      final tempDir = await getTemporaryDirectory();
      final String fileName = "فاتورة_${invoice.name.replaceAll(' ', '_')}.pdf";
      final file = await File('${tempDir.path}/$fileName').create();
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'مرفق فاتورة العميل: ${invoice.name}',
      );
    } catch (e) {
      debugPrint("Share Error: $e");
    }
  }

  pw.TableRow _buildPdfTableRow(String label, String value, {bool isHeader = false, PdfColor? headerColor}) {
    return pw.TableRow(
      decoration: isHeader ? pw.BoxDecoration(color: headerColor) : null,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(12),
          child: pw.Text(value, style: pw.TextStyle(fontSize: isHeader ? 12 : 11, fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal, color: isHeader ? PdfColors.white : PdfColors.black), textAlign: pw.TextAlign.right),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(12),
          child: pw.Text(label, style: pw.TextStyle(fontSize: isHeader ? 12 : 11, fontWeight: pw.FontWeight.bold, color: isHeader ? PdfColors.white : PdfColors.black), textAlign: pw.TextAlign.right),
        ),
      ],
    );
  }

  // تصميم نافذة التفاصيل
  void _showInvoiceDetails(InvoiceModel invoice) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("تفاصيل الفاتورة", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen)),
              const Divider(height: 30),
              _detailRow("اسم العميل:", invoice.name),
              _detailRow("رقم العميل:", invoice.phone), // أضفتها هنا للعرض أيضاً
              _detailRow("نوع الخدمة:", invoice.service), // أضفتها هنا للعرض أيضاً
              _detailRow("المبلغ:", "${invoice.amount} SAR"),
              _detailRow("التاريخ:", invoice.date),
              _detailRow("الحالة:", invoice.isPaid ? "مدفوعة" : "غير مدفوعة"),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _sharePDF(invoice);
                  },
                  icon: const Icon(Icons.share, color: Colors.white, size: 20),
                  label: const Text("مشاركة الفاتورة PDF",
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.emeraldGreen,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("إغلاق", style: TextStyle(color: Colors.grey.shade600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: const Text("فواتيري", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppTheme.emeraldGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [Tab(text: "الكل"), Tab(text: "المدفوعة"), Tab(text: "غير المدفوعة")],
        ),
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: AppData.updateNotifier,
        builder: (context, _, __) {
          final List<InvoiceModel> allInvoices = AppData.invoices;
          return TabBarView(
            controller: _tabController,
            children: [
              _buildInvoiceList(allInvoices),
              _buildInvoiceList(allInvoices.where((i) => i.isPaid).toList()),
              _buildInvoiceList(allInvoices.where((i) => !i.isPaid).toList()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInvoiceList(List<InvoiceModel> invoices) {
    if (invoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text("لا توجد فواتير في هذا القسم", style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }
    final reversedInvoices = invoices.reversed.toList();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: reversedInvoices.length,
      itemBuilder: (context, index) {
        final item = reversedInvoices[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: item.isPaid ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: item.isPaid ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              child: Icon(item.isPaid ? Icons.check_circle_outline : Icons.pending_actions_outlined, color: item.isPaid ? Colors.green : Colors.red),
            ),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text("التاريخ: ${item.date}", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () => _showInvoiceDetails(item),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.emeraldGreen, padding: const EdgeInsets.symmetric(horizontal: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: const Text("عرض", style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("${item.amount} SAR", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.emeraldGreen)),
                const SizedBox(height: 4),
                Text(item.isPaid ? "مدفوعة" : "غير مدفوعة", style: TextStyle(color: item.isPaid ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      },
    );
  }
}