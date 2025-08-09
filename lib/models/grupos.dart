import 'package:sqflite/sqflite.dart';

class Users {
  static const String tableName = 'grupos';

  static const String createTable = '''
    create table grupos (
      id          integer primary key autoincrement,
      nome        text null,
      imagem      text null
    );
  ''';

  static Future<void> criarTabela({required Database db}) async {
    try {
      await db.execute(createTable);
      // ignore: avoid_print
      print('✅ Criada: $tableName');
    } catch (e) {
      // ignore: avoid_print
      print('❌ Erro ao criar $tableName: $e');
    }
  }

  static Future<int> inserir({
    required Database db,
    required int id,
    required String nome,
    required String imagem,
  }) async {
    return await db.insert(
      Users.tableName,
      {
        'id': id,
        'nome': nome,
        'imagem': imagem,
      },
    );
  }

  static Future<int> update({
    required Database db,
    required int id,
    required String nome,
    required String imagem,
  }) async {
    return await db.update(
      Users.tableName,
      {
        'id': id,
        'nome': nome,
        'imagem': imagem,
      },
    );
  }
}
