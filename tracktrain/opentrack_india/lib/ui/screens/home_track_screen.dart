import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/enums.dart';
import '../../core/geo_utils.dart';
import '../../core/ist_clock.dart';
import '../../data/models/hive_records.dart';
import '../../data/models/station.dart';
import '../../data/models/train.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../providers.dart';
import '../../services/tracking_controller.dart';
import '../widgets/analog_speedometer.dart';
import '../widgets/common.dart';
import 'train_timeline_screen.dart';

/// Tab 1: Search/Track — tracking engine, live speedometer, destination
/// alarm and customizable quick-access cards.
class HomeTrackScreen extends ConsumerWidget {
  const HomeTrackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.watch(trackingControllerProvider);
    final settings = ref.watch(settingsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _StatusHeader(isActive: controller.isSessionActive),
        const SizedBox(height: 12),
        _QuickAccessRow(),
        SectionHeader(
          title: l10n.startTracking,
          trailing: const IstClockTicker(),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<TrackingModeChoice>(
                  segments: [
                    ButtonSegment(
                      value: TrackingModeChoice.auto,
                      label: Text(l10n.modeAuto),
                      icon: const Icon(Icons.smart_toy_outlined, size: 18),
                    ),
                    ButtonSegment(
                      value: TrackingModeChoice.gpsOnly,
                      label: Text(l10n.modeGps),
                      icon: const Icon(Icons.gps_fixed, size: 18),
                    ),
                    ButtonSegment(
                      value: TrackingModeChoice.cellOnly,
                      label: Text(l10n.modeCell),
                      icon: const Icon(Icons.cell_tower, size: 18),
                    ),
                  ],
                  selected: {settings.trackingMode},
                  onSelectionChanged: (selection) =>
                      settings.trackingMode = selection.first,
                ),
                const SizedBox(height: 16),
                if (controller.isSessionActive) ...[
                  AnalogSpeedometer(
                    speedKmh: controller.speedKmh,
                    unit: settings.speedUnit,
                  ),
                  const SizedBox(height: 8),
                  _SessionStats(controller: controller),
                ],
                const SizedBox(height: 12),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: Icon(
                    controller.isSessionActive
                        ? Icons.stop
                        : Icons.play_arrow,
                  ),
                  label: Text(
                    controller.isSessionActive
                        ? l10n.stopTracking
                        : l10n.startTracking,
                  ),
                  onPressed: () => _toggleTracking(context, ref),
                ),
              ],
            ),
          ),
        ),
        SectionHeader(title: l10n.destinationAlarm),
        const _DestinationAlarmCard(),
        if (controller.towerMatch != null) ...[
          SectionHeader(title: l10n.cellFix),
          Card(
            child: ListTile(
              leading: const Icon(Icons.cell_tower),
              title: Text(l10n.towerMatched),
              subtitle: Text(
                '${controller.towerMatch!.stationCode} · '
                '±${controller.towerMatch!.accuracyMeters.round()} m',
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _toggleTracking(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(trackingControllerProvider);
    final l10n = AppLocalizations.of(context);
    if (controller.isSessionActive) {
      await controller.stopSession();
      return;
    }
    final started = await controller.startSession();
    if (!started && context.mounted) {
      final tracker = ref.read(appServicesProvider).tracker;
      final message = switch (tracker.status) {
        TrackingStatus.permissionDenied => l10n.statusDenied,
        TrackingStatus.serviceDisabled => l10n.statusServiceOff,
        _ => l10n.statusServiceOff,
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
      ));
    }
  }
}

class _StatusHeader extends ConsumerWidget {
  const _StatusHeader({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tracker = ref.watch(appServicesProvider).tracker;
    ref.watch(trackingControllerProvider);

    final (icon, label) = switch (tracker.status) {
      TrackingStatus.idle => (Icons.check_circle_outline, l10n.statusIdle),
      TrackingStatus.acquiring => (Icons.satellite_alt, l10n.statusAcquiring),
      TrackingStatus.tracking => (Icons.navigation, l10n.statusTracking),
      TrackingStatus.permissionDenied => (Icons.lock, l10n.statusDenied),
      TrackingStatus.serviceDisabled =>
        (Icons.location_off, l10n.statusServiceOff),
    };

    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? scheme.primaryContainer : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isActive ? scheme.onPrimaryContainer : scheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isActive
                        ? scheme.onPrimaryContainer
                        : scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionStats extends StatelessWidget {
  const _SessionStats({required this.controller});

  final TrackingController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = [
      (Icons.straighten, GeoUtils.formatDistance(controller.distanceKm * 1000)),
      (Icons.speed, '${controller.topSpeedKmh.round()} km/h'),
      (
        Icons.near_me,
        controller.nearestStation?.code ?? '—',
      ),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Icon(items[i].$1, size: 16, color: scheme.primary),
                  const SizedBox(height: 4),
                  Text(
                    items[i].$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DestinationAlarmCard extends ConsumerStatefulWidget {
  const _DestinationAlarmCard();

  @override
  ConsumerState<_DestinationAlarmCard> createState() =>
      _DestinationAlarmCardState();
}

class _DestinationAlarmCardState extends ConsumerState<_DestinationAlarmCard> {
  double _leadKm = 5;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.watch(trackingControllerProvider);
    final armed = controller.alarmConfig;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: armed == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.chooseDestination),
                  const SizedBox(height: 10),
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.search),
                    label: Text(l10n.chooseDestination),
                    onPressed: () => _pickAndArm(context),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.alarm,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${l10n.alarmArmed}: ${armed.destination.name}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _ArmedEtaLine(controller: controller),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.alarm_off),
                    label: Text(l10n.disarmAlarm),
                    onPressed: () => controller.disarmDestinationAlarm(),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _pickAndArm(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final station = await showStationPicker(context);
    if (station == null || !context.mounted) return;

    final lead = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.alertLead),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in const [5.0, 10.0])
                ListTile(
                  leading: const Icon(Icons.notifications_active_outlined),
                  title: Text('${option.round()} km'),
                  onTap: () => Navigator.of(dialogContext).pop(option),
                ),
            ],
          ),
        );
      },
    );
    if (lead == null || !context.mounted) return;

    setState(() => _leadKm = lead);
    await ref
        .read(trackingControllerProvider)
        .armDestinationAlarm(station, leadKm: _leadKm);
  }
}

