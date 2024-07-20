

import '../../data/dao/topic_dao.dart';
import '../entities/topic.dart';

abstract class TopicRepositoryInterface {
  Future<List<Topic>> getAllTopics();
  Future<Topic?> getTopicById(String id);
  Future<List<Topic>> getTopicByLanguage(String languageId);
  Future<void> insertTopic(Topic topic);
  Future<void> updateTopic(Topic topic);
  Future<void> deleteTopic(String id);
}

// TODO: Adjust Dependency Injection
class TopicRepository implements TopicRepositoryInterface {
  final TopicDao _topicDao = TopicDao();

  @override
  Future<List<Topic>> getAllTopics() => _topicDao.getAllTopics();

  @override
  Future<List<Topic>> getTopicByLanguage(String languageId) =>
      _topicDao.getAllTopics(languageId: languageId);

  @override
  Future<Topic?> getTopicById(String id) => _topicDao.getTopicById(id);

  @override
  Future<void> insertTopic(Topic topic) => _topicDao.insertTopic(topic);

  @override
  Future<void> updateTopic(Topic topic) => _topicDao.updateTopic(topic);

  @override
  Future<void> deleteTopic(String id) => _topicDao.deleteTopic(id);
}