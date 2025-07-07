import 'package:app_desktop/pages/chat.dart';
import 'package:app_desktop/pages/friends.dart';
import 'package:app_desktop/pages/to-do.dart';
import 'package:app_desktop/widget/card_conversas.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final ScrollController _scrollController = ScrollController();

  int currentUserId = 1;
  final String MensagensQuery = r'''
    subscription GetMensagens($userId: Int!) {
      grupo_membros(where: { id_user: { _eq: $userId } }) {
        grupo {
          id
          nome
          imagem
          grupo_membros {
            user {
              id
              nome
              imagem
              status
            }
          }
        }
      }
    }
  ''';

  final String UserQuery = r'''
    subscription getuser($userId: Int!) {
      users(where: {id: {_eq: $userId}}) {
        id
        nome
        imagem
        status
      }
    }
  ''';

  String? contatoSelecionado = "Amigos";

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 260,
            color: Color.fromRGBO(18, 18, 20, 1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Scrollbar(
                  controller: _scrollController,
                  thickness: 5,
                  radius: Radius.circular(10),
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: ClampingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Column(
                      children: [
                        // Menu
                        MenuItemButton(
                          text: "Amigos",
                          onTap: () {
                            setState(() {
                              contatoSelecionado = "Amigos";
                            });
                          },
                        ),
                        SizedBox(height: 8),
                        MenuItemButton(
                          text: "TO-DO",
                          onTap: () {
                            setState(() {
                              contatoSelecionado = "TO-DO";
                            });
                          },
                        ),
                        SizedBox(height: 20),

                        // Título "Mensagens" e botão
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Mensagens",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                onPressed: () {},
                                icon: Icon(Icons.add, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),

                        // Lista de contatos
                        Subscription(
                          options: SubscriptionOptions(
                            document: gql(MensagensQuery),
                            variables: {'userId': currentUserId},
                          ),
                          builder: (result, {fetchMore, refetch}) {
                            if (result.isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (result.hasException) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Erro: ${result.exception.toString()}",
                                  style: const TextStyle(color: Colors.red),
                                ),
                              );
                            }

                            final amigos = result.data?['grupo_membros'] ?? [];

                            return Column(
                              children: List.generate(amigos.length, (index) {
                                final amigo =
                                    amigos[index]['grupo']['grupo_membros'];
                                final outro;

                                if (amigo.length == 2) {
                                  // Identifica o outro usuário (não o atual)
                                  final user1 = amigo[0]['user'];
                                  final user2 = amigo[1]['user'];

                                  outro = user1['id'] == currentUserId
                                      ? user2
                                      : user1;
                                } else {
                                  outro = amigos[index]['grupo'];
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 3),
                                  child: ConversaCard(
                                    nome: outro['nome'],
                                    imagem: outro['imagem'],
                                    status: outro['status'] != null ? outro['status'] : -1,
                                    onTap: () {
                                      setState(() {
                                        contatoSelecionado = outro['id']
                                            .toString();
                                      });
                                    },
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                Subscription(
                  options: SubscriptionOptions(
                    document: gql(UserQuery),
                    variables: {'userId': currentUserId},
                  ),
                  builder: (result, {fetchMore, refetch}) {
                    if (result.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (result.hasException) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Erro: ${result.exception.toString()}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final user = result.data?['users'][0];

                    return _buildperfil(context, user);
                  },
                ),
              ],
            ),
          ),

          // 🔁 Área da direita (conteúdo que muda)
          Expanded(
            child: Container(
              color: Colors.grey[900],
              child: contatoSelecionado == "Amigos"
                  ? Friends()
                  : contatoSelecionado == "TO-DO"
                  ? TodoPage()
                  : ChatPage(),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuItemButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const MenuItemButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              text == "Amigos"
                  ? Icon(Icons.person, size: 20, color: Colors.white70)
                  : Icon(
                      Icons.check_circle_outline_sharp,
                      size: 20,
                      color: Colors.white70,
                    ),
              SizedBox(width: 10),
              Text(text, style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildperfil(BuildContext context, Map<String, dynamic> user) {
  return Padding(
    padding: EdgeInsets.only(bottom: 15, left: 20, right: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Stack(
              children: [
                user['imagem'] != null && user['imagem'].isNotEmpty
                    ? CircleAvatar(
                        radius: 19,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: NetworkImage(user['imagem']),
                        onBackgroundImageError: (_, __) {},
                      )
                    : CircleAvatar(
                        radius: 19,
                        backgroundColor: Colors.grey[800],
                        child: Icon(Icons.person, color: Colors.white, size: 19),
                      ),
                if (user['status'] != -1)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: user['status'] == 2
                            ? Colors.green
                            : user['status'] == 1
                                ? Color.fromARGB(255, 253, 198, 0)
                                : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 10),
            Text(
                user['nome'] ?? '',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
          ],
        ),
        Row(
          children: [
            Icon(Icons.mic, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Icon(Icons.headset, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Icon(Icons.settings, color: Colors.white, size: 20),
          ],
        ),
      ],
    ),
  );
}
