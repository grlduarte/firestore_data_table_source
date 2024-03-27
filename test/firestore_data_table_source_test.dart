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
  final pageSizes = <int>[-1, 0, 1, 2, 10];

  for (int pageSize in pageSizes) {
    if (pageSize <= 0) {
      group('When created with page size of $pageSize',
          () => createdWithInvalidPageSize(pageSize));
      continue;
    }

    group('With page size of $pageSize row(s),', () {
      group('when created', () => firstInitialized(pageSize));

      group('when no data is available', () => noDataIsAvailable(pageSize));

      group('when ${2 * pageSize} rows are available',
          () => twoPagesAreAvailable(pageSize));

      group('when ${4 * pageSize} rows are available',
          () => fourPagesAreAvailable(pageSize));

      group('when data is filtered with no results',
          () => dataIsFilteredWithNoResults(pageSize));
    });
  }
}

void createdWithInvalidPageSize(int pageSize) {
  final firestore = FakeFirebaseFirestore();
  FirestoreDataTableSource createSut() => FirestoreDataTableSource(
        query: firestore.collection('lorem'),
        getDataRow: (snapshot) => const DataRow(cells: []),
        pageSize: pageSize,
      );

  test('it should raise an assertion error', () {
    expect(() => createSut(), throwsAssertionError);
  });
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

void dataIsFilteredWithNoResults(int pageSize) {
  late FirestoreDataTableSource sut;
  final firestore = FakeFirebaseFirestore();

  setUp(() async {
    sut = FirestoreDataTableSource(
      query: firestore.collection('lorem'),
      getDataRow: (snapshot) => const DataRow(cells: []),
      filter: (snapshot) => false,
      pageSize: pageSize,
    );
    await populateFirestore(firestore.collection('lorem'), 2 * pageSize);
  });

  tearDown(() => firestore.clearPersistence());

  group('and first row is requested,', () {
    setUp(() => sut.getRow(0));

    test('it should be null', () => expect(sut.getRow(0), null));
    test('row count should be 0', () => expect(sut.rowCount, 0));
    test('row count should be approximate',
        () => expect(sut.isRowCountApproximate, true));
  });

  group('and a full page is requested,', () {
    setUp(() => sut.getRow(pageSize + 1));

    test('first row should be null', () => expect(sut.getRow(0), null));
    test('row count should be 0', () => expect(sut.rowCount, 0));
    test('row count should not be approximate',
        () => expect(sut.isRowCountApproximate, false));
  });

  group('and the filter is removed after a full page is requested,', () {
    setUp(() {
      sut.getRow(pageSize + 1);
      sut.clearFilter();
    });

    test('row count should be ${2 * pageSize}',
        () => expect(sut.rowCount, 2 * pageSize));
    test('row count should not be approximate',
        () => expect(sut.isRowCountApproximate, false));
  });
}
