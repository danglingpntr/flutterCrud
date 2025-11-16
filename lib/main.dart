import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'core/env_config.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/widgets/auth_screen.dart';
import 'features/tasks/controllers/task_controller.dart';
import 'features/tasks/widgets/task_list_screen.dart';
import 'services/auth_service.dart';
import 'services/task_live_query.dart';
import 'services/task_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();
  await Parse().initialize(
    EnvConfig.appId,
    EnvConfig.serverUrl,
    clientKey: EnvConfig.clientKey,
    liveQueryUrl: EnvConfig.liveQueryUrl,
    autoSendSessionId: true,
    debug: EnvConfig.isDebugLoggingEnabled,
  );

  final initialUser = await AuthService().getCachedUser();
  runApp(TaskManagerApp(initialUser: initialUser));
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key, this.initialUser});

  final ParseUser? initialUser;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<TaskService>(create: (_) => TaskService()),
        Provider<TaskLiveQueryService>(create: (_) => TaskLiveQueryService()),
        ChangeNotifierProvider(
          create: (context) => AuthController(
            authService: context.read<AuthService>(),
            initialUser: initialUser,
          ),
        ),
        ChangeNotifierProxyProvider<AuthController, TaskController>(
          create: (context) => TaskController(
            taskService: context.read<TaskService>(),
            liveQueryService: context.read<TaskLiveQueryService>(),
          ),
          update: (context, authController, taskController) {
            final controller = taskController ??
                TaskController(
                  taskService: context.read<TaskService>(),
                  liveQueryService: context.read<TaskLiveQueryService>(),
                );
            controller.attachUser(authController.user);
            return controller;
          },
        ),
      ],
      child: Consumer<AuthController>(
        builder: (context, authController, _) {
          return MaterialApp(
            title: 'Task Manager',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            home: authController.isAuthenticated
                ? const TaskListScreen()
                : const AuthScreen(),
          );
        },
      ),
    );
  }
}
