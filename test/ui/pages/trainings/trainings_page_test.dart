import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/data/repositories/trainings/training_repository.dart';
import 'package:trainers_stopwatch/data/repositories/users/user_repository.dart';
import 'package:trainers_stopwatch/domain/common/report/services/training_report_pdf_renderer.dart';
import 'package:trainers_stopwatch/domain/common/training/models/training.dart';
import 'package:trainers_stopwatch/domain/common/user/models/user.dart';
import 'package:trainers_stopwatch/domain/usecases/reports/send_training_report_email_use_case.dart';
import 'package:trainers_stopwatch/domain/usecases/reports/share_training_report_use_case.dart';
import 'package:trainers_stopwatch/ui/pages/trainings/trainings_page.dart';
import 'package:trainers_stopwatch/ui/pages/trainings/viewmodel/trainings_view_model.dart';

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
  final Training training;

  const _TrainingRepositoryFake(this.training);

  @override
  List<Training> trainingsForUser(int userId) =>
      training.userId == userId ? [training] : const [];

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
}

Future<
    ({
      TrainingsViewModel viewModel,
      _ShareTrainingReportFake share,
      _SendTrainingReportEmailFake email,
    })> _pumpPage(WidgetTester tester) async {
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

  final share = _ShareTrainingReportFake();
  final email = _SendTrainingReportEmailFake();

  final viewModel = TrainingsViewModel(
    userRepository: const _UserRepositoryFake(user),
    trainingRepository: _TrainingRepositoryFake(training),
    shareTrainingReport: share,
    sendTrainingReportEmail: email,
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
    expect(dependencies.viewModel.shareReportCommand.isRunning, isTrue);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.share),
          )
          .onPressed,
      isNull,
    );

    completer.complete(const Success(unit));
    await tester.pumpAndSettle();

    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(dependencies.viewModel.shareReportCommand.isSuccess, isTrue);
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
    expect(dependencies.viewModel.shareReportCommand.isFailure, isTrue);
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
    expect(dependencies.viewModel.shareReportCommand.isSuccess, isTrue);
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
      dependencies.viewModel.sendReportEmailCommand.isSuccess,
      isTrue,
    );
  });
}
