library firestore_data_table_source;

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

typedef FilterRow<T> = bool Function(DocumentSnapshot<T> snapshot);

typedef GetDataRow<T> = DataRow Function(DocumentSnapshot<T> snapshot);

class FirestoreDataTableSource<T> extends DataTableSource {
  final List<DocumentSnapshot<T>> _data = [];
  List<DocumentSnapshot<T>> _filteredData = [];

  bool _fetchedAllDocuments = false;
  bool _fetching = false;
  Query<T> _query;
  FilterRow<T>? _filter;

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
    FilterRow<T>? filter,
  })  : _query = query,
        _filter = filter;

  @override
  int get rowCount => _filteredData.length;

  @override
  bool get isRowCountApproximate => !_fetchedAllDocuments;

  @override
  int get selectedRowCount => 0;

  void _fetchData(int index) async {
    if (_fetching) return;

    if (_fetchedAllDocuments) return;

    _fetching = true;
    Query<T> pageQuery = _query;

    if (_data.isNotEmpty) {
      pageQuery = pageQuery.startAfterDocument(_data.last);
    }

    int queryCount = 2 * pageSize;
    if (index - _data.length > pageSize) {
      queryCount += index - _data.length;
    }
    pageQuery = pageQuery.limit(queryCount);

    final QuerySnapshot<T> querySnapshot = await pageQuery.get();
    _data.addAll(querySnapshot.docs);
    _applyFilter();

    if (querySnapshot.docs.length < queryCount) {
      _fetchedAllDocuments = true;
    }

    _fetching = false;
    notifyListeners();
  }

  /// Clear all loaded data
  ///
  /// Note that when associated with [PaginatedDataTable], new data will be
  /// fetched as soon as [getRow] is called.
  void clearData() {
    _data.clear();
    _filteredData.clear();
    _fetchedAllDocuments = false;
    notifyListeners();
  }

  void changeQuery(Query<T> newQuery) {
    _query = newQuery;
    _data.clear();
    _filteredData.clear();
    _fetchedAllDocuments = false;
    notifyListeners();
  }

  void _applyFilter() {
    _filteredData = List<DocumentSnapshot<T>>.from(_data);

    if (_filter != null) _filteredData.retainWhere(_filter!);
  }

  /// Apply a filter to loaded data
  void changeFilter(FilterRow<T> filter) {
    _filter = filter;
    _applyFilter();
    notifyListeners();
  }

  /// Clear all applied filters
  void clearFilter() {
    _filter = null;
    _applyFilter();
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    // Load more items before getting to the end of the list
    if (index > _filteredData.length - pageSize) _fetchData(index);

    if (index >= _filteredData.length) {
      return null;
    }

    return getDataRow(_filteredData[index]);
  }
}
