import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/geo_utils.dart';
import '../../data/models/station.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../providers.dart';
import '../widgets/common.dart';

/// Tab 2: Live Station — shows where you are right now (GPS fix or cell
/// tower estimate) and what is around: nearby stations and the trains that
/// halt at the closest one.
class LiveStationScreen extends ConsumerWidget {
  const LiveStationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.watch(trackingControllerProvider);
    final services = ref.watch(appServicesProvider);

    final Position? fix = services.tracker.lastPosition;
    final tower = controller.towerMatch;
    final double? lat = fix?.latitude ?? tower?.latitude;
    final double? lon = fix?.longitude ?? tower?.longitude;
    final bool fromGps = fix != null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  fromGps ? Icons.gps_fixed : Icons.cell_tower,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fromGps ? l10n.modeGps : l10n.cellFix,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        lat == null || lon == null
                            ? l10n.statusIdle
                            : '${lat.toStringAsFixed(4)}, '
                                '${lon.toStringAsFixed(4)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (tower != null) ...[
          SectionHeader(title: l10n.cellFix),
          Card(
            child: ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: Text(l10n.towerMatched),
              subtitle: Text(
                '${tower.stationCode} · ±${tower.accuracyMeters.round()} m',
              ),
            ),
          ),
        ] else if (!fromGps) ...[
          const SizedBox(height: 12),
          Text(
            l10n.noTowerMatch,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        SectionHeader(title: l10n.nearbyStations),
        if (lat == null || lon == null)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Center(child: Text(l10n.startTracking)),
          )
        else
          _NearbyStationList(lat: lat, lon: lon),
      ],
    );
  }
}

class _NearbyStationList extends ConsumerWidget {
  const _NearbyStationList({required this.lat, required this.lon});

  final double lat;
  final double lon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(appServicesProvider);

    return FutureBuilder(
      future: services.stations.nearestTo(lat, lon, limit: 10),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final stations = snapshot.data!;
        return Column(
          children: [
            for (final station in stations)
              _NearbyTile(
                station: station,
                distanceMeters: GeoUtils.haversineMeters(
                  lat,
                  lon,
                  station.latitude,
                  station.longitude,
                ),
                bearing: GeoUtils.bearingDegrees(
                  lat,
                  lon,
                  station.latitude,
                  station.longitude,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _NearbyTile extends StatelessWidget {
  const _NearbyTile({
    required this.station,
    required this.distanceMeters,
    required this.bearing,
  });

  final Station station;
  final double distanceMeters;
  final double bearing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => showStationDetails(context, station),
        leading: CircleAvatar(
          radius: 18,
          child: Text(
            station.code.length >= 2 ? station.code.substring(0, 2) : station.code,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(station.displayTitle),
        subtitle: Text(station.subtitle),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              GeoUtils.formatDistance(distanceMeters),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              GeoUtils.cardinal(bearing),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
