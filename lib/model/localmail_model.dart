import 'package:cloud_firestore/cloud_firestore.dart';

class LocalMailModel {
  String? id;
  String? userId;
  String? type;
  String? message;
  DateTime? timestamp;

  LocalMailModel({
    this.id,
    this.userId,
    this.type,
    this.message,
    this.timestamp,
  });

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) "id": id,
      if (userId != null) "userId": userId,
      if (type != null) "type": type,
      if (message != null) "message": message,
      if (timestamp != null) "timestamp": Timestamp.fromDate(timestamp!),
    };
  }

  factory LocalMailModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return LocalMailModel(
      id: data?['id'],
      userId: data?['userId'],
      type: data?['type'],
      message: data?['message'],
      timestamp: (data?['timestamp'] as Timestamp).toDate(),
    );
  }
}
