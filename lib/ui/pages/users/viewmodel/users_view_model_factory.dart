import '/domain/usecases/users/users_use_case.dart';
import 'users_view_model.dart';

final class UsersViewModelFactory {
  final UsersUseCase Function() _useCaseFactory;

  const UsersViewModelFactory({
    required UsersUseCase Function() useCaseFactory,
  }) : _useCaseFactory = useCaseFactory;

  UsersViewModel create(Iterable<int> activeUserIds) => UsersViewModel(
        useCase: _useCaseFactory(),
        initiallySelectedUserIds: activeUserIds,
      );
}
