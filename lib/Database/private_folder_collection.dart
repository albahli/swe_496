import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swe496/models/private_folder_models/category.dart';
import 'package:swe496/models/private_folder_models/comment.dart';
import 'package:swe496/models/private_folder_models/subtask.dart';
import 'package:swe496/models/private_folder_models/task.dart';
import 'package:swe496/models/private_folder_models/activity_action.dart';
import 'package:intl/intl.dart';

class PrivateFolderCollection {
  final Firestore _firestore = Firestore.instance;

  var usersCollection = 'userProfile';
  var tasksCollection = 'tasks';
  var categoriesCollection = 'categories';
  var subtasksCollection = 'subtasks';
  var commentsCollection = 'comments';
  var activityLogCollection = 'activityActions';

  Future<void> createCategory(String userId, String categoryName) async {
    final newCatDocument = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(categoriesCollection)
        .document();

    recordPrivateFolderActivity(
        userId: userId, actionType: 'Created category \'$categoryName\'');

    final newCategory = Category(newCatDocument.documentID, categoryName);

    // Formatting category Dart object to be JSON object
    final category = newCategory.toJson();

    try {
      await newCatDocument.setData(category);
    } catch (e) {
      print('$e create category exception');
    }
  }

  Future<void> deleteCategory({
    @required String userId,
    @required String categoryId,
  }) async {
    final userDocument =
        _firestore.collection(usersCollection).document(userId);

    final categoryDocument =
        userDocument.collection(categoriesCollection).document(categoryId);

    final categoryDocData =
        await categoryDocument.get().then((snapshot) => snapshot.data);

    final taskDocuments = userDocument
        .collection(tasksCollection)
        .where('category', isEqualTo: categoryId)
        .getDocuments();

    recordPrivateFolderActivity(
        userId: userId,
        actionType: 'Deleted category ${categoryDocData['categoryName']}');

    try {
      await taskDocuments.then(
        (snapshot) async {
          for (DocumentSnapshot doc in snapshot.documents) {
            await deleteTask(userId: userId, taskId: doc.data['category']);
          }
        },
      );

      await categoryDocument.delete();
    } catch (e) {
      print(e);
    }
  }

  Future<void> changeCategoryName({
    @required String userId,
    @required String categoryId,
    @required String newCategoryName,
  }) async {
    final categoryDocument = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(categoriesCollection)
        .document(categoryId);

    final categoryDocData =
        await categoryDocument.get().then((snapshot) => snapshot.data);

    recordPrivateFolderActivity(
      userId: userId,
      actionType:
          'Changed category name from ${categoryDocData['categoryName']} to $newCategoryName',
    );

    try {
      await categoryDocument.updateData({
        'categoryName': newCategoryName,
      });
    } catch (e) {
      print(e);
    }
  }

