import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:onboarding_overlay/onboarding_overlay.dart';

import '../../common/singletons/app_settings.dart';
import '../../common/models/user_model.dart';
import 'widgets/user_dialog/user_dialog.dart';
import '../stopwatch_page/stopwatch_page_controller.dart';
import '../widgets/common/generic_dialog.dart';
import 'users_page_controller.dart';
import 'users_page_state.dart';
import 'widgets/dismissible_user_tile.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({
    super.key,
  });

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final app = AppSettings.instance;
  final _controller = UsersPageController();
  final List<UserModel> _selectedUsers = [];
  final List<int> _preSelectedUserIds = [];
  late final OnboardingState? overlay;

  @override
  void initState() {
    super.initState();
    _startingPage();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        overlay = Onboarding.of(context);
        if (app.showTutorial || app.tutorialOn) {
          _startTutorial();
        }
      },
    );
  }

  void _startTutorial() {
    if (app.tutorialOn) {
      if (overlay != null) {
        overlay!.show();
      }
    }
  }

  Future<void> _startingPage() async {
    await _controller.init();

    final usersList = StopwatchPageController.instance.usersList;

    _preSelectedUserIds.addAll(
      usersList.map(
        (user) => user.id!,
      ),
    );

    _selectedUsers.addAll(usersList);
  }

  Future<void> _addNewUser() async {
    final result = await UserDialog.open(
      context,
      addUser: _controller.addUser,
    );

    await Future.delayed(const Duration(milliseconds: 150));
    if (result != null && result) {
      _continueTutorial();
    } else {
      app.tutorialOn = false;
    }
  }

  Future<void> _continueTutorial() async {
    if (app.tutorialOn && mounted) {
      final overlay = Onboarding.of(context);
      if (overlay != null) {
        if (app.focusNodes[9].context?.mounted ?? false) {
          overlay.showFromIndex(2);
        } else {
          await Future.delayed(const Duration(microseconds: 100), () {
            if (app.focusNodes[9].context?.mounted ?? false) {
              overlay.showFromIndex(2);
            }
          });
        }
      }
    }
  }

  void _backPage() {
    // overlay!.deactivate();
    Navigator.pop(context);
  }

  void selectUser(bool select, UserModel user) {
    if (select) {
      _selectedUsers.add(user);
    } else {
      _selectedUsers.removeWhere((item) => item.id == user.id);
    }
  }

  Future<bool> editUser(UserModel user) async {
    final result = await UserDialog.open(
          context,
          user: user,
          addUser: _controller.updateUser,
        ) ??
        false;
    return result;
  }

  bool isSelected(UserModel user) {
    final list = _selectedUsers.map((u) => u.id).toList();
    return list.contains(user.id!);
  }

  Future<bool> deleteUser(UserModel user) async {
    if (isSelected(user)) {
      await GenericDialog.open(
        context,
        title: 'APBlockedTitle'.tr(),
        message: 'APBlockedMsg'.tr(),
        actions: DialogActions.close,
      );
      return false;
    }

    final result = await GenericDialog.open(
      context,
      title: 'APDeleteUser'.tr(),
      message: 'APDeleteUserMsg'.tr(),
      actions: DialogActions.yesNo,
    );
    if (result) {
      _controller.deleteUser(user);
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        final stopwatchController = StopwatchPageController.instance;
        stopwatchController.addNewUsers(_selectedUsers);
      },
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          elevation: 5,
          title: Text('APUserList'.tr()),
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.menu),
              itemBuilder: (context) => <PopupMenuEntry>[
                PopupMenuItem(
                  onTap: () {
                    app.tutorialOn = true;
                    _startTutorial();
                  },
                  child: const ListTile(
                    leading: Icon(Icons.question_mark),
                    title: Text('Tutorial'),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ListenableBuilder(
                listenable: _controller,
                builder: (context, child) {
                  switch (_controller.state) {
                    // Users Page State Loading
                    case UsersPageStateLoading():
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    // Users Page State Success
                    case UsersPageStateSuccess():
                      final user = _controller.users;
                      if (user.isEmpty) {
                        return Center(
                          child: Text('APRegisterSome'.tr()),
                        );
                      }
                      return Expanded(
                        child: ListView.builder(
                          itemCount: user.length,
                          itemBuilder: (context, index) => Focus(
                            focusNode: app.isTutorial(user[index].id!)
                                ? app.focusNodes[9]
                                : null,
                            child: DismissibleUserTile(
                              user: user[index],
                              selectUser: selectUser,
                              editFunction: editUser,
                              deleteFunction: deleteUser,
                              blockedUserIds: _preSelectedUserIds,
                              isChecked: _preSelectedUserIds.contains(
                                user[index].id!,
                              ),
                            ),
                          ),
                        ),
                      );
                    // Users Page State Error
                    default:
                      return Center(
                        child: Text(
                          'TPError'.tr(),
                        ),
                      );
                  }
                },
              ),
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              focusNode: app.focusNodes[10],
              heroTag: 'fab1',
              onPressed: _backPage,
              child: Icon(
                Icons.arrow_back,
                color: primary.withOpacity(.5),
              ),
            ),
            const SizedBox(width: 18),
            FloatingActionButton(
              focusNode: app.focusNodes[8],
              heroTag: 'fab2',
              onPressed: _addNewUser,
              child: Icon(
                Icons.person_add,
                color: primary.withOpacity(.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
