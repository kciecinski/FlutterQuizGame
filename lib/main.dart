import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Trivia Game'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);


  final String title;
  int points = 0;

  @override
  _MyHomePageState createState() => _MyHomePageState();
  
}

class Answered extends StatefulWidget {
  
    Answered(String answere_value, String correct_answer, int points){
      this.answere_value = answere_value;
      this.correct_answer = correct_answer;
      this.points = points;
    }

    int points; 
    String answere_value;
    String correct_answer;


  @override
  _AnsweredState createState() => _AnsweredState();
}

class _AnsweredState extends State<Answered> {


  @override
  Widget build(BuildContext context) {

    correctAnswereCard(){
      this.widget.points++;
      return Card(child: 
      Padding(
        padding: EdgeInsets.all(30.0),
        child: Text(
          "Correct Answere",
          style: Theme.of(context).textTheme.title,
          textAlign: TextAlign.center,
        ),
      ),

        color: Colors.green,
      );

    }

    badAnswereCard(){
      return Card(child: 
            Padding(
        padding: EdgeInsets.all(30.0),
        child: Text(
          "Bad Answere",
          style: Theme.of(context).textTheme.title,
          textAlign: TextAlign.center
        ),
      ),
        color: Colors.red,
      );
    }

    return  
    Scaffold(
      appBar: AppBar(
      title: Text("Answere"),
    ),
    body: 
    Center(
      child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        widget.correct_answer == widget.answere_value ? correctAnswereCard() : badAnswereCard(),
        FlatButton(
          onPressed: (){ 
            Navigator.pop(
              context,
              {'points':widget.points}
              );
          },
          padding: EdgeInsets.all(5.0),
          child: Text("Next"),
          color: Colors.orange,
          textColor: Colors.white,
        )
      ]
      ),

    )
,
    );}
}


class _MyHomePageState extends State<MyHomePage> {


  final TextEditingController answerFieldController = new TextEditingController();
  int points = 0;


  @override
  Widget build(BuildContext context) {
    answerFieldController.clear();
    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Center(

        child: Column(
          children: <Widget>[
            FutureBuilder <Trivia>(
              future: fetchTrivie(),
              builder: (context,snapshot){
                if(snapshot.hasData){
                  print(snapshot.data.answer);
                  return Column(children: <Widget>[
                    Container(child:
                      Row(children: <Widget>[
                        Expanded(child:
                          Column(children: <Widget>[
                            Text(
                              'Category:',
                            ),
                            Text(
                              snapshot.data.category,
                              style: Theme.of(context).textTheme.subtitle,
                            ),
                          ],),
                        flex: 5,
                        ),
                        Expanded(child: 
                          Column(children: <Widget>[
                            Text(
                              'Points',
                              textAlign: TextAlign.end,
                            ),
                            Text(
                              '${this.points}'
                            )
                          ],),
                        flex: 5,
                        )],
                      ),
                      alignment: Alignment(-1, 4),
                      margin: EdgeInsets.only(bottom: 100,top: 20, left: 15),
                    ),
                    Text(
                      "Question"
                    ),
                    Text(
                    snapshot.data.question,
                    style: Theme.of(context).textTheme.title,
                    textAlign: TextAlign.center,
                    ),
                    Padding(
                    padding: EdgeInsets.all(30.0),
                    child: TextField( 
                        controller: answerFieldController,
                        decoration: InputDecoration(
                          fillColor: Colors.redAccent,
                          hintText: 'Answer:'
                        ),
                    ),
                    ),
                    FlatButton(
                      onPressed: (){
                          _navigateToNewScreen(context,snapshot.data.answer);
                      },
                      padding: EdgeInsets.all(8.0),
                      color: Colors.red.shade200,
                      textColor: Colors.white,
                      child: Text("Submit Answer"),
                    ),
                  ],
                  );
                }else{
                  return Text("Error");
                }
              },
            )
           
          ],
        ),
      ),
    );
  }
    _navigateToNewScreen(BuildContext context, String answer) async {
    Map results = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Answered(answerFieldController.text, answer, this.points) ),
    );
  
    if (results.containsKey('points')) {
      points = results['points'];
    }
  }
}
Future<Trivia> fetchTrivie() async {
  final response = await http.get("http://jservice.io/api/random");

  if(response.statusCode == 200){
   return Trivia.fromJson(json.decode(response.body));
  }else{
    throw Exception("Failed to load");
  }
} 

class Trivia
{
  final String category;
  final String answer;
  final String question;

  Trivia({this.category,this.answer,this.question});

  factory Trivia.fromJson(List<dynamic> json){
    return Trivia(
      question: json[0]['question'],
      answer: json[0]['answer'],
      category: json[0]['category']['title'],
    );
  }

}
