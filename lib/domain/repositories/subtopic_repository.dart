
import '../../data/dao/subtopic_dao.dart';
import '../entities/subtopic.dart';

abstract class SubtopicRepositoryInterface {
  Future<List<Subtopic>> getAllSubtopics();
  Future<Subtopic?> getSubtopicById(String id);
  Future<List<Subtopic>> getAllSubtopicsByTopic(String topicId);
  Future<void> insertSubtopic(Subtopic subtopic);
  Future<void> updateSubtopic(Subtopic subtopic);
  Future<void> deleteSubtopic(String id);
}

// TODO: Adjust Dependency Injection
class SubtopicRepository implements SubtopicRepositoryInterface {
  final SubtopicDao _subtopicDao = SubtopicDao();

  @override
  Future<List<Subtopic>> getAllSubtopics() => _subtopicDao.getAllSubtopics();

  @override
  Future<List<Subtopic>> getAllSubtopicsByTopic(String topicId) =>
      _subtopicDao.getAllSubtopics(topicId: topicId);

  @override
  Future<Subtopic?> getSubtopicById(String id) => _subtopicDao.getSubtopicById(id);

  @override
  Future<void> insertSubtopic(Subtopic subtopic) => _subtopicDao.insertSubtopic(subtopic);

  @override
  Future<void> updateSubtopic(Subtopic subtopic) => _subtopicDao.updateSubtopic(subtopic);

  @override
  Future<void> deleteSubtopic(String id) => _subtopicDao.deleteSubtopic(id);
}