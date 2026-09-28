import 'package:hive/hive.dart';

part 'offline_alert_queue.g.dart';

@HiveType(typeId: 0)
class QueuedAlert extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userName;

  @HiveField(2)
  String phone;

  @HiveField(3)
  double? latitude;

  @HiveField(4)
  double? longitude;

  @HiveField(5)
  int startedAt;

  @HiveField(6)
  List<String> guardianNumbers;

  @HiveField(7)
  bool synced;

  @HiveField(8)
  List<String> pendingSmsNumbers;

  @HiveField(9)
  String smsMessage;

  QueuedAlert({
    required this.id,
    required this.userName,
    required this.phone,
    this.latitude,
    this.longitude,
    required this.startedAt,
    required this.guardianNumbers,
    required this.smsMessage,
    this.synced = false,
    this.pendingSmsNumbers = const [],
  });
}

class OfflineAlertQueue {
  static const String boxName = 'sos_queue';

  Future<Box<QueuedAlert>> _box() async => Hive.isBoxOpen(boxName)
      ? Hive.box<QueuedAlert>(boxName)
      : Hive.openBox<QueuedAlert>(boxName);

  Future<void> enqueue(QueuedAlert alert) async {
    await (await _box()).put(alert.id, alert);
  }

  Future<List<QueuedAlert>> getUnsynced() async =>
      (await _box())
        .values
        .where((alert) => !alert.synced || alert.pendingSmsNumbers.isNotEmpty)
        .toList();

  Future<void> markSynced(QueuedAlert alert) async {
    alert.synced = true;
    await alert.save();
  }

  Future<void> remove(String id) async {
    await (await _box()).delete(id);
  }
}