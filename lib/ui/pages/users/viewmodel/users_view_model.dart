import 'dart:collection';

import 'package:flutter/foundation.dart';

import '/core/result/command.dart';
import '/domain/common/user/models/user.dart';
import '/domain/models/image_preparation.dart';
import '/domain/models/prepared_user_image.dart';
import '/domain/usecases/users/users_use_case.dart';

typedef UserMutation = ({
  User user,
  PreparedUserImage? preparedImage,
});

class UsersViewModel extends ChangeNotifier {
  final UsersUseCase _useCase;
  final Set<int> _activeUserIds;
  final Set<int> _selectedUserIds;
  final Map<Command<Object>, VoidCallback> _commandListeners = {};

  late final Command0<List<User>> loadCommand;
  late final Command1<User, UserMutation> addCommand;
  late final Command1<Unit, UserMutation> editCommand;
  late final Command1<Unit, User> deleteCommand;
  late final Command0<ImagePreparation> prepareImageCommand;
  late final Command1<Unit, PreparedUserImage> discardImageCommand;

  AppError? _lastError;

  UsersViewModel({
    required UsersUseCase useCase,
    required Iterable<int> initiallySelectedUserIds,
  })  : _useCase = useCase,
        _activeUserIds = Set<int>.of(initiallySelectedUserIds),
        _selectedUserIds = Set<int>.of(initiallySelectedUserIds) {
    loadCommand = Command0<List<User>>(_useCase.loadAll);
    addCommand = Command1<User, UserMutation>(_add);
    editCommand = Command1<Unit, UserMutation>(_edit);
    deleteCommand = Command1<Unit, User>(_delete);
    prepareImageCommand = Command0<ImagePreparation>(_useCase.prepareImage);
    discardImageCommand =
        Command1<Unit, PreparedUserImage>(_useCase.discardPreparedImage);

    for (final command in _commands) {
      void listener() => _onCommandChanged(command);
      _commandListeners[command] = listener;
      command.addListener(listener);
    }
  }

  List<User> get users => _useCase.users;

  Set<int> get selectedUserIds => UnmodifiableSetView(_selectedUserIds);

  Set<int> get activeUserIds => UnmodifiableSetView(_activeUserIds);

  List<User> get selectedUsers => List.unmodifiable(
        users.where((user) {
          final id = user.id;
          return id != null && _selectedUserIds.contains(id);
        }),
      );

  AppError? get lastError => _lastError;

  bool get isLoading => _commands.any((command) => command.isRunning);

  Iterable<Command<Object>> get _commands => [
        loadCommand,
        addCommand,
        editCommand,
        deleteCommand,
        prepareImageCommand,
        discardImageCommand,
      ];

  Future<void> load() => loadCommand.execute();

  Future<void> add({
    required User user,
    PreparedUserImage? preparedImage,
  }) =>
      addCommand.execute((user: user, preparedImage: preparedImage));

  Future<void> edit({
    required User user,
    PreparedUserImage? preparedImage,
  }) =>
      editCommand.execute((user: user, preparedImage: preparedImage));

  Future<void> delete(User user) => deleteCommand.execute(user);

  Future<PreparedUserImage?> prepareImage() async {
    await prepareImageCommand.execute();
    return switch (prepareImageCommand.value) {
      ImagePrepared(:final image) => image,
      _ => null,
    };
  }

  Future<void> discardPreparedImage(PreparedUserImage image) =>
      discardImageCommand.execute(image);

  bool isSelected(User user) {
    final id = user.id;
    return id != null && _selectedUserIds.contains(id);
  }

  void setSelected(User user, {required bool selected}) {
    final id = user.id;
    if (id == null) return;

    final changed =
        selected ? _selectedUserIds.add(id) : _selectedUserIds.remove(id);
    if (changed) notifyListeners();
  }

  void clearLastError() {
    if (_lastError == null) return;
    _lastError = null;
    notifyListeners();
  }

  AsyncResult<User> _add(UserMutation mutation) => _useCase.insert(
        user: mutation.user,
        preparedImage: mutation.preparedImage,
      );

  AsyncResult<Unit> _edit(UserMutation mutation) => _useCase.update(
        user: mutation.user,
        preparedImage: mutation.preparedImage,
      );

  AsyncResult<Unit> _delete(User user) {
    if (isSelected(user)) {
      return Future.value(
        const Failure(
          AppError(
            code: AppErrorCode.invalidData,
            message: 'A selected user cannot be deleted.',
          ),
        ),
      );
    }
    return _useCase.delete(user);
  }

  void _onCommandChanged(Command<Object> command) {
    if (command.isRunning || command.isSuccess) {
      _lastError = null;
    } else if (command.isFailure) {
      _lastError = command.error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    for (final command in _commands) {
      command
        ..removeListener(_commandListeners[command]!)
        ..dispose();
    }
    _commandListeners.clear();
    super.dispose();
  }
}
