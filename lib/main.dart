import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_single_instance/flutter_single_instance.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:app_desktop/widget/atividade_status.dart'; // seu watcher atualizado
import 'package:app_desktop/rotas/rotas.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();

  final instance = FlutterSingleInstance();

  if (await instance.isFirstInstance()) {
    final HttpLink httpLink = HttpLink('http://xxx.xxx.xxx.xxx:xxxx/xxx/xxx');

    final WebSocketLink websocketLink = WebSocketLink(
      'ws://xxx.xxx.xxx.xxx:xxx/xxx/xxx',
      config: SocketClientConfig(
        autoReconnect: true,
        inactivityTimeout: Duration(seconds: 30),
      ),
    );

    final Link link = Link.split(
      (request) => request.isSubscription,
      websocketLink,
      httpLink,
    );

    final client = ValueNotifier(
      GraphQLClient(
        link: link,
        cache: GraphQLCache(store: HiveStore()),
      ),
    );

    runApp(MainApp(client: client));
  } else {
    exit(0);
  }
}

class MainApp extends StatelessWidget {
  final ValueNotifier<GraphQLClient> client;

  const MainApp({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: ActivityStatusWatcher(
        graphqlClient: client.value,
        onStatusChanged: (status) {
          // ignore: avoid_print
          print("Status do utilizador mudou: $status");
          // Aqui pode disparar outras ações, se quiser
        },
        child: MaterialApp.router(
          routerConfig: rotasApp,
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark().copyWith(
            primaryColor: Colors.tealAccent[400],
            scaffoldBackgroundColor: const Color(0xFF121212),
          ),
        ),
      ),
    );
  }
}
