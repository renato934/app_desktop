import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  TextEditingController _messageController = TextEditingController();

  final List<Map<String, String>> messages = [
    {'from': 'Ana', 'text': 'Olá! Tudo bem?'},
    {'from': 'Tu', 'text': 'Tudo ótimo, e contigo?'},
    {'from': 'Ana', 'text': 'Também. Vamos jogar mais tarde?'},
    {'from': 'Tu', 'text': 'Claro! A que horas?'},
    {'from': 'Ana', 'text': 'Por volta das 20h. Está bem para ti?'},
    {'from': 'Tu', 'text': 'Sim, perfeito! Vou preparar o jogo.'},
    {'from': 'Ana', 'text': 'Ótimo, até mais logo então!'},
    {'from': 'Tu', 'text': 'Até!'},
    {'from': 'Ana', 'text': 'Ah, lembraste do evento no sábado?'},
    {'from': 'Tu', 'text': 'Sim, vou tentar aparecer.'},
    {'from': 'Ana', 'text': 'Beleza, vai ser fixe!'},
    {'from': 'Tu', 'text': 'Com certeza!'},
    {'from': 'Ana', 'text': 'Também queria falar contigo sobre o projeto.'},
    {'from': 'Tu', 'text': 'Diz aí, estou a ouvir.'},
    {'from': 'Ana', 'text': 'Parece que precisamos de ajustar o prazo.'},
    {'from': 'Tu', 'text': 'Concordo. Quanto tempo achas que precisamos?'},
    {'from': 'Ana', 'text': 'Duas semanas extra talvez.'},
    {'from': 'Tu', 'text': 'Ok, vou falar com a equipa para confirmar.'},
    {'from': 'Ana', 'text': 'Obrigado!'},
    {'from': 'Tu', 'text': 'Sem problemas.'},
    {'from': 'Ana', 'text': 'Depois falamos mais, boa sorte com tudo!'},
    {'from': 'Tu', 'text': 'Obrigado, também para ti!'},
    {'from': 'Ana', 'text': 'Até!'},
    {'from': 'Tu', 'text': 'Até!'},
  ];

  final List<Map<String, String>> friends = [
    {
      'id': '1',
      'nome': 'Ana',
      'status': 'online',
      'tag': 'aB3kL9dX',
      "imagem": "assets/splash.png",
    },
  ];

  @override
   Widget build(BuildContext context) {
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
            _buildFriendTile(friends[0]),
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
                itemCount: messages.length,
                itemBuilder: (_, i) {
                  final msg = messages[i];
                  final isMe = msg['from'] == 'Tu';
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue : Colors.grey[700],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text("${msg['text']}"),
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
                    decoration: InputDecoration(
                      hintText: 'Escreve uma mensagem',
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  child: Icon(Icons.send),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(16),
                    shape: CircleBorder(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildFriendTile(Map<String, String> friend) {
  return ListTile(
    leading: Stack(
      children: [
        friend['imagem'] != null || friend['imagem']!.isNotEmpty
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
              color: friend['status'] == 'online' ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black, // borda para destacar o círculo no avatar
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
        Icon(Icons.call, color: Colors.grey, size: 20),
        SizedBox(width: 15),
        Icon(Icons.video_call, color: Colors.grey, size: 20),
      ],
    ),
  );
}
