import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../common/abstract_classes/history_controller.dart';
import '../../common/models/history_model.dart';
import '../../common/models/user_model.dart';
import '../../common/models/training_model.dart';
import 'history_page_controller.dart';
import '../widgets/common/history_list_view.dart';
import 'widgets/training_informations.dart';

class HistoryPage extends StatefulWidget {
  final UserModel user;
  final TrainingModel training;

  const HistoryPage({
    super.key,
    required this.user,
    required this.training,
  });

  static const routeName = '/history';

  static HistoryPage fromContext(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final user = args['user']! as UserModel;
    final training = args['training']! as TrainingModel;

    return HistoryPage(
      user: user,
      training: training,
    );
  }

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _controller = HistoryPageController();

  String get lapMessage =>
      'Lap: ${widget.training.lapLength} ${widget.training.distanceUnit}';
  String get splitMessage =>
      'Split: ${widget.training.splitLength} ${widget.training.distanceUnit}';

  @override
  void initState() {
    super.initState();

    _controller.init(
      user: widget.user,
      training: widget.training,
      histories: <HistoryModel>[],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HPTile'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          children: [
            TrainingInformations(
                user: widget.user,
                training: widget.training,
                lapMessage: lapMessage,
                splitMessage: splitMessage),
            Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  switch (_controller.state) {
                    case StateLoading():
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    case StateSuccess():
                      return HistoryListView(
                        controller: _controller,
                        user: _controller.user,
                        training: _controller.training,
                        histories: _controller.histories,
                        updateHistory: _controller.updateHistory,
                        deleteHistory: _controller.deleteHistory,
                      );
                    default:
                      return Center(
                        child: Text('TPError'.tr()),
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
