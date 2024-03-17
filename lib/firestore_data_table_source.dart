library firestore_data_table_source;

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

typedef GetDataRow<T> = DataRow Function(DocumentSnapshot<T> snapshot);

class FirestoreDataTableSource<T> extends DataTableSource {
  final Query<T> _query;

  List<DocumentSnapshot<T>> _data = [];
  int _rowCount = 0;
  bool _isRowCountApproximate = true;

  final GetDataRow<T> getDataRow;

  FirestoreDataTableSource({
    required Query<T> query,
    required this.getDataRow,
  }) : _query = query {
    _fetchData();
  }

  @override
  int get rowCount => _rowCount;

  @override
  bool get isRowCountApproximate => _isRowCountApproximate;

  @override
  int get selectedRowCount => 0;

  void _fetchData() async {
    final querySnapshot = await _query.get();
    _data = querySnapshot.docs;

    _rowCount = _data.length;
    _isRowCountApproximate = false;
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    if (index >= _data.length) {
      return null;
    }

    return getDataRow(_data[index]);
  }
}
