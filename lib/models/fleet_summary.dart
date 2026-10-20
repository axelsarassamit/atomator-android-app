import '../models/models.dart';

/// Summarizes only complete, valid readings. Missing readings are never healthy.
class FleetSummary {
  int reported = 0;
  int unavailable = 0;
  int ramMb = 0;
  int warning = 0;
  int critical = 0;
  int? minUptime;
  int? maxUptime;

  FleetSummary.fromResults(Iterable<SSHResult> results) {
    for (final result in results) {
      final fields = result.output.trim().split('|');
      final values = fields.map((v) => int.tryParse(v.trim())).toList();
      if (!result.success ||
          values.length != 3 ||
          values.any((v) => v == null || v < 0) ||
          values[1]! > 100) {
        unavailable++;
        continue;
      }
      reported++;
      ramMb += values[0]!;
      final disk = values[1]!;
      if (disk >= 90) {
        critical++;
      } else if (disk >= 80) {
        warning++;
      }
      final uptime = values[2]!;
      if (minUptime == null || uptime < minUptime!) minUptime = uptime;
      if (maxUptime == null || uptime > maxUptime!) maxUptime = uptime;
    }
  }

  String get totalRam => (ramMb / 1024).toStringAsFixed(1);
  String get averageRam =>
      reported == 0 ? '0.0' : (ramMb / reported / 1024).toStringAsFixed(1);
}
