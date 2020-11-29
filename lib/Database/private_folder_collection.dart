import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swe496/models/private_folder_models/category.dart';
import 'package:swe496/models/private_folder_models/comment.dart';
import 'package:swe496/models/private_folder_models/subtask.dart';
import 'package:swe496/models/private_folder_models/task.dart';

class PrivateFolderCollection {
  // 15 this is the instance we need to handle Firestore operations
  final Firestore _firestore = Firestore.instance;

  var usersCollection = 'userProfile';
  var tasksCollection = 'tasks';
  var categoriesCollection = 'categories';
  var subtasksCollection = 'subtasks';
  var commentsCollection = 'comments';

  Future<void> createCategory(String userId, String categoryName) async {
    final newCatDocument = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(categoriesCollection)
        .document();

    final newCategory = Category(newCatDocument.documentID, categoryName);

    // Formatting category Dart object to be JSON object
    final category = newCategory.toJson();

    try {
      await newCatDocument.setData(category);
    } catch (e) {
      print('$e create category exception');
    }
  }

  Future<void> removeTaskFromCategory(String categoryId, String taskId) async {
    // TODO: remove a task from category
  }

  Future<void> changeCategoryName(String categoryId, String newName) async {
    // TODO: change the category of id 'categoryId' to the name 'newName'
  }

  // Now we finished setting up Firestore for the authentication side, and we are now going to use it within our app
  // and we are going to use it directly when we create a user in Firebase authentication service, and when we log in

  // Add the created task to the tasks collection at the database
  Future<void> createTask({
    String userId,
    String categoryId,
    String newTtaskTitle,
    DateTime dueDate,
    String state,
    String priority,
  }) async {
    final newTaskDocument = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(tasksCollection)
        .document();

    TaskModel newTask = TaskModel(
      categoryId: categoryId,
      taskId: newTaskDocument.documentID,
      taskTitle: newTtaskTitle,
      dueDate: dueDate,
      state: state,
      priority: priority,
      completed: false,
    );

    // formatting the task dart object to be a JSON object
    final jsonTask = newTask.toJson();

    try {
      await newTaskDocument.setData(jsonTask);
    } catch (e) {
      print('$e create task exception');
      rethrow;
    }
  }

