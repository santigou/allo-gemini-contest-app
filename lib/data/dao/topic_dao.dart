import '../../domain/entities/topic.dart';
import '../services/database_service.dart';


class TopicDao {

  Future<List<Topic>> getAllTopics({String? languageId}) async {
    final db = await DatabaseService.instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM topics ${(languageId == null)?'': "WHERE languageId = $languageId"}');
    return List.generate(maps.length, (i) {
      return Topic.fromSqfliteDatabase(maps[i]);
    });
  }

  Future<Topic?> getTopicById(String id) async {
    final db = await DatabaseService.instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM topics WHERE id = ?',
      [id],
    );
    if (maps.isNotEmpty) {
      return Topic.fromSqfliteDatabase(maps.first);
    }
    return null;
  }

  Future<void> insertTopic(Topic topic) async {
    final db = await DatabaseService.instance.database;
    await db.rawInsert(
      'INSERT OR REPLACE INTO topics(id, name, description, objectives, languageId, summary, subtopicCount) VALUES(?, ?, ?, ?, ?, ?, ?)',
      [
        topic.id,
        topic.name,
        topic.description,
        topic.objectives,
        topic.languageId,
        topic.summary,
        topic.subtopicCount,
      ],
    );
  }

  Future<void> updateTopic(Topic topic) async {
    final db = await DatabaseService.instance.database;
    await db.rawUpdate(
      'UPDATE topics SET name = ?, description = ?, objectives = ?, languageId = ?, summary = ?, subtopicCount = ? WHERE id = ?',
      [
        topic.name,
        topic.description,
        topic.objectives,
        topic.languageId,
        topic.summary,
        topic.subtopicCount,
        topic.id,
      ],
    );
  }

  Future<void> deleteTopic(String id) async {
    final db = await DatabaseService.instance.database;
    await db.rawDelete(
      'DELETE FROM topics WHERE id = ?',
      [id],
    );
  }
}