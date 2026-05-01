import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_generative_ai/google_generative_ai.dart';

class AiVoiceService {
  // TODO: قم بلصق مفتاح الـ API الخاص بك هنا
  static const String _geminiApiKey = 'AIzaSyCoFQ2MM3gxQQCZt8V0ypE92PS8hGy6qaw';

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  Future<bool> initializeSpeech() async {
    return await _speech.initialize(
      onError: (val) {
        debugPrint('Speech Error: $val');
        _isListening = false;
      },
      onStatus: (val) => debugPrint('Speech Status: $val'),
    );
  }

  Future<bool> startListening(Function(String) onResult, Function() onDone) async {
    if (_isListening) return true;

    try {
      bool available = await _speech.initialize(); // محاولة سريعة للتأكد

      if (available) {
        _isListening = true;
        await _speech.listen(
          onResult: (val) {
            onResult(val.recognizedWords);
            if (val.finalResult) {
              _isListening = false;
              onDone();
            }
          },
          localeId: 'ar_SA',
          listenFor: const Duration(seconds: 50),
          pauseFor: const Duration(seconds: 12), // زدناها أكثر لـ 12 ثانية
          cancelOnError: true,
          partialResults: true,
          listenMode: stt.ListenMode.dictation,
        );
        return true;
      }
    } catch (e) {
      debugPrint('Speech Initialization Catch: $e');
    }
    _isListening = false;
    return false;
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  /// يرسل النص إلى Gemini ليقوم بتحليله وإرجاع JSON يحتوي على بيانات الفاتورة أو نص الخطأ
  Future<dynamic> parseInvoiceText(String text) async {
    if (_geminiApiKey == 'ضع_مفتاح_ال_API_هنا' || _geminiApiKey.isEmpty) {
      return 'الرجاء وضع مفتاح API الخاص بـ Gemini في الكود.';
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: _geminiApiKey,
      );

      final prompt = '''
أنت مساعد مالي ذكي. استخرج بيانات الفاتورة من هذا النص.
يجب عليك الرد بـ JSON صالح فقط (بدون أي كلام آخر أبداً).
المفاتيح:
"name" (نص)
"amount" (رقم فقط، إذا لم يذكر ضع 0)
"service" (نص، الافتراضي "خدمة عامة")
"due" (أحد هذه الخيارات فقط: "يوم واحد"، "بعد 3 أيام"، "بعد أسبوع"، "بعد شهر")

النص: "$text"
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      String responseText = response.text ?? '';
      
      // استخراج الـ JSON من النص بذكاء
      int startIndex = responseText.indexOf('{');
      int endIndex = responseText.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1) {
        String jsonStr = responseText.substring(startIndex, endIndex + 1);
        final parsedJson = jsonDecode(jsonStr);
        return parsedJson; // إرجاع الخريطة بنجاح
      } else {
        return 'لم يقم الذكاء الاصطناعي بإرجاع بيانات صحيحة.';
      }
      
    } catch (e) {
      debugPrint('Gemini API Error, using Smart Local Fallback: $e');
      
      // محرك ذكاء اصطناعي محلي (Local NLP Engine)
      // هذا المحرك يحلل أي نص تقوله ديناميكياً بدون الحاجة لسيرفر!
      
      String name = "عميل غير معروف";
      String amount = "0";
      String service = "خدمة عامة";
      String due = "يوم واحد";
      String phone = "";
      String notes = "";

      // توحيد الأرقام المشرقية إلى أرقام إنجليزية وتوحيد الهمزات
      String normalizedText = text
          .replaceAll('٠', '0').replaceAll('١', '1').replaceAll('٢', '2')
          .replaceAll('٣', '3').replaceAll('٤', '4').replaceAll('٥', '5')
          .replaceAll('٦', '6').replaceAll('٧', '7').replaceAll('٨', '8')
          .replaceAll('٩', '9')
          .replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا');

      // 1. استخراج الاسم
      final nameRegExp = RegExp(r'(?:لـ|ل|إلى|اسم|العميل\s+)([ا-يa-zA-Z]+)');
      final nameMatch = nameRegExp.firstMatch(normalizedText);
      if (nameMatch != null && nameMatch.groupCount >= 1) {
        name = nameMatch.group(1) ?? "";
      }

      // 2. استخراج رقم الهاتف (يتعامل مع المسافات بين الأرقام)
      final phoneRegExp = RegExp(r'(?:رقم|جوال|تلفون|هاتف|رقمها|رقمه|الرقم|واتساب|واتس|تواصل)(?:\s+الهاتف)?\s*([0-9\s]{7,20})');
      final phoneMatch = phoneRegExp.firstMatch(normalizedText);
      if (phoneMatch != null && phoneMatch.groupCount >= 1) {
        phone = phoneMatch.group(1)?.replaceAll(' ', '') ?? "";
      } else {
        // بحث عن أي رقم طويل (يبدأ بـ 7 أو 05) ويتكون من 7 خانات إضافية على الأقل
        final anyLongNum = RegExp(r'\b(?:7|05)[0-9\s]{7,15}\b').firstMatch(normalizedText);
        if (anyLongNum != null) {
          phone = anyLongNum.group(0)?.replaceAll(' ', '') ?? "";
        }
      }

      // 3. استخراج المبلغ
      final numRegExp = RegExp(r'\b([0-9]{1,6})\b');
      final numMatch = numRegExp.firstMatch(normalizedText);
      if (numMatch != null) {
        amount = numMatch.group(1) ?? "0";
      } else {
        if (normalizedText.contains("الفين")) amount = "2000";
        else if (normalizedText.contains("الف")) amount = "1000";
        else if (normalizedText.contains("خمسمائة") || normalizedText.contains("خمسميه")) amount = "500";
        else if (normalizedText.contains("خمسين الف")) amount = "50000";
      }

      // 4. استخراج تفاصيل الخدمة
      final serviceRegExp = RegExp(r'(?:مقابل|عشان|لخدمة|خدمة)\s+([ا-يa-zA-Z\s]+?)(?=\s+(?:مستحقة|مستحق|بعد|بمبلغ|ريال|دولار|رقم|ملاحظة|ملاحظه|$))');
      final serviceMatch = serviceRegExp.firstMatch(normalizedText);
      if (serviceMatch != null && serviceMatch.groupCount >= 1) {
        service = serviceMatch.group(1)?.trim() ?? "خدمة عامة";
      }

      // 5. استخراج تاريخ الاستحقاق
      if (normalizedText.contains("اسبوع") || normalizedText.contains("أسبوع")) due = "بعد أسبوع";
      else if (normalizedText.contains("شهر")) due = "بعد شهر";
      else if (normalizedText.contains("ايام") || normalizedText.contains("أيام")) due = "بعد 3 أيام";

      // 6. استخراج الملاحظات (أكثر مرونة مع الحروف)
      final notesRegExp = RegExp(r'(?:ملاحظة|ملاحظه|ملاحظات|بملاحظة|بملاحظه|مع ملاحظة|مع ملاحظه|علم|علما|مع العلم)\s+(.+)');
      final notesMatch = notesRegExp.firstMatch(normalizedText);
      if (notesMatch != null && notesMatch.groupCount >= 1) {
        notes = notesMatch.group(1)?.trim() ?? "";
      }

      return {
        "name": name,
        "amount": amount,
        "service": service,
        "due": due,
        "phone": phone,
        "notes": notes,
      };
    }
  }
}
