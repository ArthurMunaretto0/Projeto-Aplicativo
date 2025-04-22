import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      create table clientes (
        id integer primary key autoincrement,
        nome text not null,
        telefone text not null,
        endereco text not null
      );
    ''');

    await db.execute('''
      create table servicos (
        id integer primary key autoincrement,
        nome text not null,
        descricao text not null,
        preco real not null
      );
    ''');

    await db.execute('''
      create table vinculos (
        id integer primary key autoincrement,
        cliente_id integer not null,
        servico_id integer not null,
        data text not null,
        hora_inicio text not null,
        hora_fim text not null,
        foreign key (cliente_id) references clientes(id),
        foreign key (servico_id) references servicos(id)
      );
    ''');
  }

  Future<int> insertCliente(Map<String, dynamic> cliente) async {
    final db = await database;
    return await db.insert('clientes', cliente);
  }

  Future<int> insertServico(Map<String, dynamic> servico) async {
    final db = await database;
    return await db.insert('servicos', servico);
  }

  Future<List<Map<String, dynamic>>> getClientes() async {
    final db = await database;
    return await db.query('clientes');
  }

  Future<List<Map<String, dynamic>>> getServicos() async {
    final db = await database;
    return await db.query('servicos');
  }

  Future<int> insertVinculoDetalhado({
    required int clienteId,
    required int servicoId,
    required String data,
    required String horaInicio,
    required String horaFim,
  }) async {
    final db = await database;
    return await db.insert('vinculos', {
      'cliente_id': clienteId,
      'servico_id': servicoId,
      'data': data,
      'hora_inicio': horaInicio,
      'hora_fim': horaFim,
    });
  }

  Future<List<Map<String, dynamic>>> getVinculosCompletos() async {
    final db = await database;
    return await db.rawQuery('''
    select 
      clientes.nome as cliente,
      servicos.nome as servico,
      servicos.descricao as descricao,
      servicos.preco as preco,
      vinculos.data,
      vinculos.hora_inicio,
      vinculos.hora_fim
    from vinculos
    inner join clientes on clientes.id = vinculos.cliente_id
    inner join servicos on servicos.id = vinculos.servico_id
    order by vinculos.id desc
  ''');
  }
}
