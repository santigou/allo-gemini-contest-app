import 'package:gemini_proyect/data/dao/subtopic_dao.dart';

import '../entities/response_model.dart';
import '../entities/subtopic.dart';
import '../viewmodels/subtopic_viewmodel.dart';

class SubtopicService{

  //TODO: Do the dependency inyection
  SubtopicDao _subtopicDao = new SubtopicDao();

  Future<ResponseModel> createManySubtopics(List<SubtopicViewmodel> subtopics, int topicId) async {
    try {

      List<int> ids = [];

      for(SubtopicViewmodel vm in subtopics)
      {
        Subtopic subtopic = Subtopic(name: vm.name,
            description: vm.description,
            objectives: vm.objectives,
            summary: vm.summary,
            conceptCount: 0,
            completed: false,
            order: vm.order,
            topicId: topicId
        );

        int lastId = await _subtopicDao.insertSubtopic(subtopic);
        ids.add(lastId);
      };

      return ResponseModel(isError: false,
          message: "Topic created successfully",
          result: topicId );
    } on Exception catch (ex){
      return ResponseModel(isError: true, message: ex.toString());
    }
  }
}