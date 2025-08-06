import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const SmartCodeApp());
}

class SmartCodeApp extends StatelessWidget {
  const SmartCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Code',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.promptTextTheme(),
        primaryColor: const Color(0xFFD87F3D),
        scaffoldBackgroundColor: const Color(0xFFF6E7D7),
      ),
      home: const HomePage(),
    );
  }
}

// ============================ หน้าแรก ============================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(80),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(80),
                  child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScannerPage()),
                );
              },
              icon: const Icon(Icons.qr_code_scanner, size: 32),
              label: const Text(
                'เริ่มสแกนบาร์โค้ด',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD87F3D),
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 10,
                shadowColor: Colors.brown.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================ ข้อมูลโปรโมชั่น ============================
class PromotionData {
  final String title;
  final String description;
  final String imageUrl;
  final String priceInfo;

  PromotionData({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.priceInfo,
  });
}

final Map<String, PromotionData> promotions = {
  '8850779559955': PromotionData(
    title: 'น้ำแร่ Aura ขวด 1.5 ลิตร',
    description:
        'น้ำแร่ธรรมชาติ 100% จากขุนเขา\nไม่มีการเติมแต่งหรือผ่านกระบวนการทางเคมี\nแร่ธาตุจำเป็นต่อร่างกาย สะอาด ปลอดภัย',
    imageUrl: 'assets/aura_promo.png',
    priceInfo: '2 ขวดเพียง 35 บาท (จากปกติ 46 บาท)',
  ),
};

// ============================ หน้าสแกนบาร์โค้ด ============================
class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final MobileScannerController cameraController = MobileScannerController();
  bool isProcessing = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void handleBarcodeDetected(BarcodeCapture barcodeCapture) {
    if (isProcessing) return;

    final String? code = barcodeCapture.barcodes.first.rawValue;
    if (code != null && code.isNotEmpty) {
      isProcessing = true;
      cameraController.stop();

      if (promotions.containsKey(code)) {
        final promo = promotions[code]!;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PromotionPage(promo: promo)),
        );
      } else {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('ไม่พบโปรโมชั่น'),
            content: Text('รหัส: $code\nยังไม่มีข้อมูลโปรโมชั่นในระบบ'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ตกลง'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileScanner(
        controller: cameraController,
        onDetect: handleBarcodeDetected,
      ),
    );
  }
}

// ============================ หน้าข้อมูลโปรโมชั่น ============================
class PromotionPage extends StatelessWidget {
  final PromotionData promo;

  const PromotionPage({Key? key, required this.promo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(promo.title),
        backgroundColor: const Color(0xFFD87F3D),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset(promo.imageUrl),
            const SizedBox(height: 16),
            Text(
              promo.priceInfo,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(promo.description, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
