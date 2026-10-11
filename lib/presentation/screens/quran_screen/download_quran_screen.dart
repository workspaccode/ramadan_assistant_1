import 'package:ramadan_assistant/presentation/widgets/sakina_ui.dart';
import 'package:flutter/material.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/services/quran_database_service.dart';
import 'package:ramadan_assistant/presentation/screens/quran_screen/quran_screen.dart';

class DownloadQuranScreen extends StatefulWidget {
  const DownloadQuranScreen({
    super.key,
    this.returnToCaller = false,
    this.downloadDatabase,
    this.seedTajweed,
  });
  final bool returnToCaller;
  final Future<void> Function(ValueChanged<double>)? downloadDatabase;
  final Future<void> Function(ValueChanged<double>)? seedTajweed;

  @override
  State<DownloadQuranScreen> createState() => _DownloadQuranScreenState();
}

class _DownloadQuranScreenState extends State<DownloadQuranScreen> {
  bool _isDownloading = false;
  double _progress = 0.0;
  bool _isPreparing = false;
  bool _hasError = false;

  void _onProgress(double progress) {
    if (!mounted) return;
    setState(
      () => _progress = progress.isFinite ? progress.clamp(0.0, 1.0) : 0,
    );
  }

  Future<void> _startDownload() async {
    if (_isDownloading) return;
    setState(() {
      _isDownloading = true;
      _isPreparing = false;
      _hasError = false;
      _progress = 0;
    });

    try {
      await (widget.downloadDatabase ??
          QuranDatabaseService.instance.downloadDatabase)(_onProgress);

      if (mounted) {
        setState(() {
          _progress = 0.0;
          _isPreparing = true;
        });
      }

      await (widget.seedTajweed ??
          QuranDatabaseService.instance.fetchAndSeedTajweedData)(_onProgress);

      if (mounted) {
        if (widget.returnToCaller) {
          Navigator.pop(context, true);
          return;
        }
        // Navigate to the actual Quran screen once download finishes and replace this screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const QuranScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _progress = 0.0;
          _hasError = true;
        });
      }
      debugPrint('Error downloading database: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const SakinaBottomBar(selectedIndex: 2),
      appBar: AppBar(title: Text('quran'.tr()), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 100,
                  color: context.primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  _hasError
                      ? 'error_occurred'.tr()
                      : _isPreparing
                      ? context.loc.ui_quran_preparing
                      : context.loc.ui_quran_download_prompt,
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
                    label: Text(
                      _hasError
                          ? 'retry'.tr()
                          : context.loc.ui_quran_download_action,
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      backgroundColor: context.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
