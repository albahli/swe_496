import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swe496/models/Project.dart';
import 'package:swe496/models/User.dart';
import 'package:uuid/uuid.dart';

class ProjectCollection {
  final Firestore _firestore = Firestore.instance;

  Stream<List<Project>> projectStream(User user) {
  }
}
