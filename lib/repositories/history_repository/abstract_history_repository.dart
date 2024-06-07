import '../../common/models/history_model.dart';

abstract class AbstractHistoryRepository {
  Future<int> insert(HistoryModel history);
  Future<HistoryModel?> query(int id);
  Future<List<HistoryModel>> queryAllFromTraining(int trainingId);
  Future<int> delete(HistoryModel history);
  Future<int> update(HistoryModel history);
}
