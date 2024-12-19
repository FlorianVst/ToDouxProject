import 'dart:math';
import 'dart:ui';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  /// Initialise Awesome Notifications avec les canaux de notification
  Future<void> initializeNotifications() async {
    AwesomeNotifications().initialize(
      null, // Icône par défaut pour les notifications Android (res/drawable)
      [
        NotificationChannel(
          channelKey: 'deadline_channel',
          channelName: 'Notifications de Deadlines',
          channelDescription: 'Rappels pour les deadlines des projets et des étapes.',
          defaultColor: const Color(0xFF9D50DD),
          importance: NotificationImportance.High,
          playSound: true,
        ),
        NotificationChannel(
          channelKey: 'motivation_channel',
          channelName: 'Notifications de Motivation',
          channelDescription: 'Rappels aléatoires pour motiver et rappeler les étapes à venir.',
          defaultColor: const Color(0xFF56AB2F),
          importance: NotificationImportance.High,
          playSound: true,
        ),
      ],
      debug: true,
    );

    // Demande de permission si elle n'est pas encore accordée
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  /// Planifie une notification pour une deadline spécifique
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isAfter(DateTime.now())) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'deadline_channel',
          title: title,
          body: body,
        ),
        schedule: NotificationCalendar(
          year: scheduledDate.year,
          month: scheduledDate.month,
          day: scheduledDate.day,
          hour: scheduledDate.hour,
          minute: scheduledDate.minute,
          second: 0,
          preciseAlarm: true,
        ),
      );
    }
  }

  /// Notifications aléatoires pour les étapes à venir
  Future<void> scheduleRandomStepNotifications(List<Map<String, dynamic>> etapes) async {
    if (etapes.isEmpty) return;

    // Filtre les étapes dont la deadline est dans le futur
    DateTime now = DateTime.now();
    List<Map<String, dynamic>> etapesAVenir = etapes
        .where((etape) => DateTime.parse(etape['deadline']).isAfter(now))
        .toList();

    if (etapesAVenir.isEmpty) return;

    // Sélectionner une étape au hasard
    Random random = Random();
    Map<String, dynamic> etapeAleatoire = etapesAVenir[random.nextInt(etapesAVenir.length)];

    // Créer la notification
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: random.nextInt(100000), // Génère un identifiant unique
        channelKey: 'motivation_channel',
        title: "🔔 Rappel de Motivation : ${etapeAleatoire['nom']}",
        body: "N'oubliez pas de travailler sur l'étape : ${etapeAleatoire['nom']}. Deadline : ${etapeAleatoire['deadline']}",
      ),
    );
  }

  /// Notifications répétées toutes les 30 secondes pour les tests
  Future<void> scheduleRepeatingTestNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 99999, // ID fixe pour cette notification
        channelKey: 'motivation_channel',
        title: "🔔 Notification de Test",
        body: "Ceci est une notification répétée toutes les 30 secondes.",
      ),
      schedule: NotificationInterval(
        interval: Duration(seconds: 30), // Répétition toutes les 30 secondes
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        repeats: true,
      ),
    );
  }
}













