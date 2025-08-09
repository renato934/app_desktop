import 'package:flutter/material.dart';

Future<Map<String, dynamic>?> selecionarAmigos(BuildContext context, List<Map<String, dynamic>> contatos) async {
  final Set<int> selecionados = {};
  final List<String> nomesSelecionados = [];
  const double alturaItem = 70;

  final width = MediaQuery.of(context).size.width;
  final alturaCalculada = contatos.length * alturaItem;

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) {
      return Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Dialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: width * 0.5,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecionar Amigos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: alturaCalculada.clamp(0, 500),
                    ),
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: contatos.length,
                          itemBuilder: (context, i) {
                            final contato = contatos[i];
                            final id = contato['id']!;
                            final nome = contato['nome']!;
                            final status = contato['status']!;
                            final tag = contato['tag']!;
                            final imagem = contato['imagem']!;

                            return CheckboxListTile(
                              value: selecionados.contains(id),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selecionados.add(id);
                                    nomesSelecionados.add(nome);
                                  } else {
                                    selecionados.remove(id);
                                    nomesSelecionados.remove(nome);
                                  }
                                });
                              },
                              activeColor: Colors.blue,
                              title: Text(
                                nome,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle:
                                  Text(tag, style: TextStyle(fontSize: 13)),
                              secondary: Stack(
                                children: [
                                  imagem.isNotEmpty
                                      ? CircleAvatar(
                                          radius: 19,
                                          backgroundColor: Colors.grey[800],
                                          backgroundImage: NetworkImage(imagem),
                                          onBackgroundImageError: (_, __) {},
                                        )
                                      : CircleAvatar(
                                          radius: 19,
                                          backgroundColor: Colors.grey[800],
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: 19,
                                          ),
                                        ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: status == 'online'
                                            ? Colors.green
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
                              checkboxShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        child: const Text('Confirmar'),
                        onPressed: () {
                          if (selecionados.isNotEmpty) {
                            Navigator.pop(context, {'ids': selecionados,'nomes': nomesSelecionados,});
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
