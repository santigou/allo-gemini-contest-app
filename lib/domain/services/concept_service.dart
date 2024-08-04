import 'package:gemini_proyect/data/dao/concept_dao.dart';
import 'package:gemini_proyect/domain/entities/concept.dart';
import 'package:gemini_proyect/domain/entities/response_model.dart';

class ConceptService {
  //TODO: Do the dependency injection
  final ConceptDao _conceptDao = ConceptDao();

  Future<ResponseModel> createManyConcepts(List<Concept> concepts) async {
    try {
      List<int> ids = [];
      List<Concept> conceptList = [];

      for (Concept concept in concepts) {
        int lastId = await _conceptDao.insertConcept(concept);
        ids.add(lastId);
        conceptList.add(concept);
      }

      return ResponseModel(
        isError: false,
        message: "Concepts created successfully",
        result: conceptList,
      );
    } on Exception catch (ex) {
      return ResponseModel(
        isError: true,
        message: ex.toString(),
      );
    }
  }

  Future<List<Concept>> getConceptsByMessageId(int messageId) async {
    try {
      List<Concept> concepts = await _conceptDao.getAllConcepts(messageId: messageId);
      return concepts;
    } catch (e) {
      print("Error getting concepts: $e");
      return [];
    }
  }

  Future<Concept?> getConceptById(int id) async {
    try {
      Concept? concept = await _conceptDao.getConceptById(id);
      return concept;
    } catch (e) {
      print("Error getting concept by id: $e");
      return null;
    }
  }

  Future<ResponseModel> updateConcept(Concept concept) async {
    try {
      await _conceptDao.updateConcept(concept);
      return ResponseModel(
        isError: false,
        message: "Concept updated successfully",
      );
    } on Exception catch (ex) {
      return ResponseModel(
        isError: true,
        message: ex.toString(),
      );
    }
  }

  Future<ResponseModel> deleteConcept(int id) async {
    try {
      await _conceptDao.deleteConcept(id);
      return ResponseModel(
        isError: false,
        message: "Concept deleted successfully",
      );
    } on Exception catch (ex) {
      return ResponseModel(
        isError: true,
        message: ex.toString(),
      );
    }
  }
}
