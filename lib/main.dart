import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("crud");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const crudapp(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class crudapp extends StatefulWidget {
  const crudapp({super.key});

  @override
  State<crudapp> createState() => _crudappState();
}

class _crudappState extends State<crudapp> {
  TextEditingController usernamecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController datecontroller = TextEditingController();
  List all = [];

  var lr = Hive.box("crud");

  createdata(Map<String, dynamic> row) async {
    await lr.add(row);
    readall();
  }

  update(int? key, Map<String, dynamic> row) async {
    await lr.put(key, row);
    readall();
  }

  readall() async {
    var dataa = lr.keys.map((e) {
      final items = lr.get(e);
      return {
        "key": e,
        "user": items["user"],
        "email": items["email"],
        "date": items["date"],
      };
    }).toList();
    setState(() {
      all = dataa.reversed.toList();
    });
  }

  @override
  void initState() {
    super.initState();
    readall();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hive Local User Database"),
        centerTitle: true,
        titleTextStyle: TextStyle(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 107, 129, 180),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          crudmodal(0);
        },
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: all.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8),
            shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(
                  color: Color(0xff76b5c5),
                )),
            child: ListTile(
              title: Text("Username:"+" "+all[index]["user"]),
             subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Email:"+" "+all[index]["email"]),
                  Text("Date Of Birth:"+" "+all[index]["date"]),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      var updatevalue = all[index]["key"];
                      crudmodal(updatevalue);
                    },
                    icon: Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () {
                      var deletevalue = all[index]["key"];
                      lr.delete(deletevalue);
                      readall();
                    },
                    icon: Icon(Icons.delete),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void crudmodal(int id) {
    usernamecontroller.clear();
    emailcontroller.clear();
    datecontroller.clear();

    if (id != 0) {
      final item = all.firstWhere(
        (element) => element["key"] == id,
      );
      usernamecontroller.text = item["user"];
      emailcontroller.text = item["email"];
      datecontroller.text = item["date"];
    }

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(30, 30, 30, MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernamecontroller,
                decoration: InputDecoration(hintText: "Enter Username"),
              ),
              TextField(
                controller: emailcontroller,
                decoration: InputDecoration(hintText: "Enter Email"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: datecontroller,
                decoration: InputDecoration(hintText: "Enter Date of Birth"),
                readOnly: true, 
                onTap: () async {
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      datecontroller.text = "${selectedDate.toLocal()}".split(' ')[0]; 
                    });
                  }
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  String user = usernamecontroller.text.toString();
                  String email = emailcontroller.text.toString();
                  String date = datecontroller.text.toString();
                  var data = {"user": user, "email": email, "date": date};
                  if (id == 0) {
                    createdata(data);
                  } else {
                    update(id, data);
                  }
                  Navigator.pop(context);
                },
                child: id == 0 ? Text("Add") : Text("Update"),
              )
            ],
          ),
        );
      },
    );
  }
}
