import 'dart:isolate';

void main() async {
  final uri = await Isolate.resolvePackageUri(
    Uri.parse('package:flutter_quran_tajwid/screens/recitation_screen.dart'),
  );
  // ignore: avoid_print
  print(uri);
}
