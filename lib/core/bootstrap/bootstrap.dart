import '../../data/services/database/database_provider.dart';
import '../result/result.dart';

final class Bootstrap {
  final DatabaseProvider _databaseProvider;

  const Bootstrap({required DatabaseProvider databaseProvider})
      : _databaseProvider = databaseProvider;

  AsyncResult<Unit> initialize() => _databaseProvider.init();
}
