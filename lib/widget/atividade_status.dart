import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:user_activity_plugin/user_activity_plugin.dart';
import 'package:window_manager/window_manager.dart';  // novo import

enum UserStatus { offline, away, online }

int currentUserId = 1;

class ActivityStatusWatcher extends StatefulWidget {
  final Widget child;
  final Duration awayTimeout;
  final void Function(UserStatus status)? onStatusChanged;
  final GraphQLClient graphqlClient;

  const ActivityStatusWatcher({
    Key? key,
    required this.child,
    required this.graphqlClient,
    this.awayTimeout = const Duration(seconds: 10),
    this.onStatusChanged,
  }) : super(key: key);

  @override
  _ActivityStatusWatcherState createState() => _ActivityStatusWatcherState();
}

class _ActivityStatusWatcherState extends State<ActivityStatusWatcher>
    with WidgetsBindingObserver, WindowListener {
  UserStatus _status = UserStatus.online;

  static const String updateStatusMutation = r'''
    mutation updateUserStatus($userId: Int!, $status: Int!) {
      update_users_by_pk(pk_columns: {id: $userId}, _set: {status: $status}) {
        id
        status
      }
    }
  ''';

  final Duration _checkIdleInterval = Duration(seconds: 5);
  Timer? _idleCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Inicializar o window_manager
    windowManager.addListener(this);

    _setStatus(UserStatus.online, force: true);
    _startIdleCheckTimer();
  }

  @override
  void dispose() {
    _idleCheckTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  DateTime _lastActive = DateTime.now();

  void _startIdleCheckTimer() {
    _idleCheckTimer?.cancel();
    _idleCheckTimer = Timer.periodic(_checkIdleInterval, (_) async {
      try {
        final now = DateTime.now();
        await UserActivityPlugin.setIdleThreshold(Duration(seconds: 15));
        final isIdle = await UserActivityPlugin.isUserIdle();
        // ignore: avoid_print
        print("⌛ Agora: $now | Está inativo? $isIdle");

        if (isIdle) {
          _setStatus(UserStatus.away);
        } else {
          _setStatus(UserStatus.online);
          _lastActive = now; // Reset manual também
        }
      } catch (e) {
        // ignore: avoid_print
        print("Erro ao verificar inatividade via plugin: $e");
      }
    });
  }

  void _onUserInteraction() {
    _lastActive = DateTime.now();
    _setStatus(UserStatus.online);
  }

  Future<void> _setStatus(UserStatus status, {bool force = false}) async {
    if (_status != status || force) {
      setState(() => _status = status);
      widget.onStatusChanged?.call(status);
      await _updateStatusOnServer(status);
    }
  }

  Future<void> _updateStatusOnServer(UserStatus status) async {
    final statusInt = status.index;
    final options = MutationOptions(
      document: gql(updateStatusMutation),
      variables: {
        'userId': currentUserId,
        'status': statusInt,
      },
    );

    final result = await widget.graphqlClient.mutate(options);
    if (result.hasException) {
      // ignore: avoid_print
      print("Erro ao atualizar status: ${result.exception.toString()}");
    } else {
      // ignore: avoid_print
      print("Status atualizado no servidor: $statusInt");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _setStatus(UserStatus.offline);
      _idleCheckTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      _setStatus(UserStatus.online, force: true);
      _startIdleCheckTimer();
    }
  }

  // CALLBACK do window_manager para quando o usuário fecha a janela
  @override
  void onWindowClose() async {
    await _setStatus(UserStatus.offline);
    // permite fechar a janela após atualizar status
    await windowManager.destroy();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _onUserInteraction,
      onPanDown: (_) => _onUserInteraction(),
      child: widget.child,
    );
  }
}
