import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_data_table_source/firestore_data_table_source.dart';

Future<void> populateFirestore(
  CollectionReference collection,
  int numberOfRows,
) async {
  for (var i = 0; i < numberOfRows; i++) {
    await collection.add({'lorem': 'ipsum'});
  }
}

void main() async {
  const pageSize = 10;

  group('When created', () => firstInitialized(pageSize));

  group('When no data is available', () => noDataIsAvailable(pageSize));

  group('When ${2 * pageSize} rows are available',
      () => twoPagesAreAvailable(pageSize));

  group('When ${4 * pageSize} rows are available',
      () => fourPagesAreAvailable(pageSize));
}

void firstInitialized(int pageSize) {
  late FirestoreDataTableSource sut;
  final firestore = FakeFirebaseFirestore();

  setUp(() {
    sut = FirestoreDataTableSource(
      query: firestore.collection('lorem'),
      getDataRow: (snapshot) => const DataRow(cells: []),
      pageSize: pageSize,
    );
  });

  tearDown(() => firestore.clearPersistence());

  test('it should return an instance of DataTableSource',
      () => expect(sut, isA<DataTableSource>()));
  test('row count should be 0', () => expect(sut.rowCount, 0));
  test('row count should be approximate',
      () => expect(sut.isRowCountApproximate, true));
}

void noDataIsAvailable(int pageSize) {
  late FirestoreDataTableSource sut;
  final firestore = FakeFirebaseFirestore();

  setUp(() {
    sut = FirestoreDataTableSource(
      query: firestore.collection('lorem'),
      getDataRow: (snapshot) => const DataRow(cells: []),
      pageSize: pageSize,
    );
  });

  tearDown(() => firestore.clearPersistence());

  group('and first row is requested,', () {
    setUp(() => sut.getRow(0));

    test('it should be null', () => expect(sut.getRow(0), null));
    test('row count should be 0', () => expect(sut.rowCount, 0));
    test('row count should not be approximate',
        () => expect(sut.isRowCountApproximate, false));
  });
}

void twoPagesAreAvailable(int pageSize) {
  late FirestoreDataTableSource sut;
  final firestore = FakeFirebaseFirestore();

  setUp(() async {
    sut = FirestoreDataTableSource(
      query: firestore.collection('lorem'),
      getDataRow: (snapshot) => const DataRow(cells: []),
      pageSize: pageSize,
    );
    await populateFirestore(firestore.collection('lorem'), 2 * pageSize);
  });

  tearDown(() => firestore.clearPersistence());

  group('and first row is requested,', () {
    setUp(() => sut.getRow(0));

    test('it should be a DataRow', () => expect(sut.getRow(0), isA<DataRow>()));
    test('row count should be ${2 * pageSize}',
        () => expect(sut.rowCount, 2 * pageSize));
    test('row count should be approximate',
        () => expect(sut.isRowCountApproximate, true));
  });

  group('and row $pageSize is requested,', () {
    setUp(() => sut.getRow(pageSize));

    test('it should be a DataRow',
        () => expect(sut.getRow(pageSize), isA<DataRow>()));
    test('row count should be ${2 * pageSize}',
        () => expect(sut.rowCount, 2 * pageSize));
    test('row count should not be approximate',
        () => expect(sut.isRowCountApproximate, false));
  });
}

void fourPagesAreAvailable(int pageSize) {
  late FirestoreDataTableSource sut;
  final firestore = FakeFirebaseFirestore();

  setUp(() async {
    sut = FirestoreDataTableSource(
      query: firestore.collection('lorem'),
      getDataRow: (snapshot) => const DataRow(cells: []),
      pageSize: pageSize,
    );
    await populateFirestore(firestore.collection('lorem'), 4 * pageSize);
  });

  tearDown(() => firestore.clearPersistence());

  group('and first row is requested,', () {
    setUp(() => sut.getRow(0));

    test('it should be a DataRow', () => expect(sut.getRow(0), isA<DataRow>()));
    test('row count should be ${2 * pageSize}',
        () => expect(sut.rowCount, 2 * pageSize));
    test('row count should be approximate',
        () => expect(sut.isRowCountApproximate, true));
  });

  group('and row $pageSize is requested,', () {
    setUp(() => sut.getRow(pageSize));

    test('it should be a DataRow',
        () => expect(sut.getRow(pageSize), isA<DataRow>()));
    test('row count should be ${3 * pageSize}',
        () => expect(sut.rowCount, 3 * pageSize));
    test('row count should be approximate',
        () => expect(sut.isRowCountApproximate, true));
  });

  group('and row ${2 * pageSize} is requested,', () {
    setUp(() => sut.getRow(2 * pageSize));

    test('it should be a DataRow',
        () => expect(sut.getRow(2 * pageSize), isA<DataRow>()));
    test('row count should be ${4 * pageSize}',
        () => expect(sut.rowCount, 4 * pageSize));
    test('row count should be approximate',
        () => expect(sut.isRowCountApproximate, true));
  });

  group('and row ${3 * pageSize} is requested,', () {
    setUp(() => sut.getRow(3 * pageSize));

    test('it should be a DataRow',
        () => expect(sut.getRow(3 * pageSize), isA<DataRow>()));
    test('row count should be ${4 * pageSize}',
        () => expect(sut.rowCount, 4 * pageSize));
    test('row count should be approximate',
        () => expect(sut.isRowCountApproximate, false));
  });
}
