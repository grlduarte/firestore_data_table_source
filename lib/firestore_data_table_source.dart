library firestore_data_table_source;

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

typedef GetDataRow<T> = DataRow Function(DocumentSnapshot<T> snapshot);

class FirestoreDataTableSource<T> extends DataTableSource {
  final Query<T> _query;

  List<DocumentSnapshot<T>> _data = [];
  int _rowCount = 0;
  bool _isRowCountApproximate = true;
  bool _fetching = false;

  final GetDataRow<T> getDataRow;

  FirestoreDataTableSource({
    required Query<T> query,
    required this.getDataRow,
  }) : _query = query;

  @override
  int get rowCount => _rowCount;

  @override
  bool get isRowCountApproximate => _isRowCountApproximate;

  @override
  int get selectedRowCount => 0;

  void _fetchData() async {
    if (_fetching) return;

    _fetching = true;
    final querySnapshot = await _query.get();
    _data = querySnapshot.docs;

    _rowCount = _data.length;
    _isRowCountApproximate = false;
    _fetching = false;
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    if (_data.isEmpty) {
      _fetchData();
    }

    if (index >= _data.length) {
      return null;
    }

    return getDataRow(_data[index]);
  }
}
