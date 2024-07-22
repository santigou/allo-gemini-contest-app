import 'package:gemini_proyect/data/dao/topic_dao.dart';
import 'package:gemini_proyect/domain/entities/response_model.dart';
import 'package:gemini_proyect/domain/entities/topic.dart';
import 'package:gemini_proyect/domain/viewmodels/start_topic_viewmodel.dart';

import '../entities/subtopic.dart';

abstract class ITopicService{

}

class TopicService{

  //TODO: Change to use ID
  final TopicDao _topicDao = new TopicDao();

  Future<ResponseModel> createTopic(startTopicViewModel topicInfo, int languageId) async {
    try
    {
      Topic topicToSave = Topic(
          name: topicInfo.name,
          description: topicInfo.description,
          objectives: topicInfo.objectives,
          languageId: languageId,
          summary: topicInfo.summary,
          subtopicCount: topicInfo.subtopics.length);
      int topicId = await _topicDao.insertTopic(topicToSave);

      return ResponseModel(isError: false,
          message: "Topic created successfully",
          result: topicId );
    }
    on Exception catch (ex)
    {
      return ResponseModel(isError: true, message: ex.toString());
    }
  }
}