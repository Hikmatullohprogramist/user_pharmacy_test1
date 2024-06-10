import 'dart:async';

import 'package:path/path.dart';
import 'package:pharmacy/src/model/api/item_model.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  final String tableNote = 'cardTable';
  final String columnId = 'id';
  final String columnName = 'name';
  final String columnBarcode = 'barcode';
  final String columnImage = 'image';
  final String columnImageThumbnail = 'image_thumbnail';
  final String columnPrice = 'price';
  final String columnManufacturer = 'manufacturer';
  final String columnFav = 'favourite';
  final String columnCount = 'cardCount';

  static Database? _db;

  DatabaseHelper.internal();

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();

    return _db!;
  }

  initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'ewew.db');
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  void _onCreate(Database db, int newVersion) async {
    await db.execute('CREATE TABLE $tableNote('
        '$columnId INTEGER PRIMARY KEY, '
        '$columnName TEXT, '
        '$columnBarcode TEXT, '
        '$columnImage TEXT, '
        '$columnImageThumbnail TEXT, '
        '$columnPrice REAL, '
        '$columnManufacturer TEXT, '
        '$columnFav INTEGER, '
        '$columnCount INTEGER)');
  }

  Future<int> saveProducts(ItemResult item) async {
    var dbClient = await db;
    List<Map> result = await dbClient.query(
      tableNote,
      columns: [
        columnId,
      ],
      where: '$columnId = ?',
      whereArgs: [item.id],
    );
    if (result.length > 0) {
      return await dbClient.update(
        tableNote,
        item.toMap(),
        where: "$columnId = ?",
        whereArgs: [item.id],
      );
    } else {
      var result = await dbClient.insert(
        tableNote,
        item.toMap(),
      );
      return result;
    }
  }

  Future<List> getAllProducts() async {
    var dbClient = await db;
    var result = await dbClient.query(tableNote, columns: [
      columnId,
      columnName,
      columnBarcode,
      columnImage,
      columnImageThumbnail,
      columnPrice,
      columnManufacturer,
      columnFav,
      columnCount,
    ]);

    return result.toList();
  }

  Future<List<ItemResult>> getProduct() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM $tableNote');
    List<ItemResult> products = <ItemResult>[];
    for (int i = 0; i < list.length; i++) {
      var items = new ItemResult(
        id: list[i][columnId],
        name: list[i][columnName],
        barcode: list[i][columnBarcode],
        image: list[i][columnImage],
        imageThumbnail: list[i][columnImageThumbnail],
        price: list[i][columnPrice],
        manufacturer: Manufacturer(
          name: list[i][columnManufacturer],
        ),
        favourite: false,
        maxCount: 1000,
        basePrice: 0.0,
        isComing: true,
        cardCount: list[i][columnCount],
      );
      products.add(items);
    }
    return products;
  }

  Future<List<ItemResult>> getProdu(bool card) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM $tableNote');
    List<ItemResult> products = <ItemResult>[];
    for (int i = 0; i < list.length; i++) {
      var items = new ItemResult(
        id: list[i][columnId],
        name: list[i][columnName],
        barcode: list[i][columnBarcode],
        image: list[i][columnImage],
        imageThumbnail: list[i][columnImageThumbnail],
        price: list[i][columnPrice],
        manufacturer: Manufacturer(
          name: list[i][columnManufacturer],
        ),
        favourite: false,
        maxCount: 1000,
        basePrice: 0.0,
        isComing: true,
        cardCount: list[i][columnCount],
      );

      if (items.cardCount > 0) {
        products.add(items);
      }
    }
    return products;
  }

  Future<ItemResult> getProducts(int id) async {
    var dbClient = await db;
    List<Map> result = await dbClient.query(tableNote,
        columns: [
          columnId,
          columnName,
          columnBarcode,
          columnImageThumbnail,
          columnPrice,
          columnManufacturer,
          columnFav,
          columnCount,
        ],
        where: '$columnId = ?',
        whereArgs: [id]);

    if (result.length > 0) {
      return ItemResult.fromJson(result.first);
    }
    return ItemResult.fromJson({});
  }

  Future<int> deleteProducts(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete(tableNote, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> updateProduct(ItemResult products) async {
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
