import 'package:flutter/material.dart';
import 'package:ramadan_assistant/core/services/quran_database_service.dart';
import 'package:ramadan_assistant/presentation/screens/quran_screen/quran_screen.dart';

class DownloadQuranScreen extends StatefulWidget {
  const DownloadQuranScreen({super.key});

  @override
  State<DownloadQuranScreen> createState() => _DownloadQuranScreenState();
}

class _DownloadQuranScreenState extends State<DownloadQuranScreen> {
  bool _isDownloading = false;
  double _progress = 0.0;
  String _status =
      'الرجاء تنزيل المصحف أول مرة فقط'; // Please download the Mushaf for the first time only

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _status = 'جاري التنزيل...'; // Downloading...
    });

    try {
      await QuranDatabaseService.instance.downloadDatabase((progress) {
        setState(() {
          _progress = progress;
        });
      });

      if (mounted) {
        // Navigate to the actual Quran screen once download finishes and replace this screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const QuranScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _progress = 0.0;
        _status = 'حدث خطأ: ${e.toString()}'; // Error downloading with details
      });
      debugPrint('Error downloading database: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'المصحف الشريف',
          style: TextStyle(fontFamily: 'Amiri'),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              const Icon(
                Icons.menu_book_rounded,
                size: 100,
                color: Colors.teal,
              ),
              const SizedBox(height: 24),
              Text(
                _status,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_isDownloading) ...[
                LinearProgressIndicator(
                  value: _progress,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 16),
                Text(
                  '${(_progress * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: _startDownload,
                  icon: const Icon(Icons.download),
                  label: const Text(
                    'تنزيل المصحف',
                    style: TextStyle(fontSize: 18, fontFamily: 'Amiri'),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ]]),
              
            ),
          ),
        ),
    );
  }
}
