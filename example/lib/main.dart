import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_data_table_source/firestore_data_table_source.dart';

import 'firebase_options.dart';
import 'user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FirestoreDataTableSource Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'FirestoreDataTableSource Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final firestore = FirebaseFirestore.instance;
  static final usersRef = firestore.collection('users').withConverter<User>(
        fromFirestore: (snapshot, _) => User.fromJson(snapshot.data()!),
        toFirestore: (user, _) => user.toJson(),
      );

  final int rowsPerPage = 10;
  final _filterController = TextEditingController();
  final _dataTableKey = GlobalKey<PaginatedDataTableState>();

  late FirestoreDataTableSource<User> _dataSource;

  int? _sortColumn;
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();

    _dataSource = FirestoreDataTableSource<User>(
      query: usersRef,
      getDataRow: getDataRow,
      pageSize: rowsPerPage,
    );
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  DataRow getDataRow(DocumentSnapshot<User> snapshot) {
    User user = snapshot.data()!;

    return DataRow(
      cells: <DataCell>[
        DataCell(Text(snapshot.id)),
        DataCell(Text(user.name)),
        DataCell(Text(user.lastName)),
      ],
    );
  }

  void onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumn = columnIndex;
      _sortAscending = ascending;
    });

    Query<User>? query;

    switch (columnIndex) {
      case 1:
        // Name column
        query = usersRef.orderBy('name', descending: ascending);
        break;

      case 2:
        // LastName column
        query = usersRef.orderBy('lastName', descending: ascending);
        break;
    }

    if (query != null) _dataSource.changeQuery(query);
  }

  void onNameFilterChanged(String text) {
    _dataSource.changeFilter((DocumentSnapshot<User> snapshot) {
      User user = snapshot.data()!;

      bool nameMatches = user.name.toLowerCase().startsWith(text.toLowerCase());
      bool lastNameMatches =
          user.lastName.toLowerCase().startsWith(text.toLowerCase());

      return nameMatches || lastNameMatches;
    });

    // Changes the DataTable to the first page every time the filter changes
    _dataTableKey.currentState?.pageTo(0);
  }

  void onClearFilter() {
    _dataSource.clearFilter();
    _filterController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final columns = <DataColumn>[
      const DataColumn(
        label: Text('User Id'),
      ),
      DataColumn(
        label: const Text('Name'),
        onSort: onSort,
      ),
      DataColumn(
        label: const Text('Last Name'),
        onSort: onSort,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: PaginatedDataTable(
            key: _dataTableKey,
            source: _dataSource,
            columns: columns,
            header: TextField(
              controller: _filterController,
              decoration: InputDecoration(
                hintText: 'Filter by Name or Last Name',
                suffixIcon: IconButton(
                  onPressed: onClearFilter,
                  icon: const Icon(Icons.cancel),
                ),
              ),
              onChanged: onNameFilterChanged,
            ),
            rowsPerPage: rowsPerPage,
            sortColumnIndex: _sortColumn,
            sortAscending: _sortAscending,
          ),
        ),
      ),
    );
  }
}
