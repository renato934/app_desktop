import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_single_instance/flutter_single_instance.dart';
import 'package:app_desktop/rotas/rotas.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter(); // Cache GraphQL

  final instance = FlutterSingleInstance();

  if (await instance.isFirstInstance()) {
    // Define o link HTTP
    final HttpLink httpLink = HttpLink(
      'http://188.80.118.142:8080/v1/graphql',
    );

    // Define o link WebSocket (usa ws:// porque o endpoint é HTTP)
    final WebSocketLink websocketLink = WebSocketLink(
      'ws://188.80.118.142:8080/v1/graphql',
      config: SocketClientConfig(
        autoReconnect: true,
        inactivityTimeout: Duration(seconds: 30),
        initialPayload: () async => {
          // Se tiveres autenticação, adiciona os headers aqui
          'headers': {
            // 'Authorization': 'Bearer O_TEU_TOKEN',
          },
        },
      ),
    );

    // Junta os links: subscrições usam WebSocket, resto usa HTTP
    final Link link = Link.split(
      (request) => request.isSubscription,
      websocketLink,
      httpLink,
    );

    // Cria o client
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
      child: MaterialApp.router(
        routerConfig: rotasApp,
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.tealAccent[400],
          scaffoldBackgroundColor: const Color(0xFF121212),
        ),
      ),
    );
  }
}
