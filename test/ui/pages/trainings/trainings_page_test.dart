import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/data/repositories/trainings/training_repository.dart';
import 'package:trainers_stopwatch/data/repositories/users/user_repository.dart';
import 'package:trainers_stopwatch/domain/common/report/models/training_report_build_outcome.dart';
import 'package:trainers_stopwatch/domain/common/report/models/training_report_content.dart';
import 'package:trainers_stopwatch/domain/common/report/models/training_report_issue.dart';
import 'package:trainers_stopwatch/domain/common/report/models/training_report_section.dart';
import 'package:trainers_stopwatch/domain/common/report/models/training_report_totals.dart';
import 'package:trainers_stopwatch/domain/common/report/services/training_report_pdf_renderer.dart';
import 'package:trainers_stopwatch/domain/common/training/models/training.dart';
import 'package:trainers_stopwatch/domain/common/training/values/distance.dart';
import 'package:trainers_stopwatch/domain/common/training/values/speed.dart';
import 'package:trainers_stopwatch/domain/common/user/models/user.dart';
import 'package:trainers_stopwatch/domain/usecases/reports/build_training_report_use_case.dart';
import 'package:trainers_stopwatch/domain/usecases/reports/send_training_report_email_use_case.dart';
import 'package:trainers_stopwatch/domain/usecases/reports/share_training_report_use_case.dart';
import 'package:trainers_stopwatch/ui/pages/trainings/trainings_page.dart';
import 'package:trainers_stopwatch/ui/pages/trainings/viewmodel/models/training_selection_state.dart';
import 'package:trainers_stopwatch/ui/pages/trainings/viewmodel/trainings_view_model.dart';
import 'package:trainers_stopwatch/ui/pages/trainings/widgets/dismissible_training.dart';
import 'package:trainers_stopwatch/ui/pages/trainings/widgets/training_report_issues_dialog.dart';

class _TestAssetLoader extends AssetLoader {
  const _TestAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async => const {
        'TPTitle': 'Treinamentos',
        'TPShare': 'Compartilhar',
        'GenericRemove': 'Remover',
        'TPSelectAll': 'Selecionar Todos',
        'TPDeselectAll': 'Desmarcar Todos',
        'TPTrainings': 'Treinamentos',
        'TPSelectUser': 'Selecionar Usuário:',
        'GenericEdit': 'Editar',
        'GenericDelete': 'Deletar',
        'TPError': 'Desculpe. Ocorreu um erro!',
        'TPReportTitle': 'Relatório de Treinos',
        'TPReportUser': 'Usuário',
        'TPReportDate': 'Data',
        'TPReportTotalDistance': 'Distância total',
        'TPReportTotalTime': 'Tempo total',
        'TPReportAverageSpeed': 'Velocidade média',
        'TPReportLapDistance': 'Distância da volta',
        'TPReportSplitDistance': 'Distância parcial',
        'TPReportLapCount': 'Número de voltas',
        'TPReportEvent': 'Evento',
        'TPReportTime': 'Tempo',
        'TPReportSpeed': 'Velocidade',
        'TPReportComments': 'Comentários',
        'TPReportTrainingStarted': 'Início do treinamento',
        'TPReportSplit': 'Parcial',
        'TPReportLap': 'Volta',
        'TPReportSubject': 'Relatório de treinos',
        'TPReportEmailBody': '<p>O relatório de treinos está anexado.</p>',
        'TPNoTrainings': 'Nenhum treinamento registrado',
        'TPTrainingStateUnselected': 'Treino não selecionado',
        'TPTrainingStateSelected': 'Treino selecionado',
        'TPTrainingStateRejected': 'Treino rejeitado no relatório',
        'TPReportRejectedTitle': 'Relatório não gerado',
        'TPReportRejectedMessage':
            'Nenhum dos treinos selecionados pôde ser incluído no relatório:',
        'TPReportIssueTitle': 'Treino não incluído',
        'TPReportIssueNoMeasurements': 'Este treino não possui medições.',
        'TPReportIssueHistoryUnavailable':
            'Não foi possível carregar o histórico deste treino.',
        'TPReportIssueInconsistentHistory':
            'O histórico deste treino está inconsistente.',
        'TPReportIssueUnknown':
            'Não foi possível incluir este treino no relatório.',
        'GenericClose': 'Fechar',
        'TPReportPartialTitle': 'Alguns treinos não foram incluídos',
        'TPReportPartialMessage':
            'Os seguintes treinos não puderam ser incluídos no relatório:',
        'TPReportPartialValidCount':
            'O relatório será gerado com {} treino(s).',
        'GenericCancel': 'Cancelar',
        'GenericContinue': 'Continuar',
      };
}

