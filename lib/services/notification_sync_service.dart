//lib/services/notification_sync_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';

class NotificationSyncService {
  static Future<void> syncTodayTasks() async {
    final user = FirebaseAuth.instance.currentUser!;
    final now = DateTime.now();

    String todayId = "${user.uid}_${now.year}-${now.month}-${now.day}";

    final dailyRef = FirebaseFirestore.instance
        .collection('daily')
        .doc(todayId);

    final dailyDoc = await dailyRef.get();

    if (!dailyDoc.exists) return;

    await NotificationService.cancelAllNotifications();
    final tareas = await dailyRef.collection('tareas').get();

    for (var doc in tareas.docs) {
      final data = doc.data();

      final hora = data["hora_recordatorio"];
      final titulo = data["titulo"];

      // 🔥 SI TIENE HORA → PROGRAMAR
      if (hora != null && hora.toString().isNotEmpty) {
        await NotificationService.scheduleNotification(
          id: doc.id,
          title: titulo,
          time: hora,
        );
      } else {
        // 🔥 SI YA NO TIENE HORA → CANCELAR
        await NotificationService.cancelNotification(doc.id);
      }
    }
  }
}
