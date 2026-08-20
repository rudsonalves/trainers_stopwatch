import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/common/functions/share_functions.dart';
import '/common/icons/stopwatch_icons_icons.dart';
import '/common/theme/app_font_style.dart';
import '/core/routing/route_arguments.dart';
import '/core/routing/routes.dart';
import '/domain/common/training/models/training.dart';
import '/features/widgets/common/generic_dialog.dart';
import '/features/widgets/common/user_card.dart';
import 'viewmodel/trainings_view_model.dart';
import 'widgets/dismissible_training.dart';
import 'widgets/select_user_popup_menu.dart';

class TrainingsPage extends StatefulWidget {
  final TrainingsViewModel viewModel;
  final AppShare appShare;

  const TrainingsPage({
    super.key,
    required this.viewModel,
    required this.appShare,
  });

  @override
  State<TrainingsPage> createState() => _TrainingsPageState();
}

class _TrainingsPageState extends State<TrainingsPage> {
  TrainingsViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    viewModel.loadUsers();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Future<void> _openHistory(Training training) => context.pushNamed(
        MainRoutes.history.routeName,
        extra: HistoryRouteArguments(
          user: viewModel.selectedUser!,
          training: training,
        ),
      );

  Future<bool> _removeTraining(Training training) async {
    final confirmed = await GenericDialog.open(
      context,
      title: 'TPRemoveTrainingTitle'.tr(),
      message: 'TPRemoveTrainingMsg'.tr(),
      actions: DialogActions.yesNo,
    );
    if (!confirmed) return false;
    await viewModel.delete(training);
    return viewModel.deleteCommand.isSuccess;
  }

  Future<void> _removeSelected() async {
    final confirmed = await GenericDialog.open(
      context,
      title: 'TPRemoveSelectedTitle'.tr(),
      message: 'TPRemoveSelectedMsg'.tr(),
      actions: DialogActions.yesNo,
    );
    if (confirmed) await viewModel.deleteSelected();
  }

  void _sendEmail() {
    final user = viewModel.selectedUser;
    if (user == null) return;
    widget.appShare.sendEmail(
      user: user,
      recipient: user.email,
      trainings: viewModel.selectedTrainings,
    );
  }

  void _sendWhatsApp() {
    final user = viewModel.selectedUser;
    if (user == null) return;
    widget.appShare.sendWhatsApp(
      user: user,
      trainings: viewModel.selectedTrainings,
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    if (viewModel.loadUsersCommand.isRunning && viewModel.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.loadUsersCommand.isFailure && viewModel.users.isEmpty) {
      return Center(child: Text('TPError'.tr()));
    }

    return Column(
      children: [
        SelectUserPopupMenu(
          colorScheme: colorScheme,
          users: viewModel.users,
          selectedUserId: viewModel.selectedUserId,
          onSelected: (id) {
            if (id != null) viewModel.selectUser(id);
          },
        ),
        if (viewModel.selectedUser case final user?)
          UserCard(
            isChecked: true,
            name: user.name,
            email: user.email,
            phone: user.phone,
            photoReference: user.photoReference,
          ),
        if (viewModel.lastError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('TPError'.tr()),
          ),
        OverflowBar(
          alignment: MainAxisAlignment.spaceAround,
          children: [
            MenuAnchor(
              builder: (context, controller, child) => IconButton.filledTonal(
                onPressed: viewModel.hasSelectedTrainings
                    ? () => controller.isOpen
                        ? controller.close()
                        : controller.open()
                    : null,
                icon: const Icon(Icons.share),
                tooltip: 'Show menu',
              ),
              menuChildren: [
                MenuItemButton(
                  onPressed: _sendEmail,
                  child: const Row(children: [
                    Icon(StopwatchIcons.mail, color: Colors.amber),
                    SizedBox(width: 12),
                    Text('Email'),
                  ]),
                ),
                MenuItemButton(
                  onPressed: _sendWhatsApp,
                  child: const Row(children: [
                    Icon(StopwatchIcons.whatsapp, color: Colors.green),
                    SizedBox(width: 12),
                    Text('WhatsApp'),
                  ]),
                ),
              ],
            ),
            IconButton.filledTonal(
              onPressed:
                  viewModel.hasSelectedTrainings ? _removeSelected : null,
              tooltip: 'GenericRemove'.tr(),
              icon: const Icon(Icons.delete),
            ),
            IconButton.filledTonal(
              onPressed: viewModel.trainings.isEmpty
                  ? null
                  : viewModel.areAllTrainingsSelected
                      ? viewModel.clearSelection
                      : viewModel.selectAll,
              tooltip: viewModel.areAllTrainingsSelected
                  ? 'TPDeselectAll'.tr()
                  : 'TPSelectAll'.tr(),
              icon: Icon(viewModel.areAllTrainingsSelected
                  ? Icons.deselect
                  : Icons.select_all),
            ),
          ],
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.secondaryContainer),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('TPTrainings'.tr(),
                      style: AppFontStyle.roboto18SemiBold),
                ),
                if (viewModel.loadTrainingsCommand.isRunning)
                  const LinearProgressIndicator(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListView.builder(
                      itemCount: viewModel.trainings.length,
                      itemBuilder: (context, index) {
                        final training =
                            viewModel.trainings.reversed.elementAt(index);
                        return DismissibleTraining(
                          training: training,
                          openHistory: _openHistory,
                          removeTraining: _removeTraining,
                          onSelect: (training) => viewModel.setSelected(
                            training,
                            selected: !viewModel.isSelected(training),
                          ),
                          selected: viewModel.isSelected(training),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('TPTitle'.tr()), elevation: 5),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) => _buildBody(Theme.of(context).colorScheme),
          ),
        ),
      );
}
