import 'package:flutter/material.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/persistence/document_store.dart';
import 'package:ramadan_assistant/presentation/widgets/sakina_ui.dart';

class LocalDataScreen extends StatefulWidget {
  const LocalDataScreen({super.key, required this.store});
  final DocumentStore store;
  @override
  State<LocalDataScreen> createState() => _LocalDataScreenState();
}

class _LocalDataScreenState extends State<LocalDataScreen> {
  late Future<List<StoredDocument>> _pending = widget.store.pendingSync();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.loc.features_local_data)),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SakinaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.phone_android_outlined,
                  color: context.primaryColor,
                  size: 32,
                ),
                const SizedBox(height: 16),
                Text(
                  context.loc.features_on_device,
                  style: context.textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(context.loc.features_local_intro),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FutureBuilder<List<StoredDocument>>(
            future: _pending,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const LinearProgressIndicator();
              }
              if (snapshot.hasError) {
                return Column(
                  children: [
                    Text(context.loc.features_action_failed),
                    TextButton(
                      onPressed: () =>
                          setState(() => _pending = widget.store.pendingSync()),
                      child: Text(context.loc.retry),
                    ),
                  ],
                );
              }
              return SakinaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${snapshot.data!.length}',
                      style: context.textTheme.headlineMedium,
                    ),
                    Text(context.loc.features_pending_label),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}