  Future<void> deleteTask({
    @required String userId,
    @required String taskId,
  }) async {
    final taskDocument = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(tasksCollection)
        .document(taskId);

    try {
      taskDocument
          .collection(subtasksCollection)
          .getDocuments()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.documents) {
          doc.reference.delete();
        }
      });
      taskDocument
          .collection(commentsCollection)
          .getDocuments()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.documents) {
          doc.reference.delete();
        }
      });
      await taskDocument.delete();
    } catch (e) {
      print(e);
    }
  }

  Future<void> createSubtask({
    @required String userId,
    @required String parentTaskId,
    @required String subtaskTitle,
    @required DateTime dueDate,
    @required String state,
    @required String priority,
  }) async {
    final newSubtaskDocument = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(tasksCollection)
        .document(parentTaskId)
        .collection(subtasksCollection)
        .document();

    Subtask newSubtask = Subtask(
      parentTaskId: parentTaskId,
      subtaskId: newSubtaskDocument.documentID,
      subtaskTitle: subtaskTitle,
      dueDate: dueDate,
      subtaskState: state,
      subtaskPriority: priority,
      completed: false,
    );

    final subtaskJSON = newSubtask.toJson();
    print('The subtask as json map is >> $subtaskJSON');
    try {
      await newSubtaskDocument.setData(subtaskJSON);
    } catch (e) {
      print('$e create subtask exception');
    }
  }

  Future<void> deleteSubtask({
    @required String userId,
    @required String parentTaskId,
    @required String subtaskId,
  }) async {
    print('entered the subtask deletion implementer area');
    final subtaskDocument = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(tasksCollection)
        .document(parentTaskId)
        .collection(subtasksCollection)
        .document(subtaskId);

    try {
      print('entered the subtask deletion implementer last area');
      await subtaskDocument.delete();
      print('proceeded over the subtask deletion implementer last area');
    } catch (e) {
      print(e);
    }
  }

  // The stream to provide to the tasks
  Stream<List<TaskModel>> privateFolderTasksStream(String userId) {
    final tasksSnapshot = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(tasksCollection)
        .orderBy('dueDate')
        .orderBy('taskState')
        .orderBy('taskPriority')
        .orderBy('taskTitle')
        .snapshots();

    return tasksSnapshot.map(
      (QuerySnapshot query) {
        List<TaskModel> _tasksList = List<TaskModel>();
        query.documents.forEach(
          (DocumentSnapshot taskDocument) {
            _tasksList.add(TaskModel.fromJson(taskDocument.data));
          },
        );
        return _tasksList;
      },
    );
  }

  Stream<List<Subtask>> subtasksStream({
    @required String userId,
    @required String parentTaskId,
  }) {
    print('subtasks stream entered $parentTaskId');
    final subtasksSnapshot = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(tasksCollection)
        .document(parentTaskId)
        .collection(subtasksCollection)
        .where('parentTaskId', isEqualTo: parentTaskId) // ! really need it?
        .snapshots();

    return subtasksSnapshot.map((QuerySnapshot query) {
      List<Subtask> _subtasksList = List<Subtask>();
      query.documents.forEach((subtask) {
        print('subtask title is ${subtask.data['subtaskTitle']}');
        _subtasksList.add(Subtask.fromJson(subtask.data));
      });
      return _subtasksList;
    });
  }

  Stream<List<Category>> privateFolderCategoriesStream(String userId) {
    final categoriesSnapshot = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(categoriesCollection)
        .orderBy('categoryId')
        .snapshots();

    return categoriesSnapshot.map(
      (QuerySnapshot query) {
        List<Category> _categoriesList = List<Category>();
        query.documents.forEach(
          (DocumentSnapshot element) {
            _categoriesList.add(Category.fromJson(element.data));
          },
        );
        return _categoriesList.reversed.toList();
      },
    );
  }

  Future<Stream<TaskModel>> taskStream(String userId, taskId) async {
    final taskDocument = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(tasksCollection)
        .document(taskId)
        .snapshots();

    return taskDocument.map((taskSnapshot) {
      return TaskModel.fromJson(taskSnapshot.data);
    });
  }

  Future<void> taskCompletionToggle(
      {String userId, String taskId, bool completionState}) async {
    final taskDocument = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(tasksCollection)
        .document(taskId);
    try {
      await taskDocument.updateData({'completed': completionState});
    } catch (e) {
      print('$e update task exception');
      rethrow;
    }
  }

  Future<void> changeTaskCategory({
    @required String userId,
    @required String taskId,
    @required String newCategoryId,
  }) async {
    final taskDocument = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(tasksCollection)
        .document(taskId);

    try {
      await taskDocument.updateData({
        'category': newCategoryId,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> changeTaskTitle({
    @required String userId,
    @required String taskId,
    @required String newTitle,
  }) async {
    final taskDocument = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(tasksCollection)
        .document(taskId);

    try {
      await taskDocument.updateData({'taskTitle': newTitle});
    } catch (e) {
      print(e);
    }
  }

  Future<void> changeTaskDueDate({
    @required String userId,
    @required String taskId,
    @required DateTime newDueDate,
  }) async {
    final taskDocument = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(tasksCollection)
        .document(taskId);

    try {
      await taskDocument.updateData({
        'dueDate': newDueDate,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> changeStatus({
    @required String userId,
    @required String taskId,
    @required String newState,
  }) async {
    final taskDocument = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(tasksCollection)
        .document(taskId);

    try {
      await taskDocument.updateData({'taskState': newState});
    } catch (e) {
      print(e);
    }
  }

  Future<void> changePriority({
    @required String userId,
    @required String taskId,
    @required String newPriority,
  }) async {
    final taskDocument = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(tasksCollection)
        .document(taskId);

    try {
      await taskDocument.updateData({'taskPriority': newPriority});
    } catch (e) {
      print(e);
    }
  }

  Future<bool> taskHasSubtasks(String taskId, String userId) async {
    final taskDocument = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(tasksCollection)
        .document(taskId);

    try {
      var x = await taskDocument.collection(subtasksCollection).getDocuments();
      return x.documents.length > 0;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> subtaskCompletionToggle({
    String userId,
    String parentTaskId,
    String subtaskId,
    bool completionState,
  }) async {
    final subtaskDocument = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(tasksCollection)
        .document(parentTaskId)
        .collection(subtasksCollection)
        .document(subtaskId);
    try {
      await subtaskDocument.updateData({'completed': completionState});
    } catch (e) {
      print('$e update task exception');
      rethrow;
    }
  }

  Future<void> changeSubtaskStatus({
    @required String userId,
    @required String taskId,
    @required String newState,
    @required String subtaskId,
  }) async {
    final subtaskDocument = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(tasksCollection)
        .document(taskId)
        .collection(subtasksCollection)
        .document(subtaskId);

    try {
      await subtaskDocument.updateData({'subtaskState': newState});
    } catch (e) {
      print(e);
    }
  }

  Future<void> createComment({
    @required String userId,
    @required String taskId,
    @required String commentText,
    @required DateTime dateTime,
  }) async {
    final newCommentDocument = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(tasksCollection)
        .document(taskId)
        .collection(commentsCollection)
        .document();

    Comment newComment = Comment(
      commentId: newCommentDocument.documentID,
      commentText: commentText,
      dateTime: dateTime,
    );

    final jsonComment = newComment.toJson();

    try {
      await newCommentDocument.setData(jsonComment);
    } catch (e) {
      print(e);
    }
  }

  Stream<List<Comment>> commentsStream({
    @required String userId,
    @required String taskId,
  }) {
    final commentsSnapshot = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(tasksCollection)
        .document(taskId)
        .collection(commentsCollection)
        .snapshots();

    return commentsSnapshot.map((QuerySnapshot query) {
      List<Comment> _commentsList = List<Comment>();

      query.documents.forEach((commentDocument) {
        print(commentDocument.data);
        _commentsList.add(Comment.fromJson(commentDocument.data));
      });
      return _commentsList;
    });
  }
}
