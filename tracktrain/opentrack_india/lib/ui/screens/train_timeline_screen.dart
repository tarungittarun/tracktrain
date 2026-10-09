import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/train.dart';
import '../../data/models/train_stop.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../providers.dart';
import '../../services/live_data_service.dart';
import '../widgets/common.dart';

/// Full route timeline for one train, with the optional live hybrid overlay
/// (falls back to the offline schedule whenever the endpoint is unset or
/// unreachable).
class TrainTimelineScreen extends ConsumerWidget {
  const TrainTimelineScreen({super.key, required this.trainNumber});

  final String trainNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final services = ref.watch(appServicesProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(trainNumber)),
      body: FutureBuilder(
        future: Future.wait<Object?>([
          services.trains.getByNumber(trainNumber),
          services.trains.getSchedule(trainNumber),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final train = snapshot.data![0] as Train?;
          final stops = snapshot.data![1] as List<TrainStop>;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (train != null) ...[
                Text(
                  train.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  '${train.routeLabel} · ${train.daysSummary} · ${train.type}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 12),
                _LiveStatusRow(
                  trainNumber: trainNumber,
                  endpoint: settings.liveEndpoint,
                ),
              ],
              SectionHeader(title: l10n.trainSchedule),
              _Timeline(stops: stops, compact: settings.compactTimeline),
            ],
          );
        },
      ),
    );
  }
}

class _LiveStatusRow extends StatefulWidget {
  const _LiveStatusRow({required this.trainNumber, required this.endpoint});

  final String trainNumber;
  final String endpoint;

  @override
  State<_LiveStatusRow> createState() => _LiveStatusRowState();
}

class _LiveStatusRowState extends State<_LiveStatusRow> {
  late Future<LiveTrainStatus?> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  @override
  void didUpdateWidget(_LiveStatusRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endpoint != widget.endpoint ||
        oldWidget.trainNumber != widget.trainNumber) {
      _future = _fetch();
    }
  }

  Future<LiveTrainStatus?> _fetch() {
    final services = ProviderScope.containerOf(context, listen: false)
        .read(appServicesProvider);
    if (!services.connectivity.isOnline) return Future.value(null);
    return services.liveRail.fetchTrainStatus(
      baseUrl: widget.endpoint,
      trainNumber: widget.trainNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        final status = snapshot.data;
        final hasLive = status != null;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: hasLive
                ? scheme.primaryContainer
                : scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                hasLive ? Icons.cloud_done : Icons.cloud_off,
                size: 18,
                color: hasLive
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasLive
                      ? '${l10n.onlineMode} · +${status.delayMinutes} min'
                          '${status.platform.isEmpty ? '' : ' · PF ${status.platform}'}'
                      : l10n.offlineMode,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: hasLive
                            ? scheme.onPrimaryContainer
                            : scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.stops, required this.compact});

  final List<TrainStop> stops;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < stops.length; i++)
              _StopRow(
                stop: stops[i],
                isFirst: i == 0,
                isLast: i == stops.length - 1,
                compact: compact,
                lineColor: scheme.primary,
                dotColor: scheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _StopRow extends StatelessWidget {
  const _StopRow({
    required this.stop,
    required this.isFirst,
    required this.isLast,
    required this.compact,
    required this.lineColor,
    required this.dotColor,
  });

  final TrainStop stop;
  final bool isFirst;
  final bool isLast;
  final bool compact;
  final Color lineColor;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 6,
                  color: isFirst ? Colors.transparent : lineColor,
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : lineColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: compact ? 6 : 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stop.stationName.isEmpty
                              ? stop.stationCode
                              : stop.stationName,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight:
                                    isFirst || isLast ? FontWeight.w800 : null,
                              ),
                        ),
                        if (!compact)
                          Text(
                            stop.stationCode,
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        stop.scheduleLine.isEmpty ? '—' : stop.scheduleLine,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                      ),
                      if (!compact)
                        Text(
                          '${stop.distanceKm.toStringAsFixed(0)} km',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: scheme.outline,
                                  ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
