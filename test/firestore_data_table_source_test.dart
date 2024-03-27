import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firestore_data_table_source/firestore_data_table_source.dart';

void main() async {
  const pageSize = 10;

  group('When created', () => firstInitialized(pageSize));

  group('When no data is available', () => noDataIsAvailable(pageSize));
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
