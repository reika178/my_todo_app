import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:core';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(TodoApp());
}

class Todo {
  String id;
  String title;
  String note;

  Todo({this.id, @required this.title, @required this.note});
  Todo.newTodo() {
    title = "";
    note = "";
  }

  assignUUID() {
    id = Uuid().v4();
  }

  factory Todo.fromMap(Map<String, dynamic> json) => Todo(
    id: json["id"],
    title: json["title"],
    note: json["note"] 
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "title": title,
    "note": note
  };
}

class TodoBloc {
  
  final _todoController = StreamController<List<Todo>>();
  Stream<List<Todo>> get todoStream => _todoController.stream;

  getTodos() async {
    _todoController.sink.add(await DBProvider.db.getAllTodos());
  }

  TodoBloc() {
    getTodos();
  }

  dispose() {
    _todoController.close();
  }

  create(Todo todo) {
    todo.assignUUID();
    DBProvider.db.createTodo(todo);
    getTodos();
  }

  update(Todo todo) {
    DBProvider.db.updateTodo(todo);
    getTodos();
  }

  delete(String id) {
    DBProvider.db.deleteTodo(id);
    getTodos();
  }
}

class TodoApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ConstText.appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Provider<TodoBloc>(
        create: (context) => new TodoBloc(),
        dispose: (context, bloc) => bloc.dispose(),
        child: TodoListView()
        ),
    );
  }
}

class TodoListView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
  final _bloc = Provider.of<TodoBloc>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text(ConstText.todoListView)),
      body: StreamBuilder<List<Todo>>(
        stream: _bloc.todoStream,
        builder: (BuildContext context, AsyncSnapshot<List<Todo>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {

                Todo todo = snapshot.data[index];

                return Dismissible(
                  key: Key(todo.id),
                  background: _backgroundOfDismissible(),
                  secondaryBackground: _secondaryBackgroundOfDismissble(),
                  onDismissed: (direction) {
                      _bloc.delete(todo.id);
                  },
                  child: Card(
                    child: ListTile(
                      onTap: () {
                        _moveToEditView(context, _bloc, todo);
                      },
                      title: Text("${todo.title}"),
                      subtitle: Text("${todo.note}"),
                      isThreeLine: true,
                    )
                  ),
                );
              },
            );
          } 
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () { _moveToCreateView(context, _bloc);},
      ),
    );
  }

_moveToEditView(BuildContext context, TodoBloc bloc, Todo todo) => Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => AddTodo(todoBloc: bloc, todo: todo))
);

_moveToCreateView(BuildContext context, TodoBloc bloc) => Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => AddTodo(todoBloc: bloc, todo: Todo.newTodo()))
);

_backgroundOfDismissible() => Container(
  alignment: Alignment.centerLeft,
  color: Colors.green,
  child: Padding(
    padding: EdgeInsets.fromLTRB(20,0,0,0),
    child: Icon(Icons.done, color: Colors.white),
  )
);

_secondaryBackgroundOfDismissble() => Container(
  alignment: Alignment.centerRight,
  color: Colors.green,
  child: Padding(
    padding: EdgeInsets.fromLTRB(0,0,20,0),
    child: Icon(Icons.done, color: Colors.white),
  )
);
}


class AddTodo extends StatelessWidget {

  final TodoBloc todoBloc;
  final Todo todo;
  final Todo _newTodo = Todo.newTodo();

  AddTodo({Key key, @required this.todoBloc, @required this.todo}) {
    _newTodo.id = todo.id;
    _newTodo.title = todo.title;
    _newTodo.note = todo.note;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(title: Text(ConstText.todoEditView),),
        body: Container(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: <Widget>[
              _titleTextFormField(),
              _noteTextFormField(),
              _confirmButton(context)
            ],
          ),
        ),
     );
   }

  Widget _titleTextFormField() => TextFormField(
    decoration: InputDecoration(labelText: "タイトル"),
    initialValue: _newTodo.title,
    onChanged: _setTitle,
  );

  void _setTitle(String title) {
    _newTodo.title = title;
  }

  Widget _noteTextFormField() => TextFormField(
    decoration: InputDecoration(labelText: "メモ"),
    initialValue: _newTodo.note,
    maxLines: 3,
    onChanged: _setNote,
  );

  void _setNote(String note) {
    _newTodo.note = note;
  }

  Widget _confirmButton(BuildContext context) => RaisedButton(
    child: Text("Add"),
    onPressed: () {
      if (_newTodo.id == null) {
        todoBloc.create(_newTodo);
      } else {
        todoBloc.update(_newTodo);
      }
    Navigator.of(context).pop();
    },
  );
}

class ConstText {
  static final appTitle = "Todo App";
  static final todoListView = "Todo List";
  static final todoEditView = "Todo Edit";
  static final todoCreateView = "New Todo";
}

// データベースを取得する関数を追加

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static Database _database;
  static final _tableName = "Todo";

  Future<Database> get database async {
    if (_database != null)
      return _database;

    // DBがなかったら作る
    _database = await initDB();
    return _database;
  }

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    String path = join(documentsDirectory.path, "TodoDB.db");

    return await openDatabase(path, version: 1, onCreate: _createTable);
  }

  Future<void> _createTable(Database db, int version) async {
    return await db.execute(
      "CREATE TABLE $_tableName ("
      "id TEXT PRIMARY KEY,"
      "title TEXT,"
      "note TEXT"
      ")"
    );
  }

  createTodo(Todo todo) async {
    final db = await database;
    var res = await db.insert(_tableName, todo.toMap());
    return res;
  }

  getAllTodos() async {
    final db = await database;
    var res = await db.query(_tableName);
    List<Todo> list =
        res.isNotEmpty ? res.map((c) => Todo.fromMap(c)).toList() : [];
    return list;
  }

  updateTodo(Todo todo) async {
    final db = await database;
    var res = await db.update(
      _tableName,
      todo.toMap(),
      where: "id = ?",
      whereArgs: [todo.id]
    );
    return res;
  }

  deleteTodo(String id) async {
    final db = await database;
    var res = db.delete(
      _tableName,
      where: "id = ?",
      whereArgs: [id]
    );
    return res;
  }

}