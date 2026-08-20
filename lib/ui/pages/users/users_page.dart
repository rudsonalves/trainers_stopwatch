// Copyright (C) 2024 Rudson Alves
//
// This file is part of trainers_stopwatch.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/common/adapters/user_domain_adapter.dart';
import '/domain/common/user/models/user.dart';
import '/features/stopwatch_page/stopwatch_page_controller.dart';
import '/features/widgets/common/generic_dialog.dart';
import 'viewmodel/users_view_model.dart';
import 'widgets/dismissible_user_tile.dart';
import 'widgets/user_dialog/user_dialog.dart';

class UsersPage extends StatefulWidget {
  final UsersViewModel viewModel;
  final StopwatchPageController stopwatchController;

  const UsersPage({
    super.key,
    required this.viewModel,
    required this.stopwatchController,
  });

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  UsersViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    viewModel.load();
  }

  Future<void> _addNewUser() async {
    final result = await UserDialog.open(
      context,
      prepareImage: viewModel.prepareImage,
      discardImage: viewModel.discardPreparedImage,
    );
    if (result == null) return;
    await viewModel.add(
      user: result.user,
      preparedImage: result.preparedImage,
    );
  }

  void _backPage() => context.pop();

  void _selectUser(bool selected, User user) =>
      viewModel.setSelected(user, selected: selected);

  Future<bool> _editUser(User user) async {
    final result = await UserDialog.open(
      context,
      user: user,
      prepareImage: viewModel.prepareImage,
      discardImage: viewModel.discardPreparedImage,
    );
    if (result == null) return false;

    await viewModel.edit(
      user: result.user,
      preparedImage: result.preparedImage,
    );
    return viewModel.editCommand.isSuccess;
  }

  Future<bool> _deleteUser(User user) async {
    if (viewModel.isSelected(user)) {
      await GenericDialog.open(
        context,
        title: 'APBlockedTitle'.tr(),
        message: 'APBlockedMsg'.tr(),
        actions: DialogActions.close,
      );
      return false;
    }

    final confirmed = await GenericDialog.open(
      context,
      title: 'APDeleteUser'.tr(),
      message: 'APDeleteUserMsg'.tr(),
      actions: DialogActions.yesNo,
    );
    if (!confirmed) return false;

    await viewModel.delete(user);
    return viewModel.deleteCommand.isSuccess;
  }

  Widget _buildBody() {
    if (viewModel.loadCommand.isRunning && viewModel.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.loadCommand.isFailure && viewModel.users.isEmpty) {
      return Center(child: Text('TPError'.tr()));
    }

    if (viewModel.users.isEmpty) {
      return Center(child: Text('APRegisterSome'.tr()));
    }

    return Column(
      children: [
        if (viewModel.lastError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('TPError'.tr()),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: viewModel.users.length,
            itemBuilder: (context, index) {
              final user = viewModel.users[index];
              return DismissibleUserTile(
                user: user,
                selectUser: _selectUser,
                editFunction: _editUser,
                deleteFunction: _deleteUser,
                blockedUserIds: viewModel.activeUserIds.toList(),
                isChecked: viewModel.isSelected(user),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) return;
        widget.stopwatchController.addNewUsers(
          viewModel.selectedUsers.map((user) => user.toLegacy()).toList(),
        );
      },
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          elevation: 5,
          title: Text('APUserList'.tr()),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: ListenableBuilder(
            listenable: viewModel,
            builder: (context, child) => _buildBody(),
          ),
        ),
        floatingActionButton: ListenableBuilder(
          listenable: viewModel,
          builder: (context, child) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: 'fab1',
                onPressed: _backPage,
                child: Icon(
                  Icons.arrow_back,
                  color: primary.withValues(alpha: .5),
                ),
              ),
              const SizedBox(width: 18),
              FloatingActionButton(
                heroTag: 'fab2',
                onPressed: viewModel.isLoading ? null : _addNewUser,
                child: Icon(
                  Icons.person_add,
                  color: primary.withValues(alpha: .5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
