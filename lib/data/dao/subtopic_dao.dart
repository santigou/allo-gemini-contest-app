

import '../../domain/entities/subtopic.dart';
import '../services/database_service.dart';

class SubtopicDao {
  Future<List<Subtopic>> getAllSubtopics({int? topicId}) async {
    final db = await DatabaseService.instance.database;
    final List<Map<String,dynamic>> maps = await db.rawQuery('SELECT * FROM subtopics ${(topicId == null)?'': "WHERE topicId = $topicId"}');
    print(maps);//TODO REMOVE PRINT
    return List.generate(maps.length, (i) {
      return Subtopic.fromMap(maps[i]);
    });
  }

  Future<Subtopic?> getSubtopicById(int id) async {
    final db = await DatabaseService.instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM subtopics WHERE id = ?',
      [id],
    );
    if (maps.isNotEmpty) {
      return Subtopic.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertSubtopic(Subtopic subtopic) async {
    final db = await DatabaseService.instance.database;
    return await db.rawInsert(
      'INSERT INTO subtopics( name, description, objectives, summary, conceptCount, completed, topicOrder, topicId) VALUES(?, ?, ?, ?, ?, ?, ?, ?)',
      [
        subtopic.name,
        subtopic.description,
        subtopic.objectives,
        subtopic.summary,
        subtopic.conceptCount,
        subtopic.completed ? 1 : 0,
        subtopic.order,
        subtopic.topicId,
      ],
    );
  }

  Future<void> updateSubtopic(Subtopic subtopic) async {
    final db = await DatabaseService.instance.database;
    await db.rawUpdate(
      'UPDATE subtopics SET name = ?, description =?, objectives = ?, summary = ?, conceptCount = ?, completed = ?, previousSubtopicId = ?, nextSubtopicId = ?, topicId = ? WHERE id = ?',
      [
        subtopic.name,
        subtopic.description,
        subtopic.objectives,
        subtopic.summary,
        subtopic.conceptCount,
        subtopic.completed ? 1 : 0,
        subtopic.order,
        subtopic.id
      ],
    );
  }

  Future<void> deleteSubtopic(String id) async {
    final db = await DatabaseService.instance.database;
    await db.rawDelete(
      'DELETE FROM subtopics WHERE id = ?',
      [id],
    );
  }
}