import 'package:sqflite/sqflite.dart';

class Users {
  static const String tableName = 'mensagens';

  static const String createTable = '''
    create table mensagens (
      id          integer primary key autoincrement,
      idgrupo     integer not null REFERENCES grupos(id) ON DELETE CASCADE,
      iduser      integer REFERENCES users(id) ON DELETE CASCADE
      texto       text not null
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
    required int idgrupo,
    required int iduser,
  }) async {
    return await db.insert(
      Users.tableName,
      {
        'id': id,
        'idgrupo': idgrupo,
        'iduser': iduser,
      },
    );
  }

  static Future<int> update({
    required Database db,
    required int id,
    required int idgrupo,
    required int iduser,
  }) async {
    return await db.update(
      Users.tableName,
      {
        'id': id,
        'idgrupo': idgrupo,
        'iduser': iduser,
      },
    );
  }
}
