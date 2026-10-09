import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ist_clock.dart';
import '../../data/models/station.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../providers.dart';

/// Section heading used across screens.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 20, 2, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Live IST clock chip; also surfaces the GPS clock-correction badge when the
/// device clock had to be corrected against satellite time.
class IstClockTicker extends StatefulWidget {
  const IstClockTicker({super.key});

  @override
  State<IstClockTicker> createState() => _IstClockTickerState();
}

class _IstClockTickerState extends State<IstClockTicker> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final now = IstClock.correctedNow();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final ss = now.second.toString().padLeft(2, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.access_time, size: 14, color: scheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          '$hh:$mm:$ss IST',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
                color: scheme.onSurfaceVariant,
              ),
        ),
        if (IstClock.hasGpsCorrection) ...[
          const SizedBox(width: 8),
          Tooltip(
            message: l10n.gpsCorrection,
            child: Icon(
              Icons.satellite_alt,
              size: 14,
              color: scheme.tertiary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Offline/Online pill shown in the app bar.
class ConnectivityBadge extends ConsumerWidget {
  const ConnectivityBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(isOnlineProvider);
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final background =
        online ? scheme.secondaryContainer : scheme.errorContainer;
    final foreground = online ? scheme.onSecondaryContainer : scheme.onErrorContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(online ? Icons.wifi : Icons.wifi_off, size: 14, color: foreground),
          const SizedBox(width: 5),
          Text(
            online ? l10n.onlineMode : l10n.offlineMode,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet with station metadata plus the trains that halt there —
/// the reusable detail view for stations.
Future<void> showStationDetails(
  BuildContext context,
  Station station,
) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Consumer(
            builder: (context, ref, _) {
              final services = ref.watch(appServicesProvider);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.displayTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      station.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${station.latitude.toStringAsFixed(4)}, '
                      '${station.longitude.toStringAsFixed(4)}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    SectionHeader(title: l10n.trainsHaltHere),
                    Expanded(
                      child: FutureBuilder(
                        future: services.trains.trainsStoppingAt(station.code),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final trains = snapshot.data!;
                          if (trains.isEmpty) {
                            return Center(child: Text(l10n.noResults));
                          }
                          return ListView.separated(
                            controller: scrollController,
                            itemCount: trains.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final train = trains[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                  radius: 18,
                                  child: Icon(Icons.train, size: 18),
                                ),
                                title: Text('${train.number} · ${train.name}'),
                                subtitle: Text(train.routeLabel),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}
