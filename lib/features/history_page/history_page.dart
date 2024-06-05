import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../common/theme/app_font_style.dart';
import '../../models/user_model.dart';
import '../../models/training_model.dart';
import '../widgets/edit_training_dialog/edit_training_dialog.dart';
import 'history_page_controller.dart';
import 'history_page_state.dart';
import 'widgets/card_history.dart';

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
  late final UserModel user;
  late final TrainingModel training;

  String get lapMessage =>
      'Lap: ${training.lapLength} ${training.distanceUnit}';
  String get splitMessage =>
      'Split: ${training.splitLength} ${training.distanceUnit}';

  @override
  void initState() {
    super.initState();
    training = widget.training;
    user = widget.user;
    _controller.init(training);
  }

  Widget _cardHeader() {
    return InkWell(
      onTap: () async {
        await EditTrainingDialog.open(
          context,
          userName: user.name,
          training: training,
        );
      },
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  user.name,
                  style: AppFontStyle.roboto18SemiBold,
                ),
              ),
              const Divider(),
              Text(
                'HPTrainingDistances'.tr(),
                style: AppFontStyle.roboto16SemiBold,
              ),
              Text(lapMessage),
              Text(splitMessage),
              Text(
                'ETDComments'.tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(training.comments ?? '-'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('HPTile'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          children: [
            _cardHeader(),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary,
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    switch (_controller.state) {
                      case HistoryPageStateLoading():
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      case HistoryPageStateSuccess():
                        String startMessage = _controller.trainingStatistic();
                        return ListView.builder(
                          itemCount: _controller.histories.length,
                          itemBuilder: (context, index) => CardHistory(
                            history: _controller.histories[index],
                            startMessage: startMessage,
                          ),
                        );
                      default:
                        return Center(
                          child: Text('TPError'.tr()),
                        );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
