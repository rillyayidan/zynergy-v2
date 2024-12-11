import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class TimezoneHelper {
  static void initializeTimezone() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta')); // Ubah sesuai zona waktu lokal Anda
  }

  static tz.TZDateTime getNextInstanceOf(DateTime time) {
    return tz.TZDateTime.from(time, tz.local);
  }
}