class _UserRepositoryFake implements UserRepository {
  final User user;

  const _UserRepositoryFake(this.user);

  @override
  List<User> get users => [user];

  @override
  AsyncResult<List<User>> loadAll() async => Success([user]);

  @override
  AsyncResult<User> insert(User user) async => Success(user);

  @override
  AsyncResult<Unit> update(User user) async => const Success(unit);

  @override
  AsyncResult<Unit> delete(int id) async => const Success(unit);

  @override
  AsyncResult<List<String>> readPhotoReferences() async => const Success([]);
}

class _TrainingRepositoryFake implements TrainingRepository {
  final List<Training> trainings;

  _TrainingRepositoryFake(List<Training> trainings)
      : trainings = List.unmodifiable(trainings);

  @override
  List<Training> trainingsForUser(int userId) => List.unmodifiable(
        trainings.where((training) => training.userId == userId),
      );

  @override
  AsyncResult<List<Training>> loadForUser(int userId) async =>
      Success(trainingsForUser(userId));

  @override
  AsyncResult<Training> insert(Training training) async => Success(training);

  @override
  AsyncResult<Unit> update(Training training) async => const Success(unit);

  @override
  AsyncResult<Unit> delete(Training training) async => const Success(unit);
}

class _ShareTrainingReportFake implements ShareTrainingReportUseCase {
  int calls = 0;
  AsyncResult<Unit> result = Future.value(const Success(unit));

  @override
  AsyncResult<Unit> execute({
    required User user,
    required List<Training> trainings,
    required TrainingReportPdfTexts texts,
    required String subject,
    String suggestedName = 'training_logs.pdf',
  }) {
    calls++;
    return result;
  }

  @override
  AsyncResult<Unit> executeFromContent({
    required TrainingReportContent content,
    required TrainingReportPdfTexts texts,
    required String subject,
    String suggestedName = 'training_logs.pdf',
  }) {
    calls++;
    return result;
  }
}

class _SendTrainingReportEmailFake implements SendTrainingReportEmailUseCase {
  int calls = 0;
  AsyncResult<Unit> result = Future.value(const Success(unit));

  @override
  AsyncResult<Unit> execute({
    required User user,
    required List<Training> trainings,
    required TrainingReportPdfTexts texts,
    required List<String> recipients,
    required String subject,
    required String htmlBody,
    String suggestedName = 'training_logs.pdf',
  }) {
    calls++;
    return result;
  }

  @override
  AsyncResult<Unit> executeFromContent({
    required TrainingReportContent content,
    required TrainingReportPdfTexts texts,
    required List<String> recipients,
    required String subject,
    required String htmlBody,
    String suggestedName = 'training_logs.pdf',
  }) {
    calls++;
    return result;
  }
}

class _BuildTrainingReportFake implements BuildTrainingReportUseCase {
  Result<TrainingReportBuildOutcome>? outcome;

