import 'package:flutter/material.dart';

class ConversaCard extends StatefulWidget {
  final String nome;
  final int status;
  final String? imagem;
  final VoidCallback onTap;

  const ConversaCard({
    super.key,
    required this.nome,
    required this.imagem,
    required this.status,
    required this.onTap,
  });

  @override
  State<ConversaCard> createState() => _ConversaCardState();
}

class _ConversaCardState extends State<ConversaCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool temImagem = widget.imagem != null && widget.imagem!.isNotEmpty;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: isHovered
                  ? Color(0xFF2A2A2A) 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    temImagem
                    ? CircleAvatar(
                        radius: 19,
                        backgroundColor: Color.fromARGB(255, 124, 77, 255),
                        backgroundImage: NetworkImage(widget.imagem!),
                        onBackgroundImageError: (_, __) {},
                      )
                    : CircleAvatar(
                        radius: 19,
                        backgroundColor: Colors.grey[800],
                        child: Icon(Icons.person, color: Colors.white, size: 19),
                    ),
                    if(widget.status != -1)...[
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: widget.status == 2
                                ? Colors.green
                                : widget.status == 1 ? Color.fromARGB(255, 253, 198, 0) : Colors.grey,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  Colors.black, // borda para destacar o círculo no avatar
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
                const SizedBox(width: 10),
                Text(
                  widget.nome,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
