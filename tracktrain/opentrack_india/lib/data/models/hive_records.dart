import 'package:hive/hive.dart';

/// On-device-only analytics record for one tracked journey.
class TripRecord {
  TripRecord({
    required this.id,
    required this.startedAtMillis,
    required this.originCode,
    required this.originName,
    required this.destinationCode,
    required this.destinationName,
    this.trainNumber = '',
    this.trainName = '',
    this.distanceKm = 0.0,
    this.durationMinutes = 0,
    this.averageSpeedKmh = 0.0,
    this.topSpeedKmh = 0.0,
    this.departureDelayMinutes = 0,
    this.arrivalDelayMinutes = 0,
    this.trackedOnline = false,
  });

  final String id;
  final int startedAtMillis;
  final String originCode;
  final String originName;
  final String destinationCode;
  final String destinationName;
  final String trainNumber;
  final String trainName;
  final double distanceKm;
  final int durationMinutes;
  final double averageSpeedKmh;
  final double topSpeedKmh;
  final int departureDelayMinutes;
  final int arrivalDelayMinutes;
  final bool trackedOnline;

  DateTime get startedAt =>
      DateTime.fromMillisecondsSinceEpoch(startedAtMillis);

  String get routeLabel =>
      originCode.isEmpty && destinationCode.isEmpty
          ? 'Untracked route'
          : '${originCode.isEmpty ? '…' : originCode} → '
              '${destinationCode.isEmpty ? '…' : destinationCode}';
}

/// Aggregated per-day usage metrics; everything is accumulated locally and
/// never leaves the device.
class DailyUsage {
  DailyUsage({
    required this.dateKey,
    this.screenSeconds = 0,
    this.offlineSeconds = 0,
    this.onlineSeconds = 0,
    this.sessions = 0,
    this.searches = 0,
    this.dataSavedBytes = 0,
    this.distanceKm = 0.0,
    this.topSpeedKmh = 0.0,
  });

  /// `yyyy-MM-dd` in IST.
  final String dateKey;
  int screenSeconds;
  int offlineSeconds;
  int onlineSeconds;
  int sessions;
  int searches;
  int dataSavedBytes;
  double distanceKm;
  double topSpeedKmh;
}

/// A customizable quick-access card on the home screen.
class QuickCard {
  QuickCard({
    required this.typeIndex,
    required this.code,
    required this.title,
    this.subtitle = '',
  });

  final int typeIndex;
  final String code;
  final String title;
  final String subtitle;
}

/// Hand-written adapters (no codegen) keep the CI pipeline lean.
class TripRecordAdapter extends TypeAdapter<TripRecord> {
  @override
  final int typeId = 1;

  @override
  TripRecord read(BinaryReader reader) => TripRecord(
        id: reader.readString(),
        startedAtMillis: reader.readInt(),
        originCode: reader.readString(),
        originName: reader.readString(),
        destinationCode: reader.readString(),
        destinationName: reader.readString(),
        trainNumber: reader.readString(),
        trainName: reader.readString(),
        distanceKm: reader.readDouble(),
        durationMinutes: reader.readInt(),
        averageSpeedKmh: reader.readDouble(),
        topSpeedKmh: reader.readDouble(),
        departureDelayMinutes: reader.readInt(),
        arrivalDelayMinutes: reader.readInt(),
        trackedOnline: reader.readBool(),
      );

  @override
  void write(BinaryWriter writer, TripRecord obj) {
    writer
      ..writeString(obj.id)
      ..writeInt(obj.startedAtMillis)
      ..writeString(obj.originCode)
      ..writeString(obj.originName)
      ..writeString(obj.destinationCode)
      ..writeString(obj.destinationName)
      ..writeString(obj.trainNumber)
      ..writeString(obj.trainName)
      ..writeDouble(obj.distanceKm)
      ..writeInt(obj.durationMinutes)
      ..writeDouble(obj.averageSpeedKmh)
      ..writeDouble(obj.topSpeedKmh)
      ..writeInt(obj.departureDelayMinutes)
      ..writeInt(obj.arrivalDelayMinutes)
      ..writeBool(obj.trackedOnline);
  }
}

class DailyUsageAdapter extends TypeAdapter<DailyUsage> {
  @override
  final int typeId = 2;

  @override
  DailyUsage read(BinaryReader reader) => DailyUsage(
        dateKey: reader.readString(),
        screenSeconds: reader.readInt(),
        offlineSeconds: reader.readInt(),
        onlineSeconds: reader.readInt(),
        sessions: reader.readInt(),
        searches: reader.readInt(),
        dataSavedBytes: reader.readInt(),
        distanceKm: reader.readDouble(),
        topSpeedKmh: reader.readDouble(),
      );

  @override
  void write(BinaryWriter writer, DailyUsage obj) {
    writer
      ..writeString(obj.dateKey)
      ..writeInt(obj.screenSeconds)
      ..writeInt(obj.offlineSeconds)
      ..writeInt(obj.onlineSeconds)
      ..writeInt(obj.sessions)
      ..writeInt(obj.searches)
      ..writeInt(obj.dataSavedBytes)
      ..writeDouble(obj.distanceKm)
      ..writeDouble(obj.topSpeedKmh);
  }
}

class QuickCardAdapter extends TypeAdapter<QuickCard> {
  @override
  final int typeId = 3;

  @override
  QuickCard read(BinaryReader reader) => QuickCard(
        typeIndex: reader.readInt(),
        code: reader.readString(),
        title: reader.readString(),
        subtitle: reader.readString(),
      );

  @override
  void write(BinaryWriter writer, QuickCard obj) {
    writer
      ..writeInt(obj.typeIndex)
      ..writeString(obj.code)
      ..writeString(obj.title)
      ..writeString(obj.subtitle);
  }
}

/// Registers every adapter exactly once; call from `main()` before opening
/// boxes.
void registerHiveAdapters() {
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TripRecordAdapter());
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(DailyUsageAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(QuickCardAdapter());
}
