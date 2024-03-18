# Firestore DataTableSource

This package provides a [DataTableSource][data-table-source] to be used with a
[PaginatedDataTable][paginated-data-table] that can fetch Firestore elements
using a [Query][query-api] object and filter them in dart.

If you're looking for a quick way to display your Firestore data in a paginated
data table, check out Google's official [Firebase UI for
Firestore][flutterfire_ui_firestore]. On the other hand, if you need more
flexibility and customization, this package might be what you need.

## Usage

For a more complete example, check the [example app](example/).

```dart
final dataSource = FirestoreDataTableSource(
  query: FirebaseFirestore.instance.collection('my-collection'),
  getDataRow: (snapshot) => DataRow(
    cells: <DataCell>[DataCell(Text(snapshot.id))],
  ),
);

...

PaginatedDataTable(
  source: dataSource,
  columns: const <DataColumn>[
    DataColumn(label: Text("Id")),
  ],
);
```

## Additional information

To file feature requests or bugs, visit the [issues page][issues].

[issues]: https://github.com/grlduarte/firestore_data_table_source/issues
[flutterfire_ui_firestore]: https://pub.dev/packages/firebase_ui_firestore
[data-table-source]: https://api.flutter.dev/flutter/material/DataTableSource-class.html
[paginated-data-table]: https://api.flutter.dev/flutter/material/PaginatedDataTable-class.html
[query-api]: https://pub.dev/documentation/cloud_firestore/latest/cloud_firestore/Query-class.html
