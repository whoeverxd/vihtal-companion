import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Un medicamento con su hora de toma diaria.
class Medication {
  const Medication({
    required this.id,
    required this.name,
    required this.dose,
    required this.hour,
    required this.minute,
  });

  final String id;
  final String name;
  final String dose;
  final int hour;
  final int minute;

  TimeOfDay get time => TimeOfDay(hour: hour, minute: minute);

  String get timeLabel {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  factory Medication.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Medication(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      dose: (data['dose'] as String?) ?? '',
      hour: (data['hour'] as num?)?.toInt() ?? 8,
      minute: (data['minute'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Registro de una toma de medicación realizada.
class Intake {
  const Intake({
    required this.id,
    required this.medId,
    required this.dayKey,
    required this.takenAt,
  });

  final String id;
  final String medId;
  final String dayKey; // 'yyyyMMdd'
  final DateTime takenAt;

  factory Intake.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final ts = data['takenAt'];
    return Intake(
      id: doc.id,
      medId: (data['medId'] as String?) ?? '',
      dayKey: (data['dayKey'] as String?) ?? '',
      takenAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }
}

/// Una cita médica.
class Appointment {
  const Appointment({
    required this.id,
    required this.title,
    required this.location,
    required this.dateTime,
  });

  final String id;
  final String title;
  final String location;
  final DateTime dateTime;

  factory Appointment.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final ts = data['dateTime'];
    return Appointment(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      location: (data['location'] as String?) ?? '',
      dateTime: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }

  static const _months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];

  String get whenLabel {
    final h = dateTime.hour.toString().padLeft(2, '0');
    final m = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.day} ${_months[dateTime.month - 1]} · $h:$m';
  }
}

/// Un registro de estado de ánimo / síntomas.
class SymptomEntry {
  const SymptomEntry({
    required this.id,
    required this.mood,
    required this.note,
    required this.createdAt,
  });

  final String id;
  final int mood; // 1 (mal) – 5 (excelente)
  final String note;
  final DateTime createdAt;

  factory SymptomEntry.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final ts = data['createdAt'];
    return SymptomEntry(
      id: doc.id,
      mood: (data['mood'] as num?)?.toInt() ?? 3,
      note: (data['note'] as String?) ?? '',
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }
}