  TrainingReportContent _content(
    User user,
    List<Training> trainings,
  ) {
    return TrainingReportContent(
      user: user,
      sections: trainings
          .map(
            (training) => TrainingReportSection(
              training: training,
              rows: const [],
              totals: TrainingReportTotals(
                distance: Distance.create(value: 0).value!,
                duration: Duration.zero,
                lapCount: 0,
                averageSpeed: Speed.create(value: 0).value!,
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  AsyncResult<TrainingReportContent> execute({
    required User user,
    required List<Training> trainings,
  }) async =>
      Success(_content(user, trainings));

  @override
  AsyncResult<TrainingReportBuildOutcome> buildOutcome({
    required User user,
    required List<Training> trainings,
  }) async {
    return outcome ??
        Success(
          TrainingReportBuildOutcome(
            content: _content(user, trainings),
            issues: const [],
          ),
        );
  }
}

Future<
    ({
      TrainingsViewModel viewModel,
      _ShareTrainingReportFake share,
      _SendTrainingReportEmailFake email,
      _BuildTrainingReportFake build,
    })> _pumpPage(
  WidgetTester tester, {
  bool hasTraining = true,
  bool hasSecondTraining = false,
}) async {
  const user = User(
    id: 1,
    name: 'Ana',
    email: 'ana@example.com',
  );

  final training = Training.create(
    id: 10,
    userId: 1,
    date: DateTime(2026, 8, 26, 10),
    comments: 'Treino de velocidade',
  ).value!;

  final secondTraining = Training.create(
    id: 11,
    userId: 1,
    date: DateTime(2026, 8, 27, 11),
    comments: 'Treino intervalado',
  ).value!;

  final share = _ShareTrainingReportFake();
  final email = _SendTrainingReportEmailFake();
  final build = _BuildTrainingReportFake();
  final viewModel = TrainingsViewModel(
    userRepository: const _UserRepositoryFake(user),
    trainingRepository: _TrainingRepositoryFake(
      hasTraining
          ? [
              training,
              if (hasSecondTraining) secondTraining,
            ]
          : const [],
    ),
    shareTrainingReport: share,
    sendTrainingReportEmail: email,
    buildTrainingReport: build,
  );

  await viewModel.selectUser(user.id!);

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
        Locale('es'),
      ],
      path: 'assets/translations',
      assetLoader: const _TestAssetLoader(),
      fallbackLocale: const Locale('en', 'US'),
      startLocale: const Locale('pt', 'BR'),
      child: Builder(
        builder: (context) => MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          home: TrainingsPage(viewModel: viewModel),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return (
    viewModel: viewModel,
    share: share,
    email: email,
    build: build,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/shared_preferences'),
      (call) async => call.method == 'getAll' ? <String, Object>{} : true,
    );
    await EasyLocalization.ensureInitialized();
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/shared_preferences'),
      null,
    );
  });

  testWidgets('enables the report menu only after selecting a training',
      (tester) async {
    await _pumpPage(tester);

    final menuButton = find.widgetWithIcon(IconButton, Icons.share);

    expect(
      tester.widget<IconButton>(menuButton).onPressed,
      isNull,
    );

    await tester.tap(find.text('Treino de velocidade'));
    await tester.pump();

    expect(
      tester.widget<IconButton>(menuButton).onPressed,
      isNotNull,
    );
  });

  testWidgets('shows an empty state when the user has no trainings',
      (tester) async {
    await _pumpPage(tester, hasTraining: false);

    expect(
      find.text('Nenhum treinamento registrado'),
      findsOneWidget,
    );
    expect(find.byType(DismissibleTraining), findsNothing);
  });

  testWidgets('shows progress and disables the menu while sharing',
      (tester) async {
    final dependencies = await _pumpPage(tester);
    final completer = Completer<Result<Unit>>();
    dependencies.share.result = completer.future;

    await tester.tap(find.text('Treino de velocidade'));
    await tester.pump();

    await tester.tap(find.byTooltip('Show menu'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Compartilhar'));
    await tester.pump();
    await tester.pump();

    expect(dependencies.share.calls, 1);
    expect(dependencies.viewModel.sharePreparedReportCommand.isRunning, isTrue);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.share),
          )
          .onPressed,
      isNull,
    );

    expect(
      tester
          .widget<DropdownButton<int>>(
            find.byType(DropdownButton<int>),
          )
          .onChanged,
      isNull,
    );

    expect(
      tester
          .widget<Dismissible>(
            find.byType(Dismissible),
          )
          .direction,
      DismissDirection.none,
    );

    expect(
      tester
          .widget<ListTile>(
            find.widgetWithText(ListTile, 'Treino de velocidade'),
          )
          .onTap,
      isNull,
    );

    completer.complete(const Success(unit));
    await tester.pumpAndSettle();

    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(dependencies.viewModel.sharePreparedReportCommand.isSuccess, isTrue);
  });

  testWidgets('shows visible feedback when report sharing fails',
      (tester) async {
    final dependencies = await _pumpPage(tester);
    dependencies.share.result = Future.value(
      const Failure(
        AppError(
          code: AppErrorCode.unknown,
          message: 'share failed',
        ),
      ),
    );

    await tester.tap(find.text('Treino de velocidade'));
    await tester.pump();

    await tester.tap(find.byTooltip('Show menu'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Compartilhar'));
    await tester.pumpAndSettle();

    expect(
      find.text('Desculpe. Ocorreu um erro!'),
      findsOneWidget,
    );
    expect(dependencies.viewModel.sharePreparedReportCommand.isFailure, isTrue);
    expect(
      dependencies.viewModel.lastError?.code,
      AppErrorCode.unknown,
    );
  });

  testWidgets('dispatches the share command from the report menu',
      (tester) async {
    final dependencies = await _pumpPage(tester);

    await tester.tap(find.text('Treino de velocidade'));
    await tester.pump();

    await tester.tap(find.byTooltip('Show menu'));
    await tester.pumpAndSettle();

    expect(find.text('Compartilhar'), findsOneWidget);

    await tester.tap(find.text('Compartilhar'));
    await tester.pumpAndSettle();

    expect(dependencies.share.calls, 1);
    expect(dependencies.email.calls, 0);
    expect(dependencies.viewModel.sharePreparedReportCommand.isSuccess, isTrue);
  });

  testWidgets('dispatches the email command from the report menu',
      (tester) async {
    final dependencies = await _pumpPage(tester);

    await tester.tap(find.text('Treino de velocidade'));
    await tester.pump();

    await tester.tap(find.byTooltip('Show menu'));
    await tester.pumpAndSettle();

    expect(find.text('Email'), findsOneWidget);

    await tester.tap(find.text('Email'));
    await tester.pumpAndSettle();

    expect(dependencies.email.calls, 1);
    expect(dependencies.share.calls, 0);
    expect(
      dependencies.viewModel.sendPreparedReportEmailCommand.isSuccess,
      isTrue,
    );
  });

  testWidgets('shows unselected and selected training indicators',
      (tester) async {
    await _pumpPage(tester);

    expect(
      find.byIcon(Icons.radio_button_unchecked),
      findsOneWidget,
    );
    expect(
      find.byTooltip('Treino não selecionado'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.check_circle), findsNothing);

    await tester.tap(find.text('Treino de velocidade'));
    await tester.pump();

    expect(find.byIcon(Icons.radio_button_unchecked), findsNothing);
    expect(
      find.byIcon(Icons.check_circle),
      findsOneWidget,
    );
    expect(
      find.byTooltip('Treino selecionado'),
      findsOneWidget,
    );
  });

  testWidgets('shows rejected indicator and its report issue', (tester) async {
    final dependencies = await _pumpPage(tester);
    final training = dependencies.viewModel.trainings.single;

    dependencies.build.outcome = Success(
      TrainingReportBuildOutcome(
        content: TrainingReportContent(
          user: dependencies.viewModel.selectedUser!,
          sections: const [],
        ),
        issues: [
          TrainingReportIssue(
            training: training,
            error: const AppError(
              code: AppErrorCode.zeroElapsedTime,
              message: 'Training has no measurements.',
            ),
          ),
        ],
      ),
    );

    await tester.tap(find.text('Treino de velocidade'));
    await tester.pump();

    await tester.tap(find.byTooltip('Show menu'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Compartilhar'));
    await tester.pumpAndSettle();

    expect(find.text('Relatório não gerado'), findsOneWidget);

    final issuesList = find.descendant(
      of: find.byType(TrainingReportIssuesDialog),
      matching: find.byType(ListView),
    );

    expect(issuesList, findsOneWidget);
    expect(
      tester.widget<ListView>(issuesList).shrinkWrap,
      isTrue,
    );

    expect(
      find.textContaining('Este treino não possui medições.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.error), findsOneWidget);
    expect(
      find.byTooltip('Treino rejeitado no relatório'),
      findsOneWidget,
    );
    expect(dependencies.viewModel.selectedTrainingIds, isEmpty);
    expect(dependencies.share.calls, 0);

    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byTooltip('Treino rejeitado no relatório'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Treino não incluído'), findsOneWidget);
    expect(
      find.text('Este treino não possui medições.'),
      findsOneWidget,
    );
    expect(dependencies.viewModel.selectedTrainingIds, isEmpty);
  });

  testWidgets('continues sharing only after confirming a partial report',
      (tester) async {
    final dependencies = await _pumpPage(
      tester,
      hasSecondTraining: true,
    );

    final valid = dependencies.viewModel.trainings.first;
    final rejected = dependencies.viewModel.trainings.last;

    dependencies.build.outcome = Success(
      TrainingReportBuildOutcome(
        content: TrainingReportContent(
          user: dependencies.viewModel.selectedUser!,
          sections: [
            TrainingReportSection(
              training: valid,
              rows: const [],
              totals: TrainingReportTotals(
                distance: Distance.create(value: 0).value!,
                duration: Duration.zero,
                lapCount: 0,
                averageSpeed: Speed.create(value: 0).value!,
              ),
            ),
          ],
        ),
        issues: [
          TrainingReportIssue(
            training: rejected,
            error: const AppError(
              code: AppErrorCode.zeroElapsedTime,
              message: 'Training has no measurements.',
            ),
          ),
        ],
      ),
    );

    dependencies.viewModel.selectAll();
    await tester.pump();

    await tester.tap(find.byTooltip('Show menu'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Compartilhar'));
    await tester.pumpAndSettle();

    expect(
      find.text('Alguns treinos não foram incluídos'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Este treino não possui medições.'),
      findsOneWidget,
    );
    expect(
      find.text('O relatório será gerado com 1 treino(s).'),
      findsOneWidget,
    );

    expect(dependencies.share.calls, 0);
    expect(dependencies.viewModel.selectedTrainingIds, {valid.id});
    expect(
      dependencies.viewModel.selectionStateFor(rejected),
      TrainingSelectionState.rejected,
    );

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(dependencies.share.calls, 1);
    expect(
      dependencies.viewModel.sharePreparedReportCommand.isSuccess,
      isTrue,
    );
    expect(find.byType(TrainingReportIssuesDialog), findsNothing);
  });

  testWidgets('canceling a partial report keeps rejected training deselected',
      (tester) async {
    final dependencies = await _pumpPage(
      tester,
      hasSecondTraining: true,
    );

    final valid = dependencies.viewModel.trainings.first;
    final rejected = dependencies.viewModel.trainings.last;

    dependencies.build.outcome = Success(
      TrainingReportBuildOutcome(
        content: TrainingReportContent(
          user: dependencies.viewModel.selectedUser!,
          sections: [
            TrainingReportSection(
              training: valid,
              rows: const [],
              totals: TrainingReportTotals(
                distance: Distance.create(value: 0).value!,
                duration: Duration.zero,
                lapCount: 0,
                averageSpeed: Speed.create(value: 0).value!,
              ),
            ),
          ],
        ),
        issues: [
          TrainingReportIssue(
            training: rejected,
            error: const AppError(
              code: AppErrorCode.zeroElapsedTime,
              message: 'Training has no measurements.',
            ),
          ),
        ],
      ),
    );

    dependencies.viewModel.selectAll();
    await tester.pump();

    await tester.tap(find.byTooltip('Show menu'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Compartilhar'));
    await tester.pumpAndSettle();

    expect(
      find.text('Alguns treinos não foram incluídos'),
      findsOneWidget,
    );
    expect(dependencies.share.calls, 0);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.byType(TrainingReportIssuesDialog), findsNothing);
    expect(dependencies.share.calls, 0);

    expect(dependencies.viewModel.selectedTrainingIds, {valid.id});
    expect(
      dependencies.viewModel.selectionStateFor(valid),
      TrainingSelectionState.selected,
    );
    expect(
      dependencies.viewModel.selectionStateFor(rejected),
      TrainingSelectionState.rejected,
    );

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.error), findsOneWidget);
  });

  testWidgets('continues email only after confirming a partial report',
      (tester) async {
    final dependencies = await _pumpPage(
      tester,
      hasSecondTraining: true,
    );

    final valid = dependencies.viewModel.trainings.first;
    final rejected = dependencies.viewModel.trainings.last;

    dependencies.build.outcome = Success(
      TrainingReportBuildOutcome(
        content: TrainingReportContent(
          user: dependencies.viewModel.selectedUser!,
          sections: [
            TrainingReportSection(
              training: valid,
              rows: const [],
              totals: TrainingReportTotals(
                distance: Distance.create(value: 0).value!,
                duration: Duration.zero,
                lapCount: 0,
                averageSpeed: Speed.create(value: 0).value!,
              ),
            ),
          ],
        ),
        issues: [
          TrainingReportIssue(
            training: rejected,
            error: const AppError(
              code: AppErrorCode.zeroElapsedTime,
              message: 'Training has no measurements.',
            ),
          ),
        ],
      ),
    );

    dependencies.viewModel.selectAll();
    await tester.pump();

    await tester.tap(find.byTooltip('Show menu'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Email'));
    await tester.pumpAndSettle();

    expect(
      find.text('Alguns treinos não foram incluídos'),
      findsOneWidget,
    );
    expect(dependencies.email.calls, 0);
    expect(dependencies.share.calls, 0);
    expect(dependencies.viewModel.selectedTrainingIds, {valid.id});
    expect(
      dependencies.viewModel.selectionStateFor(rejected),
      TrainingSelectionState.rejected,
    );

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(dependencies.email.calls, 1);
    expect(dependencies.share.calls, 0);
    expect(
      dependencies.viewModel.sendPreparedReportEmailCommand.isSuccess,
      isTrue,
    );
    expect(find.byType(TrainingReportIssuesDialog), findsNothing);
  });

  testWidgets('shows global preparation failure without opening partial dialog',
      (tester) async {
    final dependencies = await _pumpPage(tester);

    dependencies.build.outcome = const Failure(
      AppError(
        code: AppErrorCode.storageReadFailed,
        message: 'Could not prepare the report.',
      ),
    );

    await tester.tap(find.text('Treino de velocidade'));
    await tester.pump();

    await tester.tap(find.byTooltip('Show menu'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Compartilhar'));
    await tester.pumpAndSettle();

    expect(
      dependencies.viewModel.prepareReportCommand.isFailure,
      isTrue,
    );
    expect(
      dependencies.viewModel.lastError?.code,
      AppErrorCode.storageReadFailed,
    );

    expect(
      find.text('Desculpe. Ocorreu um erro!'),
      findsOneWidget,
    );
    expect(find.byType(TrainingReportIssuesDialog), findsNothing);

    expect(dependencies.share.calls, 0);
    expect(dependencies.email.calls, 0);
    expect(
      dependencies.viewModel.selectedTrainingIds,
      {dependencies.viewModel.trainings.single.id},
    );
  });
}
