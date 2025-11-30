import 'package:app_desktop/basedados/querys.dart';
import 'package:app_desktop/pages/chat.dart';
import 'package:app_desktop/pages/friends.dart';
import 'package:app_desktop/pages/to-do.dart';
import 'package:app_desktop/widget/card_conversas.dart';
import 'package:app_desktop/widget/widget_perfil.dart';
import 'package:app_desktop/widget/widget_selecionarAmigos.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final ScrollController _scrollController = ScrollController();

  int currentUserId = 1;
  String contatoSelecionado = "Amigos";

  void criarConversa(Set<int> ids, List<String> nomes) async{
      final GraphQLClient client = GraphQLProvider.of(context).value;

      String? nomeGrupo;
      ids.add(currentUserId);

      if(ids.length > 2)
      {
        nomeGrupo = nomes.join(', ');
      }

      // 1. Criar o grupo
      final resultGrupo = await client.mutate(MutationOptions(
        document: gql(newGrupo),
        variables: {'nome': nomeGrupo},
      ));

      if (resultGrupo.hasException) {
        print('Erro ao criar grupo: ${resultGrupo.exception.toString()}');
        return;
      }

      final int grupoId = resultGrupo.data!['insert_grupos_one']['id'];

      // 2. Adicionar membros ao grupo
      for (final idUser in ids) {
        final resultMembro = await client.mutate(MutationOptions(
          document: gql(newGrupoMembros),
          variables: {
            'id_grupo': grupoId,
            'id_user': idUser,
          },
        ));

        if (resultMembro.hasException) {
          print('Erro ao adicionar membro $idUser: ${resultMembro.exception.toString()}');
        }
      }

      print('Grupo "$nomeGrupo" criado com ID $grupoId e membros adicionados.');

      setState(() {
        contatoSelecionado = grupoId.toString();
      });

  }

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
                              Subscription(
                                options: SubscriptionOptions(
                                  document: gql(friendsQuery),
                                  variables: {'userId': currentUserId},
                                ),
                                builder: (result) {
                                  if (result.isLoading) return CircularProgressIndicator();

                                  final rawFriends = (result.data!['amigos'] ?? []) as List<dynamic>;

                                  final friendsList = rawFriends
                                    .map((f) => extractFriend(f as Map<String, dynamic>, currentUserId))
                                    .toList();                                  

                                  return  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                    onPressed: () async {
                                      final Map<String, dynamic>? selecionados = await selecionarAmigos(context, friendsList);
                                      if (selecionados != null && selecionados.isNotEmpty) {
                                        final Set<int> ids = selecionados['ids'];
                                        final List<String> nomes = selecionados['nomes'];
                                        criarConversa(ids, nomes);
                                      }
                                    },
                                    icon: Icon(Icons.add, color: Colors.white),
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 10),

                        // Lista de contatos
                        Subscription(
                          options: SubscriptionOptions(
                            document: gql(mensagensQuery),
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
                                final amigo = amigos[index]['grupo']['grupo_membros'];
                                final outro;

                                if (amigo.length == 2) {
                                  // Identifica o outro usuário (não o atual)
                                  final user1 = amigo[0]['user'];
                                  final user2 = amigo[1]['user'];

                                  final outroUser = user1['id'] == currentUserId ? user2 : user1;

                                  outro = {
                                    ...outroUser,  
                                    'id_grupo': amigos[index]['grupo']['id'],
                                  };
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
                                        contatoSelecionado = outro['id_grupo'] != null ? outro['id_grupo'].toString() : outro['id'].toString();
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
                    document: gql(userQuery),
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

                    return buildperfil(context, user);
                  },
                ),
              ],
            ),
          ),

          // 🔁 Área da direita (conteúdo que muda)
          Expanded(
            child: Container(
              color: Colors.grey[900],
              child: IndexedStack(
                index: _getSelectedIndex(),
                children: [
                  Friends(),
                  TodoPage(),
                  if (contatoSelecionado != "Amigos" && contatoSelecionado != "TO-DO")
                    ChatPage(idgrupo: int.parse(contatoSelecionado)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex() {
    if (contatoSelecionado == "Amigos") return 0;
    if (contatoSelecionado == "TO-DO") return 1;
    return 2;
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


Map<String, dynamic> extractFriend(Map<String, dynamic> friendship, int currentId) {
  final idUser1 = friendship['user']['id'];
  if (idUser1 == currentId) {
    return friendship['userByIdUser2'];
  } else {
    return friendship['user'];
  }
}