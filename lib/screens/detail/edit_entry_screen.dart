import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/entry_detail.dart';
import '../../providers/entry_provider.dart';
import '../../widgets/entry_form.dart';

class EditEntryScreen extends StatefulWidget {
  const EditEntryScreen({super.key, required this.dateKey});
  final String dateKey;
  @override
  State<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  late final Future<EntryDetail?> detail = context.read<EntryProvider>().detail(
    widget.dateKey,
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Edit Catatan')),
    body: FutureBuilder<EntryDetail?>(
      future: detail,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: Text('Gagal memuat catatan'));
        }
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            EntryForm(
              dateKey: widget.dateKey,
              initial: snapshot.data,
              onSaved: () => Navigator.pop(context),
            ),
          ],
        );
      },
    ),
  );
}
