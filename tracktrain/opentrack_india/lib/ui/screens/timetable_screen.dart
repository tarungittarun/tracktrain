import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/models/station.dart';
import '../../data/models/train.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../providers.dart';
import '../widgets/common.dart';
import 'train_timeline_screen.dart';

enum _SearchScope { stations, trains }

/// Tab 3: Offline Timetable — typo-tolerant FTS5 search over the bundled
/// dataset, fully functional in airplane mode.
class TimetableScreen extends ConsumerStatefulWidget {
  const TimetableScreen({super.key});

  @override
  ConsumerState<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends ConsumerState<TimetableScreen> {
  final TextEditingController _controller = TextEditingController();
  _SearchScope _scope = _SearchScope.stations;
  String _query = '';
  Timer? _debounce;
  bool _counted = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final trimmed = value.trim();
      setState(() => _query = trimmed);
      if (trimmed.isNotEmpty && !_counted) {
        _counted = true;
        ref.read(appServicesProvider).analytics.recordSearch();
      }
      if (trimmed.isEmpty) _counted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        setState(() => _query = '');
                      },
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onChanged: _onChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<_SearchScope>(
                  segments: [
                    ButtonSegment(
                      value: _SearchScope.stations,
                      label: Text(l10n.searchStations),
                    ),
                    ButtonSegment(
                      value: _SearchScope.trains,
                      label: Text(l10n.searchTrains),
                    ),
                  ],
                  selected: {_scope},
                  onSelectionChanged: (selection) =>
                      setState(() => _scope = selection.first),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _scope == _SearchScope.stations
              ? _StationResults(query: _query)
              : _TrainResults(query: _query),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: _DatasetFooter(),
        ),
      ],
    );
  }
}

class _StationResults extends ConsumerWidget {
  const _StationResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final results = ref.watch(stationSearchProvider(query));

    return results.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(child: Text(l10n.noResults)),
      data: (stations) {
        if (stations.isEmpty) return Center(child: Text(l10n.noResults));
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: stations.length,
          itemBuilder: (context, index) =>
              _StationTile(station: stations[index]),
        );
      },
    );
  }
}

class _StationTile extends StatelessWidget {
  const _StationTile({required this.station});

  final Station station;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => showStationDetails(context, station),
        leading: CircleAvatar(
          radius: 18,
          child: Text(
            station.code.length >= 2
                ? station.code.substring(0, 2)
                : station.code,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(station.displayTitle),
        subtitle: Text(station.subtitle),
        trailing: Text(
          station.code,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _TrainResults extends ConsumerWidget {
  const _TrainResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final results = ref.watch(trainSearchProvider(query));

    return results.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(child: Text(l10n.noResults)),
      data: (trains) {
        if (trains.isEmpty || query.isEmpty) {
          return Center(child: Text(l10n.noResults));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: trains.length,
          itemBuilder: (context, index) => _TrainTile(train: trains[index]),
        );
      },
    );
  }
}

class _TrainTile extends StatelessWidget {
  const _TrainTile({required this.train});

  final Train train;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => TrainTimelineScreen(trainNumber: train.number),
            ),
          );
        },
        leading: const CircleAvatar(
          radius: 18,
          child: Icon(Icons.train, size: 18),
        ),
        title: Text('${train.number} · ${train.name}'),
        subtitle: Text('${train.routeLabel} · ${train.daysSummary}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: scheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            train.type,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

class _DatasetFooter extends StatefulWidget {
  const _DatasetFooter();

  @override
  State<_DatasetFooter> createState() => _DatasetFooterState();
}

class _DatasetFooterState extends State<_DatasetFooter> {
  @override
  void initState() {
    super.initState();
    unawaited(AppDatabase.instance.ensureReady().then((_) {
      if (mounted) setState(() {});
    }));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final db = AppDatabase.instance;
    return Center(
      child: Text(
        l10n.datasetInfo(
          db.stationCount.toString(),
          db.trainCount.toString(),
        ),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}
