//lib/services/notification_texts.dart

class NotificationTexts {
  static const String channelId = "daily_channel";

  static const String channelName = "Daily Notifications";

  static const String channelDescription = "Recordatorios de tareas diarias";

  static const String defaultTitle = "⏰ Daily Partner";

  static String notificationTitle(String importance) {
    if (importance == "alta") {
      return "🔥 Tarea importante";
    }

    return defaultTitle;
  }

  static String notificationBody(String taskTitle) {
    return "No olvides: $taskTitle";
  }
}
