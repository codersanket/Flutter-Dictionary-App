import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dictonary',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
String _token="Your Token";
String _url="https://owlbot.info/api/v4/dictionary/";
TextEditingController _controller=TextEditingController();
StreamController _streamController;
Stream _stream;
Timer dbounce;


@override
void initState() {
  super.initState();
  _streamController=StreamController();
  _stream=_streamController.stream;
}

_search()async{
if(_controller.text == null || _controller.text.length==0){
  _streamController.add(null);
  return ;
}
_streamController.add("Waiting");
Response response=await get(_url + _controller.text.trim(),headers: {"Authorization": "Token " + _token});
_streamController.add(jsonDecode(response.body));
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Dictonary"),
        bottom: PreferredSize(child: Row(
          children: [
            Expanded(child: Container(
              margin: EdgeInsets.only(left: 12,bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),

              ),
              child: TextFormField(

                decoration: InputDecoration(
                  hintText: "Search For Word",
                  contentPadding: EdgeInsets.only(left: 24)
                ),
                onChanged: (text){
                  if(dbounce?.isActive ?? false)dbounce.cancel();
                  dbounce =Timer(Duration(milliseconds:1000 ),(){
                    _search();
                  } );
                },
                controller: _controller,
              ),
            )),
            IconButton(icon: Icon(Icons.search,color: Colors.white,), onPressed: (){
              _search();
            })
          ],
        ), preferredSize: Size.fromHeight(48)),

      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: StreamBuilder(builder: (BuildContext context,AsyncSnapshot snapshot){
          if(snapshot.data==null){
            return Center(
              child: Text("Enter a Search Word"),
            );
          }
          if(snapshot.data=="Waiting"){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(itemBuilder: (BuildContext context,int index){
           return ListBody(
             children: [
               Container(
                 color: Colors.grey[300],
                 child:ListTile(
                   leading: snapshot.data["definitions"][index]["image_url"]==null ?null:CircleAvatar(
                     backgroundImage: NetworkImage(snapshot.data["definitions"][index]["image_url"]),

                   ),
                   title: Text(_controller.text.trim() + "(" + snapshot.data["definitions"][index]["type"] +")" ),
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Text(snapshot.data["definitions"][index]["definition"]),
               )
             ],
           );
          },
          itemCount: snapshot.data["definitions"].length,
          );
        },stream: _stream,),
      ),
    );
  }
}
