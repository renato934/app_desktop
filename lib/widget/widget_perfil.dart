import 'package:flutter/material.dart';

Widget buildperfil(BuildContext context, Map<String, dynamic> user) {
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