import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  // from adding tasks
  String? id;
  String? taskName;
  String? status; // encoded via a string
  DateTime? deadline;
  String? description;
  // misc info
  String? ownerId;
  DateTime? lastEditedDate;
  String? lastEditUserId;

  TaskModel(
      {this.id,
      this.taskName,
      this.status,
      this.deadline,
      this.description,
      // misc info
      this.ownerId,
      this.lastEditedDate,
      this.lastEditUserId});

  TaskModel copyWith(TaskModel other) {
    return TaskModel(
        id: other.id ?? id,
        taskName: other.taskName ?? taskName,
        status: other.status ?? status,
        deadline: other.deadline ?? deadline,
        description: other.description ?? description,
        // other info
        ownerId: other.ownerId ?? ownerId,
        lastEditedDate: other.lastEditedDate ?? lastEditedDate,
        lastEditUserId: other.lastEditUserId ?? lastEditUserId);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) "id": id,
      if (taskName != null) "taskName": taskName,
      if (status != null) "status": status,
      if (deadline != null) "deadline": Timestamp.fromDate(deadline!),
      if (description != null) "description": description,
      // other info
      if (ownerId != null) "ownerId": ownerId,
      if (lastEditedDate != null)
        "lastEditedDate": Timestamp.fromDate(lastEditedDate!),
      if (lastEditUserId != null) "lastEditedUserId": lastEditUserId
    };
  }

  // convert from firestore
  factory TaskModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return TaskModel(
        id: data?['id'],
        taskName: data?['taskName'],
        status: data?['status'],
        deadline: (data?['deadline'] as Timestamp).toDate(),
        description: data?['description'],
        // other info
        ownerId: data?['ownerId'],
        lastEditedDate: (data?['lastEditedDate'] as Timestamp).toDate(),
        lastEditUserId: data?['lastEditedUserId']);
  }
}
