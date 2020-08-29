import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:core';
import 'package:uuid/uuid.dart';

void main() {
  runApp(TodoApp());
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

  Todo clone() {
    Todo newTodo = Todo(title,note);
    newTodo.id = id;
    return newTodo;
  }

  assignUUID() {
    id = Uuid().v4();
  }
}

class TodoBloc {
  
  static final List<Todo> sampleTodos = [];

  final _todoController = StreamController<List<Todo>>();
  Stream<List<Todo>> get todoStream => _todoController.stream;

  getTodos() {
    _todoController.sink.add(sampleTodos);
  }

  TodoBloc() {
    getTodos();
  }

  dispose() {
    _todoController.close();
  }

  create(Todo todo) {
    todo.assignUUID();
    sampleTodos.add(todo);
    getTodos();
  }

  update(Todo todo) {
    int _index = sampleTodos.indexWhere((Todo t) => t.id == todo.id);
    if(_index >=0) {
      sampleTodos[_index] = todo;
      getTodos();
    }
  }

  delete(String id) {
    int _index = sampleTodos.indexWhere((Todo t) => t.id == id);
    if(_index >= 0) {
      sampleTodos.removeAt(_index);
      getTodos();
    }
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