  // Create the created task object as JSON object and add it into the tasks collection at the database
  Future<void> createTask({
    String userId,
    String categoryId,
    String newTaskTitle,
    DateTime dueDate,
    String state,
    String priority,
  }) async {
    final newTaskDocument = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(tasksCollection)
        .document();

    recordPrivateFolderActivity(
        userId: userId, actionType: "Created task '$newTaskTitle'");

    TaskModel newTask = TaskModel(
      categoryId: categoryId,
      taskId: newTaskDocument.documentID,
      taskTitle: newTaskTitle,
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

    final taskDocData =
        await taskDocument.get().then((snapshot) => snapshot.data);

    await recordPrivateFolderActivity(
        userId: userId, actionType: 'Deleted task ${taskDocData['taskTitle']}');

    try {
      await taskDocument.collection(subtasksCollection).getDocuments().then(
        (snapshot) async {
          for (DocumentSnapshot doc in snapshot.documents) {
            await deleteSubtask(
                userId: userId,
                parentTaskId: taskId,
                subtaskId: doc.data['subtaskId']);
            doc.reference.delete();
          }
        },
      );

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

    recordPrivateFolderActivity(
        userId: userId, actionType: 'Created subtask $subtaskTitle');

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

    final subtaskDocData =
        await subtaskDocument.get().then((snapshot) => snapshot.data);

    recordPrivateFolderActivity(
        userId: userId,
        actionType: 'Deleted subtask ${subtaskDocData['subtaskTitle']}');

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
        .snapshots();

    return subtasksSnapshot.map(
      (QuerySnapshot query) {
        List<Subtask> _subtasksList = List<Subtask>();
        query.documents.forEach(
          (subtask) {
            print('subtask title is ${subtask.data['subtaskTitle']}');
            _subtasksList.add(Subtask.fromJson(subtask.data));
          },
        );
        return _subtasksList;
      },
    );
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

    return taskDocument.map(
      (taskSnapshot) {
        return TaskModel.fromJson(taskSnapshot.data);
      },
    );
  }

  Future<void> taskCompletionToggle({
    String userId,
    String taskId,
    bool completionState,
  }) async {
    final taskDocument = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(tasksCollection)
        .document(taskId);

    final taskDocData =
        await taskDocument.get().then((snapshot) => snapshot.data);

    recordPrivateFolderActivity(
      userId: userId,
      actionType: completionState == true
          ? 'Completed Task \'${taskDocData['taskTitle']}\''
          : 'Redo task \'${taskDocData['taskTitle']}\'',
    );

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

    final taskDocData =
        await taskDocument.get().then((snapshot) => snapshot.data);

    recordPrivateFolderActivity(
      userId: userId,
      actionType: 'Changed task \'${taskDocData['taskTitle']}\' category',
    );

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

    final taskDocData =
        await taskDocument.get().then((snapshot) => snapshot.data);

    recordPrivateFolderActivity(
      userId: userId,
      actionType:
          'Changed task title from \'${taskDocData['taskTitle']}\' to \'$newTitle\'',
    );

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

    final taskDocData =
        await taskDocument.get().then((snapshot) => snapshot.data);

    recordPrivateFolderActivity(
      userId: userId,
      actionType:
          'Changed task due date \'${taskDocData['taskTitle']}\' to \'${DateFormat.yMMMd().format(newDueDate)}\'',
    );

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

    final taskDocData =
        await taskDocument.get().then((snapshot) => snapshot.data);

    recordPrivateFolderActivity(
      userId: userId,
      actionType:
          'Changed status of task \'${taskDocData['taskTitle']}\' to \'$newState\'',
    );

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

    final taskDocData =
        await taskDocument.get().then((snapshot) => snapshot.data);

    recordPrivateFolderActivity(
      userId: userId,
      actionType:
          'Changed priority of task \'${taskDocData['taskTitle']}\' to \'$newPriority\'',
    );

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

    final subtaskDocData =
        await subtaskDocument.get().then((snapshot) => snapshot.data);

    recordPrivateFolderActivity(
      userId: userId,
      actionType: completionState == true
          ? 'Completed subtask \'${subtaskDocData['subtaskTitle']}\''
          : 'Redo subtask \'${subtaskDocData['subtaskTitle']}\'',
    );

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

    final subtaskDocData =
        await subtaskDocument.get().then((snapshot) => snapshot.data);

    recordPrivateFolderActivity(
      userId: userId,
      actionType:
          'Changed status of subtask \'${subtaskDocData['subtaskTitle']}\' to \'$newState\'',
    );

    try {
      await subtaskDocument.updateData({'subtaskState': newState});
    } catch (e) {
      print(e);
    }
  }

  Future<void> changeSubtaskPriority({
    @required String userId,
    @required String taskId,
    @required String newPriority,
    @required String subtaskId,
  }) async {
    final subtaskDocument = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(tasksCollection)
        .document(taskId)
        .collection(subtasksCollection)
        .document(subtaskId);

    final subtaskDocData =
        await subtaskDocument.get().then((snapshot) => snapshot.data);

    recordPrivateFolderActivity(
      userId: userId,
      actionType:
          'Changed priority of subtask \'${subtaskDocData['subtaskTitle']}\' to \'$newPriority\'',
    );

    try {
      await subtaskDocument.updateData({'subtaskPriority': newPriority});
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
    final taskDocument = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(tasksCollection)
        .document(taskId);

    final taskDocData =
        await taskDocument.get().then((snapshot) => snapshot.data);

    final newCommentDocument =
        taskDocument.collection(commentsCollection).document();

    recordPrivateFolderActivity(
      userId: userId,
      actionType: 'Created comment in task \'${taskDocData['taskTitle']}\'',
    );

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

  Future<void> recordPrivateFolderActivity({
    @required String userId,
    @required String actionType,
  }) async {
    final activityDocument = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(activityLogCollection)
        .document();

    ActivityAction activity = ActivityAction(
      actionId: activityDocument.documentID,
      actionType: actionType,
      actionDate: DateTime.now(),
    );

    var activityJson = activity.toJson();

    try {
      await activityDocument.setData(activityJson);
    } catch (e) {
      print(e);
    }
  }

  Stream<List<ActivityAction>> activityStream(String userId) {
    final activitySnapshot = _firestore
        .collection(usersCollection)
        .document(userId)
        .collection(activityLogCollection)
        .orderBy('actionDate', descending: true)
        .snapshots();

    return activitySnapshot.map((QuerySnapshot query) {
      List<ActivityAction> _activityActions = List<ActivityAction>();
      query.documents.forEach(
        (activityDocument) {
          _activityActions.add(ActivityAction.fromJson(activityDocument.data));
        },
      );
      return _activityActions;
    });
  }
}
