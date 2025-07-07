import 'package:flutter/material.dart';

class Friends extends StatefulWidget {
  const Friends({super.key});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> friends = [
    {'id': '1', 'nome': 'Ana', 'status': 'online', 'tag': 'aB3kL9dX', "imagem" : "assets/splash.png"},
    {'id': '2', 'nome': 'Bruno', 'status': 'offline', 'tag': 'Pq8ZrRt2', "imagem" : ""},
    {'id': '3', 'nome': 'Carla', 'status': 'online', 'tag': 'Xy12ABcd', "imagem" : "assets/splash.png"},
    {'id': '4', 'nome': 'Afonso', 'status': 'online', 'tag': 'Lm9NpQ7w', "imagem" : ""},
    {'id': '5', 'nome': 'José', 'status': 'offline', 'tag': 'Rt6YvWs1', "imagem" : ""},
    {'id': '6', 'nome': 'Martim', 'status': 'offline', 'tag': 'Jk3ZxUv5', "imagem" : "assets/splash.png"},
    {'id': '7', 'nome': 'Mariana', 'status': 'online', 'tag': 'Fg8TbSn4', "imagem" : ""},
    {'id': '8', 'nome': 'Rafael', 'status': 'offline', 'tag': 'Dc9ErKw2', "imagem" : ""},
    {'id': '9', 'nome': 'Isabela', 'status': 'online', 'tag': 'Uz5NmQl7', "imagem" : "assets/splash.png"},
    {'id': '10', 'nome': 'Lucas', 'status': 'online', 'tag': 'Py1WqEv6', "imagem" : ""},
    {'id': '11', 'nome': 'Sofia', 'status': 'offline', 'tag': 'Ox7BkRj3', "imagem" : ""},
    {'id': '12', 'nome': 'Pedro', 'status': 'offline', 'tag': 'Vn4HyTf8', "imagem" : "assets/splash.png"},
    {'id': '13', 'nome': 'Beatriz', 'status': 'offline', 'tag': 'Qs2DrCm9', "imagem" : ""},
    {'id': '14', 'nome': 'Tiago', 'status': 'offline', 'tag': 'Ml6ZxOw1', "imagem" : ""},
    {'id': '15', 'nome': 'Helena', 'status': 'offline', 'tag': 'Kb9TyVu5', "imagem" : "assets/splash.png"},
    {'id': '16', 'nome': 'Gabriel', 'status': 'offline', 'tag': 'Aj3NpQs7', "imagem" : ""},
  ];

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

  Widget _buildFriendTile(Map<String, String> friend) {
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
                  color: friend['status'] == 'online'
                      ? Colors.green
                      : Colors.grey,
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
              // lógica para adicionar amigo aqui
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
        // Mini nav usando TabBar
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

        // Conteúdo das abas
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Online friends
              ListView.separated(
  padding: EdgeInsets.all(8),
  itemCount: friends.where((f) => f['status'] == 'online').length,
  itemBuilder: (context, index) {
    final onlineFriends = friends.where((f) => f['status'] == 'online').toList();
    return _buildFriendTile(onlineFriends[index]);
  },
  separatorBuilder: (context, index) => SizedBox(height: 8),
),

// All friends
ListView.separated(
  padding: EdgeInsets.all(8),
  itemCount: friends.length,
  itemBuilder: (context, index) => _buildFriendTile(friends[index]),
  separatorBuilder: (context, index) => SizedBox(height: 8),
),

              // Add friend
              _buildAddFriendTab(),
            ],
          ),
        ),
      ],
    );
  }
}
