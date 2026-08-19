import 'package:auto_injector/auto_injector.dart';

import '/domain/usecases/users/users_use_case.dart';

void registerUseCasesDependencies(AutoInjector injector) {
  injector.add<UsersUseCase>(UsersUseCase.new);
}