class _ArmedEtaLine extends ConsumerWidget {
  const _ArmedEtaLine({required this.controller});

  final TrackingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final remaining = controller.remainingMeters;
    final eta = controller.eta;

    if (remaining == null) {
      return Text(
        '${l10n.alertLead}: ${controller.alarmConfig?.leadLabel ?? '—'}',
        style: TextStyle(color: scheme.onSurfaceVariant),
      );
    }
    return Row(
      children: [
        Expanded(
          child: Text(
            '${l10n.remaining}: ${GeoUtils.formatDistance(remaining)}',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ),
        Text(
          '${l10n.eta}: ${eta == null ? '—' : IstClock.formatTime(eta)}',
          style: TextStyle(
            color: scheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _QuickAccessRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final services = ref.watch(appServicesProvider);

    return ValueListenableBuilder(
      valueListenable: services.quickCardsBox.listenable(),
      builder: (context, box, _) {
        final cards = {
          for (final card in box.values) card.typeIndex: card,
        };
        return SizedBox(
          height: 108,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _QuickCardTile(
                icon: Icons.home_outlined,
                title: l10n.homeStation,
                card: cards[QuickCardType.homeStation.index],
                onTap: () => _configure(
                  context,
                  ref,
                  type: QuickCardType.homeStation,
                ),
                onOpen: (card) => _openHomeStation(context, ref, card),
              ),
              _QuickCardTile(
                icon: Icons.train_outlined,
                title: l10n.frequentTrain,
                card: cards[QuickCardType.frequentTrain.index],
                onTap: () => _configure(
                  context,
                  ref,
                  type: QuickCardType.frequentTrain,
                ),
                onOpen: (card) => _openFrequentTrain(context, card),
              ),
              _QuickCardTile(
                icon: Icons.bookmark_outline,
                title: l10n.savedRoute,
                card: cards[QuickCardType.savedRoute.index],
                onTap: () => _configure(
                  context,
                  ref,
                  type: QuickCardType.savedRoute,
                ),
                onOpen: (card) => _openSavedRoute(context, ref, card),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _configure(
    BuildContext context,
    WidgetRef ref, {
    required QuickCardType type,
  }) async {
    final services = ref.read(appServicesProvider);
    final l10n = AppLocalizations.of(context);
    final pickTrain = type == QuickCardType.frequentTrain;

    Station? station;
    Train? train;
    if (pickTrain) {
      train = await showTrainPicker(context);
    } else {
      station = await showStationPicker(context);
    }

    QuickCard? card;
    if (type == QuickCardType.frequentTrain) {
      if (train == null) return;
      card = QuickCard(
        typeIndex: type.index,
        code: train.number,
        title: train.name,
        subtitle: train.routeLabel,
      );
    } else {
      if (station == null) return;
      card = QuickCard(
        typeIndex: type.index,
        code: station.code,
        title: station.name,
        subtitle: type == QuickCardType.savedRoute
            ? l10n.destinationAlarm
            : station.subtitle,
      );
    }
    await services.quickCardsBox.put(type.index, card);
  }

  Future<void> _openHomeStation(
    BuildContext context,
    WidgetRef ref,
    QuickCard card,
  ) async {
    final services = ref.read(appServicesProvider);
    final station = await services.stations.getByCode(card.code);
    if (station != null && context.mounted) {
      await showStationDetails(context, station);
    }
  }

  void _openFrequentTrain(BuildContext context, QuickCard card) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TrainTimelineScreen(trainNumber: card.code),
      ),
    );
  }

  Future<void> _openSavedRoute(
    BuildContext context,
    WidgetRef ref,
    QuickCard card,
  ) async {
    final services = ref.read(appServicesProvider);
    final station = await services.stations.getByCode(card.code);
    if (station == null || !context.mounted) return;
    await ref
        .read(trackingControllerProvider)
        .armDestinationAlarm(station, leadKm: 5);
  }
}

class _QuickCardTile extends StatelessWidget {
  const _QuickCardTile({
    required this.icon,
    required this.title,
    required this.card,
    required this.onTap,
    required this.onOpen,
  });

  final IconData icon;
  final String title;
  final QuickCard? card;
  final VoidCallback onTap;
  final void Function(QuickCard card) onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final configured = card != null;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: configured
            ? scheme.secondaryContainer
            : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: configured ? () => onOpen(card!) : onTap,
          onLongPress: onTap,
          child: SizedBox(
            width: 150,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        size: 18,
                        color: configured
                            ? scheme.onSecondaryContainer
                            : scheme.primary,
                      ),
                      const Spacer(),
                      Icon(
                        configured ? Icons.edit : Icons.add,
                        size: 14,
                        color: configured
                            ? scheme.onSecondaryContainer
                            : scheme.outline,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: configured
                              ? scheme.onSecondaryContainer
                              : scheme.onSurfaceVariant,
                        ),
                  ),
                  Text(
                    configured ? card!.title : '—',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: configured
                              ? scheme.onSecondaryContainer
                              : scheme.onSurface,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-screen station picker with typo-tolerant live search.
Future<Station?> showStationPicker(BuildContext context) {
  return showModalBottomSheet<Station>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => const _StationPickerSheet(),
  );
}

Future<Train?> showTrainPicker(BuildContext context) {
  return showModalBottomSheet<Train>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => const _TrainPickerSheet(),
  );
}

class _StationPickerSheet extends ConsumerStatefulWidget {
  const _StationPickerSheet();

  @override
  ConsumerState<_StationPickerSheet> createState() =>
      _StationPickerSheetState();
}

class _StationPickerSheetState extends ConsumerState<_StationPickerSheet> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      setState(() => _query = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final results = ref.watch(stationSearchProvider(_query));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onChanged: _onChanged,
              ),
            ),
            Expanded(
              child: results.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(child: Text(l10n.noResults)),
                data: (stations) {
                  if (stations.isEmpty) {
                    return Center(child: Text(l10n.noResults));
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: stations.length,
                    itemBuilder: (context, index) {
                      final station = stations[index];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 18,
                          child: Text(
                            station.code.characters.take(2).toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        title: Text(station.displayTitle),
                        subtitle: Text(station.subtitle),
                        onTap: () => Navigator.of(context).pop(station),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TrainPickerSheet extends ConsumerStatefulWidget {
  const _TrainPickerSheet();

  @override
  ConsumerState<_TrainPickerSheet> createState() => _TrainPickerSheetState();
}

class _TrainPickerSheetState extends ConsumerState<_TrainPickerSheet> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      setState(() => _query = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final results = ref.watch(trainSearchProvider(_query));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onChanged: _onChanged,
              ),
            ),
            Expanded(
              child: results.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(child: Text(l10n.noResults)),
                data: (trains) {
                  if (trains.isEmpty || _query.isEmpty) {
                    return Center(child: Text(l10n.noResults));
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: trains.length,
                    itemBuilder: (context, index) {
                      final train = trains[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          radius: 18,
                          child: Icon(Icons.train, size: 18),
                        ),
                        title: Text('${train.number} · ${train.name}'),
                        subtitle: Text(train.routeLabel),
                        onTap: () => Navigator.of(context).pop(train),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
