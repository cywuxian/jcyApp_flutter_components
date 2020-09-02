import 'package:flutter/material.dart';
import 'package:flutter_components/widgets.dart';
import 'view/ListGroupView.dart';
import 'view/ToastVIew.dart';
import 'view/ColorView.dart';
import 'view/FormView.dart';
import 'view/NoticeBarView.dart';
import 'view/ResultView.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ToastInit(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
        ).copyWith(
          primaryColor: Color(0xff409bff)
        ),
        navigatorObservers: [BotToastNavigatorObserver()],
        home: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    ViewportUtil.init(context);
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: ListGroupView() // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}