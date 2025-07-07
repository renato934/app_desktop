import 'package:sqflite/sqflite.dart';

class Users {
  static const String tableName = 'users';

  static const String createTable = '''
    create table users (
      id          integer primary key autoincrement,
      nome        text not null,
      tag         text not null,
      imagem      text null,
      status      text not null,
    );
  ''';

  static Future<void> criarTabela({required Database db}) async {
    try {
      await db.execute(createTable);
      print('✅ Criada: $tableName');
    } catch (e) {
      print('❌ Erro ao criar $tableName: $e');
    }
  }

  static Future<int> inserir({
    required Database db,
    required int id,
    required String nome,
    required String tag,
    required String status,
    required String imagem,
  }) async {
    return await db.insert(
      Users.tableName,
      {
        'id': id,
        'nome': nome,
        'tag': tag,
        'status': status,
        'imagem': imagem,
      },
    );
  }

  static Future<int> update({
    required Database db,
    required int id,
    required String nome,
    required String tag,
    required String status,
    required String imagem,
  }) async {
    return await db.update(
      Users.tableName,
      {
        'id': id,
        'nome': nome,
        'tag': tag,
        'status': status,
        'imagem': imagem,
      },
    );
  }
}
