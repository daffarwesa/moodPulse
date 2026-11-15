import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_helper.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/entry_detail.dart';
import '../../providers/entry_provider.dart';
import '../../widgets/entry_form.dart';
import '../../widgets/stats_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.active, required this.onNavigate});
  final bool active;
  final ValueChanged<int> onNavigate;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String today = DateHelper.key(DateTime.now());
  int revision = 0;
  late Future<EntryDetail?> currentEntry;

  @override
  void initState() {
    super.initState();
    currentEntry = context.read<EntryProvider>().detail(today);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.active && widget.active) {
      today = DateHelper.key(DateTime.now());
      revision++;
      currentEntry = context.read<EntryProvider>().detail(today);
    }
  }

  void reload() {
    setState(() {
      today = DateHelper.key(DateTime.now());
      revision++;
      currentEntry = context.read<EntryProvider>().detail(today);
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = DateHelper.key(DateTime.now());
    if (today != current) {
      today = current;
      currentEntry = context.read<EntryProvider>().detail(today);
      revision++;
    }
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await context.read<EntryProvider>().refresh();
          if (mounted) reload();
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
          children: [
            Text(
              DateHelper.full(today),
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.outline,
              ),
            ),
            const SizedBox(height: 4),
            const Text('Bagaimana harimu?', style: AppTextStyles.headlineLarge),
            const SizedBox(height: 16),
            FutureBuilder<EntryDetail?>(
              key: ValueKey('$today-$revision'),
              future: currentEntry,
              builder: (context, snapshot) {
                if (!snapshot.hasData &&
                    snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Gagal memuat catatan hari ini'),
                  );
                }
                return EntryForm(
                  key: ValueKey(
                    '$today-$revision-${snapshot.data?.entry.updatedAt}',
                  ),
                  dateKey: today,
                  initial: snapshot.data,
                  showHeader: false,
                  onSaved: reload,
                  onManage: () => widget.onNavigate(2),
                );
              },
            ),
            const SizedBox(height: 16),
            const StatsCard(),
          ],
        ),
      ),
    );
  }
}
