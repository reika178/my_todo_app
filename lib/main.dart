import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class Todo {
  String id;
  String title;
  String note;

  Todo(this.title, this.note);

  Todo.newTodo() {
    title = "";
    note = "";
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'My Todo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final items = List<String>.generate(20,(i) => "Item ${i + 1}");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Todo'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          Todo todo = Todo(
            "タイトル $index",
            "タイトル $indexのメモです。タイトル $indexのメモです。"
          );
          final item = items[index];

          return Dismissible(
            key: Key(item),
            onDismissed: (direction) {
              setState(() {
                items.removeAt(index);
              });
            },
              background: Container(
                color: Colors.red),
            child: Card(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(10.0),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditTodo())
                          );
                      },
                      title: Text("${todo.title}"),
                      subtitle: Text("${todo.note}"),
                    )
                  ),
                ],
              ),
            )
          );

        }
        ),
      floatingActionButton: new FloatingActionButton(
          child: new Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddTodo()),
            );
          },
      ),
    );
  }
}

class AddTodo extends StatelessWidget {

  // final DateFormat _format = DateFormat("yyyy-MM-dd HH:mm");

  // final TodoBloc todoBloc;
  final Todo todo;
  final Todo _newTodo = Todo.newTodo();

  AddTodo({Key key, @required this.todo}) {
  // AddTodo({Key key, @required this.todoBloc, @required this.todo}) {
    _newTodo.id = todo.id;
    _newTodo.title = todo.title;
    _newTodo.note = todo.note;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar:AppBar(
      title: Text('AddTodo'),
      ),
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

  void _setNote(String title) {
    _newTodo.title = title;
  }

  Widget _confirmButton(BuildContext context) => RaisedButton(
    child: Text("Add"),
    onPressed: () {
      // if (_newTodo.id == null) {

      // }
    Navigator.of(context).pop();
    },
  );

}

class EditTodo extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar:AppBar(
      title: Text('EditTodo'),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('戻る'),
        ),
      ),
  );
}