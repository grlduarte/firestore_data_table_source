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
  final int rowsPerPage = 15;
  late FirestoreDataTableSource<User> _dataSource;

  @override
  void initState() {
    super.initState();

    _dataSource = FirestoreDataTableSource<User>(
      query: usersRef,
      getDataRow: getDataRow,
    );
  }

  DataRow getDataRow(DocumentSnapshot<User> snapshot) {
    User user = snapshot.data()!;

    return DataRow(
      cells: <DataCell>[
        DataCell(Text(snapshot.id)),
        DataCell(Text(user.name)),
        DataCell(Text(user.lastName)),
        DataCell(Text(user.birthday.toString())),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const columns = <DataColumn>[
      DataColumn(label: Text('User Id')),
      DataColumn(label: Text('Name')),
      DataColumn(label: Text('Last Name')),
      DataColumn(label: Text('Birthday')),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: PaginatedDataTable(
          columns: columns,
          source: _dataSource,
          rowsPerPage: rowsPerPage,
        ),
      ),
    );
  }
}
