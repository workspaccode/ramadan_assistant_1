import 'dart:isolate';

void main() async {
  final uri = await Isolate.resolvePackageUri(
    Uri.parse('package:quran/quran.dart'),
  );
  // ignore: avoid_print
  print(uri);
}
