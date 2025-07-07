import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class Friends extends StatefulWidget {
  const Friends({super.key});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int currentUserId = 1;
  final String friendsQuery = r'''
    subscription GetFriends($userId: Int!) {
      amigos(
        where: {
          _or: [
            {id_user1: {_eq: $userId}},
            {id_user2: {_eq: $userId}}
          ],
          status: {_eq: 1}
        }
      ) {
        user {
          id
          nome
          status
          tag
          imagem
        }
        userByIdUser2 {
          id
          nome
          status
          tag
          imagem
        }
      }
    }
  ''';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Função para extrair o "amigo" (não currentUser) da amizade
  Map<String, dynamic> extractFriend(Map<String, dynamic> friendship) {
    final idUser1 = friendship['user']['id'];
    if (idUser1 == currentUserId) {
      return friendship['userByIdUser2'];
    } else {
      return friendship['user'];
    }
  }

 Widget _buildFriendTile(Map<String, dynamic> friend) {
    return ListTile(
      leading: Stack(
          children: [
            friend['imagem'] != null && friend['imagem']!.isNotEmpty
            ? CircleAvatar(
                radius: 19,
                backgroundColor: Colors.grey[800],
                backgroundImage: AssetImage(friend['imagem']!),
                onBackgroundImageError: (_, __) {},
              )
            : CircleAvatar(
                radius: 19,
                backgroundColor: Colors.grey[800],
                child: Icon(Icons.person, color: Colors.white, size: 19),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: friend['status'] == 2
                      ? Colors.green
                      : friend['status'] == 1 ? Color.fromARGB(255, 253, 198, 0) : Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        Colors.black, // borda para destacar o círculo no avatar
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      title: Text(friend['nome']!),
      trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.message_outlined, color: Colors.grey, size: 20),
        SizedBox(width: 15),
        Icon(Icons.more_vert, color: Colors.grey, size: 20),
      ],
    ),
    );
  }

  Widget _buildAddFriendTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Nome do utilizador',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Função de adicionar não implementada.'),
                ),
              );
            },
            child: Text('Enviar pedido de amizade'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.grey[900],
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.blueAccent,
            tabs: [
              Tab(text: 'Online'),
              Tab(text: 'Todos'),
              Tab(text: 'Adicionar'),
            ],
          ),
        ),
        Expanded(
          child: Subscription(
            options: SubscriptionOptions(
              document: gql(friendsQuery),
              variables: {'userId': currentUserId},
            ),
            builder: (result) {
              if (result.hasException) {
                return Center(child: Text('Erro: ${result.exception.toString()}'));
              }
              if (result.isLoading) {
                return Center(child: CircularProgressIndicator());
              }

              final rawFriends = (result.data?['amigos'] ?? []) as List<dynamic>;

              // Extrai os amigos reais (não o utilizador atual)
              final friendsList = rawFriends
                  .map((f) => extractFriend(f as Map<String, dynamic>))
                  .toList();

              return TabBarView(
                controller: _tabController,
                children: [
                  // Online friends
                  ListView.separated(
                    padding: EdgeInsets.all(8),
                    itemCount: friendsList.where((f) => f['status'] == 1 || f['status'] == 2).length,
                    itemBuilder: (context, index) {
                      final onlineFriends = friendsList.where((f) => f['status'] == 1 || f['status'] == 2).toList();
                      return _buildFriendTile(onlineFriends[index]);
                    },
                    separatorBuilder: (context, index) => SizedBox(height: 8),
                  ),

                  // All friends
                  ListView.separated(
                    padding: EdgeInsets.all(8),
                    itemCount: friendsList.length,
                    itemBuilder: (context, index) => _buildFriendTile(friendsList[index]),
                    separatorBuilder: (context, index) => SizedBox(height: 8),
                  ),

                  // Add friend tab
                  _buildAddFriendTab(),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
