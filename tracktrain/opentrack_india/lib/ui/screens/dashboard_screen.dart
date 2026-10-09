import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ist_clock.dart';
import '../../data/models/hive_records.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../providers.dart';
import '../widgets/common.dart';
import '../widgets/stat_card.dart';
import '../widgets/weekly_bar_chart.dart';

/// Tab 4: My Travel & Usage Dashboard — every number on this screen comes
/// from local Hive boxes; the banner states the guarantee explicitly.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final totals = ref.watch(dashboardTotalsProvider);
    final weekly = ref.watch(weeklyDistanceProvider);
    final trips = ref.watch(tripsProvider);
    final scheme = Theme.of(context).colorScheme;

    final usageSeconds = totals.offlineSeconds + totals.onlineSeconds;
    final offlinePct = usageSeconds == 0
        ? 0
        : (totals.offlineSeconds * 100 / usageSeconds).round();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.lock_outline,
                  size: 18, color: scheme.onTertiaryContainer),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.localOnlyNote,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onTertiaryContainer,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.straighten,
                label: l10n.totalDistance,
                value: '${totals.totalDistanceKm.toStringAsFixed(1)} km',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                icon: Icons.speed,
                label: l10n.avgSpeed,
                value: '${totals.averageSpeedKmh.round()} km/h',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.flash_on,
                label: l10n.topSpeed,
                value: '${totals.topSpeedKmh.round()} km/h',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                icon: Icons.timer_outlined,
                label: l10n.travelTime,
                value: IstClock.formatDuration(
                  Duration(minutes: totals.travelMinutes),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.login,
                label: l10n.sessions,
                value: '${totals.sessions}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                icon: Icons.smartphone,
                label: l10n.screenTime,
                value: IstClock.formatDuration(totals.screenTime),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.data_saver_off,
                label: l10n.dataSaved,
                value: totals.dataSavedDisplay,
                caption: '${totals.searches} searches',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                icon: Icons.offline_bolt_outlined,
                label: l10n.offlineUsage,
                value: '$offlinePct%',
                caption: l10n.onlineUsage,
              ),
            ),
          ],
        ),
        SectionHeader(title: l10n.weeklyTravel),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: WeeklyBarChart(data: weekly),
          ),
        ),
        SectionHeader(title: l10n.tripHistory),
        if (trips.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text(l10n.noTrips)),
          )
        else
          for (final trip in trips) _TripTile(trip: trip),
      ],
    );
  }
}

class _TripTile extends ConsumerWidget {
  const _TripTile({required this.trip});

  final TripRecord trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(trip.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
      ),
      onDismissed: (_) =>
          ref.read(appServicesProvider).analytics.deleteTrip(trip.id),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.train, size: 18, color: scheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      trip.routeLabel,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    IstClock.formatDate(trip.startedAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (trip.trainNumber.isNotEmpty)
                Text(
                  '${trip.trainNumber} · ${trip.trainName}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  Text(
                    '${trip.distanceKm.toStringAsFixed(1)} km',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    IstClock.formatDuration(
                      Duration(minutes: trip.durationMinutes),
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '${l10n.topSpeed}: ${trip.topSpeedKmh.round()} km/h',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (trip.departureDelayMinutes != 0 ||
                      trip.arrivalDelayMinutes != 0)
                    Text(
                      'Dep +${trip.departureDelayMinutes}m · '
                      'Arr +${trip.arrivalDelayMinutes}m',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.error,
                          ),
                    ),
                  Icon(
                    trip.trackedOnline ? Icons.wifi : Icons.wifi_off,
                    size: 14,
                    color: scheme.outline,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
