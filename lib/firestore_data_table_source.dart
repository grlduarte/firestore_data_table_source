library firestore_data_table_source;

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

typedef GetDataRow<T> = DataRow Function(DocumentSnapshot<T> snapshot);

class FirestoreDataTableSource<T> extends DataTableSource {
  final List<DocumentSnapshot<T>> _data = [];

  int _rowCount = 0;
  bool _fetchedAllDocuments = false;
  bool _fetching = false;
  final Query<T> _query;

  /// Function used to assemble the DataRow
  final GetDataRow<T> getDataRow;

  /// Number of documents fetched at a time
  ///
  /// Ideally this is the same number used with the
  /// [PaginatedDataTable.rowsPerPage] property.
  ///
  /// This value is optional and defaults to 10 if not specified.
  final int pageSize;

  FirestoreDataTableSource({
    required Query<T> query,
    required this.getDataRow,
    this.pageSize = 10,
  }) : _query = query;

  @override
  int get rowCount => _rowCount;

  @override
  bool get isRowCountApproximate => !_fetchedAllDocuments;

  @override
  int get selectedRowCount => 0;

  void _fetchData() async {
    if (_fetching) return;

    if (_fetchedAllDocuments) return;

    _fetching = true;
    Query<T> pageQuery = _query.limit(pageSize);

    if (_data.isNotEmpty) {
      pageQuery = pageQuery.startAfterDocument(_data.last);
    }

    final QuerySnapshot<T> querySnapshot = await pageQuery.get();
    _data.addAll(querySnapshot.docs);

    if (querySnapshot.docs.length < pageSize) {
      _fetchedAllDocuments = true;
      _rowCount = _data.length;
    } else {
      _rowCount += pageSize;
    }

    _fetching = false;
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    // Load more items before getting to the end of the list
    if (index > _data.length - pageSize) _fetchData();

    if (index >= _data.length) {
      return null;
    }

    return getDataRow(_data[index]);
  }
}
