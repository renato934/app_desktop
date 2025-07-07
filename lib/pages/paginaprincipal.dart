import 'package:app_desktop/pages/chat.dart';
import 'package:app_desktop/pages/friends.dart';
import 'package:app_desktop/pages/to-do.dart';
import 'package:app_desktop/widget/card_conversas.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> contatos = [
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
        children: [
          // 🧭 Coluna da esquerda (Sidebar)
          Container(
            width: 260,
            color: Color.fromRGBO(18, 18, 20, 1),
            child: Scrollbar(
              controller: _scrollController, 
              thickness: 5,
              radius: Radius.circular(10),
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController, 
                physics: ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Menu
                    MenuItemButton(text: "Amigos", onTap: () {setState(() {contatoSelecionado = "Amigos";});}),
                    SizedBox(height: 8),
                    MenuItemButton(text: "TO-DO", onTap: () {setState(() {contatoSelecionado = "TO-DO";});}),
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
                    ...contatos.map(
                      (contato) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: ConversaCard(
                          nome: contato['nome']!,
                          imagem: contato['imagem'],
                          status: contato['status']!,
                          onTap: () {
                            setState(() {
                              contatoSelecionado = contato['id'];
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 🔁 Área da direita (conteúdo que muda)
          Expanded(
            child: Container(
              color: Colors.grey[900],
              child: Center(
                child: contatoSelecionado == "Amigos"
                    ? Friends()
                    : contatoSelecionado == "TO-DO" ? 
                      TodoPage()
                    : ChatPage()
              ),
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
