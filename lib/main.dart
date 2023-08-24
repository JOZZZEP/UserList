import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:list_users/pages/user_detail.dart';

import 'models/users.dart';
import 'services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Member List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Member'),
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
  late Users users;
  late String title;

  final deboundcer = Deboundcer(milliseconds: 3000);

  @override
  void initState() {
    super.initState();
    title = 'Loading users...';
    users = Users();

    Services.getUsers().then((userFromServer) => {
          setState(() {
            users = userFromServer;
            title = widget.title;
          })
        });
  }

  Widget list() {
    return Expanded(
      child: ListView.builder(
        itemCount: users.users.isEmpty ? 0 : users.users.length,
        itemBuilder: (BuildContext context, int index) {
          return row(index);
        },
      ),
    );
  }

  Widget row(int index) {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.person,
        ),
        title: Text(
          users.users[index].name,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          users.users[index].email.toLowerCase(),
          style: const TextStyle(
            fontSize: 14.0,
            color: Colors.grey,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
        ),
        onTap: () => Get.to(() => UserDetail(user: users.users[index])),
      ),
    );
  }

  Widget searchTF() {
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(
            5.0,
          )),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.all(15.0),
        hintText: 'Filter by name or email',
      ),
      onChanged: (string) {
        deboundcer.run(() {
          setState(() {
            title = "Searching...";
          });
          Services.getUsers().then((userFromServer) {
            setState(() {
              users = Users.filterList(userFromServer, string);
              title = widget.title;
            });
          });
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              searchTF(),
              const SizedBox(
                height: 10,
              ),
              list(),
            ],
          ),
        ));
  }
}

class Deboundcer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Deboundcer({required this.milliseconds});

  run(VoidCallback action) {
    if (_timer != null) _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
