import 'dart:ui';

import 'package:app_desktop/basedados/querys.dart';
import 'package:app_desktop/widget/opcoes_mensagem.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';


int? mensagemEditandoId;

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.idgrupo});
  final int idgrupo;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _messageEditarController = TextEditingController();
  int currentUserId = 1;
  final Map<int, Map<String, dynamic>> _grupoDataCache = {};
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  void marcarMensagensComoLidas() async {
    try {
      await GraphQLProvider.of(context).value.mutate(
        MutationOptions(
          document: gql(updateLidaMutation),
          variables: {"userId": currentUserId, "grupoId": widget.idgrupo},
        ),
      );
    } catch (e) {
      debugPrint('Erro ao marcar mensagens como lidas: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      marcarMensagensComoLidas();
      _focusNode.requestFocus();
    });
  }

  void enviarMensagem(List membros) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final MutationOptions options = MutationOptions(
      document: gql(insertMensagemMutation),
      variables: {
        'text': _messageController.text.trim(),
        'fromId': currentUserId,
        'grupoId': widget.idgrupo,
      },
    );

    final result = await client.mutate(options);

    if (result.hasException) {
      // ignore: avoid_print
      print("Erro ao enviar mensagem: ${result.exception.toString()}");
      return;
    }

    final mensagemId = result.data?['insert_mensagem_one']?['id'];
    if (mensagemId == null) {
      // ignore: avoid_print
      print("Mensagem criada, mas não foi possível obter o ID.");
      return;
    }

    // Cria mensagens_lidas para todos os outros membros
    final outrosMembros = membros
        .where((m) => m['user']['id'] != currentUserId)
        .map(
          (m) => {
            'id_user': m['user']['id'],
            'id_mensagem': mensagemId,
            'lida': false,
          },
        )
        .toList();

    final MutationOptions inserirLidasOptions = MutationOptions(
      document: gql(r'''
      mutation InserirMensagensLidas($objetos: [mensagens_lidas_insert_input!]!) {
        insert_mensagens_lidas(objects: $objetos) {
          affected_rows
        }
      }
    '''),
      variables: {'objetos': outrosMembros},
    );

    final resLidas = await client.mutate(inserirLidasOptions);
    if (resLidas.hasException) {
      // ignore: avoid_print
      print("Erro ao criar mensagens_lidas: ${resLidas.exception.toString()}");
    }

    _messageController.clear(); // Limpa o campo
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Subscription(
      options: SubscriptionOptions(
        document: gql(mensagensUsersQuery),
        variables: {'idgrupo': widget.idgrupo},
      ),
      builder: (result) {
        if (result.hasException) {
          return Scaffold(
            body: Center(child: Text('Erro: ${result.exception.toString()}')),
          );
        }

        final grupos = result.data?['grupos'];

        if (result.isLoading && _grupoDataCache[widget.idgrupo] == null) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (grupos == null || grupos.isEmpty) {
          if (_grupoDataCache[widget.idgrupo] != null) {
            return _buildChatScaffold(_grupoDataCache[widget.idgrupo]!);
          } else {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
        }

        final grupoSelecionado = grupos.first;
        _grupoDataCache[widget.idgrupo] = grupoSelecionado;

        return _buildChatScaffold(grupoSelecionado);
      },
    );
  }

  Scaffold _buildChatScaffold(Map<String, dynamic> grupoSelecionado) {
    final mensagens = grupoSelecionado['mensagems'];

    final mensagensReversas = List.from(mensagens.reversed);

    final membros = grupoSelecionado['grupo_membros'];

    final friend;
    bool grupo;
    if (membros.length == 2) {
      friend = membros
          .map((m) => m['user'])
          .firstWhere(
            (u) => u['id'] != currentUserId,
            orElse: () => membros.first['user'],
          );
      grupo = false;
    } else {
      friend = {
        'nome': grupoSelecionado['nome'],
        'imagem': grupoSelecionado['imagem'],
        'status': null,
      };
      grupo = true;
    }

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.grey[900],
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFriendTile(friend, grupo),
            Divider(color: Colors.grey[800], thickness: 1, height: 8),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: mensagensReversas.length,
                controller: _scrollController,
                reverse: true,
                itemBuilder: (_, i) {
                  final msg = mensagensReversas[i];
                  final isMe = msg['from_id_user'] == currentUserId;

                  Map<String, dynamic>? autor;
                  if (grupo && !isMe) {
                    final membro = membros.firstWhere(
                      (m) => m['user']['id'] == msg['from_id_user'],
                      orElse: () => null,
                    );
                    autor = membro?['user'];
                  }

                  return Listener(
                    onPointerDown: (event) {
                      if (event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton) {
                        mostrarOpcoesMensagem(context, msg, currentUserId);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 6, left: 40),
                      child: Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            if (grupo && autor != null && !isMe)
                              Positioned(
                                left: -28,
                                top: 0,
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.grey[800],
                                  backgroundImage:
                                      autor['imagem'] != null &&
                                          autor['imagem'].isNotEmpty
                                      ? NetworkImage(autor['imagem'])
                                      : null,
                                  child:
                                      (autor['imagem'] == null ||
                                          autor['imagem'].isEmpty)
                                      ? const Icon(
                                          Icons.person,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ),
                            Container(
                              margin: grupo && autor != null && !isMe
                                  ? const EdgeInsets.only(left: 16)
                                  : null,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? const Color.fromARGB(135, 157, 9, 221)
                                    : Colors.grey[700],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              constraints: const BoxConstraints(maxWidth: 280),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (grupo && autor != null && !isMe)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        autor['nome'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                    mensagemEditandoId == msg['id'] 
                                    ? TextField(
                                        controller: _messageEditarController,
                                        autofocus: true,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                          border: OutlineInputBorder(),
                                        ),
                                        onSubmitted: (value) => print('${msg['id']} ${value}'),
                                      )
                                    : SelectableText(
                                        msg['text'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            DateFormat('HH:mm').format(
                                              DateTime.parse(msg['created_at']),
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          if (isMe)
                                            Icon(
                                              Icons.done_all,
                                              size: 14,
                                              color:
                                                  (msg['mensagens_lidas'] !=
                                                          null &&
                                                      msg['mensagens_lidas']
                                                          .isNotEmpty &&
                                                      msg['mensagens_lidas']
                                                          .every(
                                                            (m) =>
                                                                m['lida'] == true,
                                                          ))
                                                  ? Colors.lightBlueAccent
                                                  : Colors.grey,
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    onSubmitted: (_) => enviarMensagem(membros),
                    decoration: const InputDecoration(
                      hintText: 'Escreve uma mensagem',
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    enviarMensagem(membros);
                  },
                  child: const Icon(Icons.send),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendTile(Map<String, dynamic> friend, bool grupo) {
    return ListTile(
      leading: Stack(
        children: [
          friend['imagem'] != null && friend['imagem'].isNotEmpty
              ? CircleAvatar(
                  radius: 19,
                  backgroundColor: Colors.grey[800],
                  backgroundImage: NetworkImage(friend['imagem']),
                )
              : CircleAvatar(
                  radius: 19,
                  backgroundColor: Colors.grey[800],
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
          if (!grupo) ...[
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: friend['status'] == 2
                      ? Colors.green
                      : friend['status'] == 1
                      ? const Color.fromARGB(255, 253, 198, 0)
                      : Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
              ),
            ),
          ],
        ],
      ),
      title: Text(
        friend['nome'] ?? '',
        style: const TextStyle(color: Colors.white),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.call, color: Colors.grey, size: 20),
          SizedBox(width: 15),
          Icon(Icons.video_call, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  void mostrarOpcoesMensagem(BuildContext context, Map<String, dynamic> mensagem, int currentUserId) {
  final isMe = mensagem['from_id_user'] == currentUserId;

  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar'),
              enabled: isMe,
              onTap: isMe
                  ? () {
                      Navigator.pop(context);
                      setState(() {
                        mensagemEditandoId = mensagem['id'];
                        _messageEditarController.text = mensagem['text'];
                      });
                    }
                  : null,
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Eliminar'),
              enabled: isMe,
              onTap: isMe ? () {
                // Aqui você pode adicionar lógica de exclusão
              } : null,
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancelar'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    },
  );
}

}



