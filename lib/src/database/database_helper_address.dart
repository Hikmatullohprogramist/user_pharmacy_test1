import 'dart:async';

import 'package:path/path.dart';
import 'package:pharmacy/src/model/database/address_model.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelperAddress {
  static final DatabaseHelperAddress _instance =
      new DatabaseHelperAddress.internal();

  factory DatabaseHelperAddress() => _instance;

  final String tableNote = 'addressTable';
  final String columnId = 'id';
  final String columnStreet = 'street';
  final String columnLat = 'lat';
  final String columnLng = 'lng';
  final String columnType = 'type';
  final String columnDom = 'dom';
  final String columnEn = 'en';
  final String columnKv = 'kv';
  final String columnComment = 'comment';

  static Database? _db;

  DatabaseHelperAddress.internal();

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();

    return _db!;
  }

  initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'addressUser.db');
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  void _onCreate(Database db, int newVersion) async {
    await db.execute(
      'CREATE TABLE $tableNote('
      '$columnId INTEGER PRIMARY KEY AUTOINCREMENT, '
      '$columnStreet TEXT, '
      '$columnDom TEXT, '
      '$columnEn TEXT, '
      '$columnKv TEXT, '
      '$columnComment TEXT, '
      '$columnType INTEGER, '
      '$columnLat TEXT, '
      '$columnLng TEXT)',
    );
  }

  Future<int> saveProducts(AddressModel item) async {
    var dbClient = await db;
    var result = await dbClient.insert(tableNote, item.toMap());
    return result;
  }

  Future<List> getAllProducts() async {
    var dbClient = await db;
    var result = await dbClient.query(tableNote,
        columns: [columnId, columnStreet, columnLat, columnLng]);
    return result.toList();
  }

  Future<List<AddressModel>> getProduct() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM $tableNote');
    List<AddressModel> products = <AddressModel>[];
    for (int i = 0; i < list.length; i++) {
      var items = new AddressModel(
        id: list[i][columnId],
        street: list[i][columnStreet],
        dom: list[i][columnDom],
        en: list[i][columnEn],
        kv: list[i][columnKv],
        comment: list[i][columnComment],
        lat: list[i][columnLat],
        lng: list[i][columnLng],
        type: list[i][columnType],
      );
      if (items.type == 0) {
        products.add(items);
      }
    }
    return products;
  }

  Future<List<AddressModel>> getAllProduct() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM $tableNote');
    List<AddressModel> products = <AddressModel>[];
    for (int i = 0; i < list.length; i++) {
      var items = new AddressModel(
        id: list[i][columnId],
        street: list[i][columnStreet],
        dom: list[i][columnDom],
        en: list[i][columnEn],
        kv: list[i][columnKv],
        comment: list[i][columnComment],
        lat: list[i][columnLat],
        lng: list[i][columnLng],
        type: list[i][columnType],
      );
      products.add(items);
    }
    return products;
  }

  Future<AddressModel?> getProductsType(int id) async {
    var dbClient = await db;
    List<Map> result = await dbClient.query(
      tableNote,
      columns: [
        columnId,
        columnStreet,
        columnLat,
        columnLng,
        columnType,
        columnDom,
        columnEn,
        columnKv,
        columnComment,
      ],
      where: '$columnType = ?',
      whereArgs: [id],
    );

    if (result.length > 0) {
      return AddressModel.fromMap(result.first);
    }
    return null;
  }

  Future<int> deleteProducts(int id) async {
    var dbClient = await db;
    return await dbClient.delete(
      tableNote,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateProduct(AddressModel products) async {
    var dbClient = await db;
    return await dbClient.update(tableNote, products.toMap(),
        where: "$columnId = ?", whereArgs: [products.id]);
  }

  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }

  Future<void> clear() async {
    var dbClient = await db;
    await dbClient.rawQuery('DELETE FROM $tableNote');
  }
}
