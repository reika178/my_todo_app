import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // visualDensity: VisualDensity.adaptivePlatformDensity,
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Todo'),
      ),
      body: ListView(
        children: List.generate(10, (index) {
          return InkWell(
            onTap: (){

            },
            child: Card(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(10.0),
                    child: ListTile(
                      title: Text("テスト$index"),
                      subtitle: Text("サブタイトル"),
                    )
                  ),
                ],
              ),
            ),
          );
        }
        ),
      ),
      floatingActionButton: new FloatingActionButton(
          child: new Icon(Icons.add),
          onPressed: () {
            
          },
      ),
    );
  }
}
