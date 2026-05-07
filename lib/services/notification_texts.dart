//lib/services/notification_texts.dart

class NotificationTexts {
  static const String title = "No te olvides:";

  static String body(String taskTitle) {
    return taskTitle; // 👈 viene de Firestore (subcolección tareas)
  }
}
