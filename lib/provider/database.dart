import 'package:fetchingapp/model/data_model.dart';
import 'package:fetchingapp/provider/sql_queries.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> cacheDatabase() async {
  return openDatabase(join(await getDatabasesPath(), 'cache_database.db'),
      onCreate: (db, version) {
    return db.execute(Queries().createCacheTable);
  }, version: 1);
}

//read data
Future<List<Map>> readCache() async {
  final db = await cacheDatabase();
  var cache = db.query('cache');
  print('db entries: $cache');

  return cache;
}

Future addBatchOfFirestore({required List<Map<String, dynamic>> list}) async {
  final db = await cacheDatabase();
  final batch = db.batch();
  for (var item in list) {
    batch.insert('cache', item, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  await batch.commit(noResult: true);
  print('batch insert complete');
}

// add entry
Future addBatchOfEntries({required List<dynamic> entries}) async {
  final db = await cacheDatabase();
  final batch = db.batch();
  for (var item in entries) {
    final entry =
        DataModel(name: item['name'], body: item['body'], email: item['email']);

    batch.insert('cache', entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
  await batch.commit(noResult: true);
  print('batch insert complete');
}

Future cleanDB() async {
  if (kIsWeb) {
    return;
  }
  final db = await cacheDatabase();
  db.execute(Queries().dropCacheTable);
  db.execute(Queries().createCacheTable);
}
