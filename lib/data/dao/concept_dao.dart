import 'package:gemini_proyect/domain/entities/concept.dart';
import '../services/database_service.dart';

class ConceptDao {

  Future<List<Concept>> getAllConcepts({int? messageId}) async {
    final db = await DatabaseService.instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT * FROM concepts ${(messageId == null) ? '' : "WHERE messageId = $messageId"} ORDER BY id DESC');
    return List.generate(maps.length, (i) {
      return Concept.fromSqfliteDatabase(maps[i]);
    });
  }

  Future<Concept?> getConceptById(int id) async {
    final db = await DatabaseService.instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM concepts WHERE id = ?',
      [id],
    );
    if (maps.isNotEmpty) {
      return Concept.fromSqfliteDatabase(maps.first);
    }
    return null;
  }

  Future<int> insertConcept(Concept concept) async {
    final db = await DatabaseService.instance.database;
    return await db.rawInsert(
      'INSERT INTO concepts(name, explanation, examples, messageId) VALUES(?, ?, ?, ?)',
      [
        concept.name,
        concept.explanation,
        concept.examples,
        concept.messageId,
      ],
    );
  }

  Future<void> updateConcept(Concept concept) async {
    final db = await DatabaseService.instance.database;
    await db.rawUpdate(
      'UPDATE concepts SET name = ?, explanation = ?, examples = ?, messageId = ? WHERE id = ?',
      [
        concept.name,
        concept.explanation,
        concept.examples,
        concept.messageId,
        concept.id,
      ],
    );
  }

  Future<void> deleteConcept(int id) async {
    final db = await DatabaseService.instance.database;
    await db.rawDelete(
      'DELETE FROM concepts WHERE id = ?',
      [id],
    );
  }
}
