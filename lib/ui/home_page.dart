import 'dart:convert';

import 'package:buscador_gifs/ui/gif_page.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String _search;
  int _offset=0;
  Future<Map> _getGifs() async {
    http.Response response;

    if(_search == null || _search == ""){
      response = await http.get(Uri.parse("https://api.giphy.com/v1/gifs/trending?api_key=3KwgUedn14AScLnUHXwl3FcO2qllmDRw&limit=20&rating=g"));
    }else{
      response = await http.get(Uri.parse("https://api.giphy.com/v1/gifs/search?api_key=3KwgUedn14AScLnUHXwl3FcO2qllmDRw&q=$_search&limit=19&offset=$_offset&rating=g&lang=en"));
    }
    return json.decode(response.body);

  }
  @override
  void initState(){
    super.initState();
    _getGifs().then((map){
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title:Image.network("https://developers.giphy.com/static/img/dev-logo-lg.gif",)
        ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Pesquise aqui",
                labelStyle: TextStyle(color:Colors.white),
                border: OutlineInputBorder()

              ),
              style: TextStyle(color: Colors.white,fontSize: 18.0),
              textAlign: TextAlign.center,
              onSubmitted: (text){
                setState(() {
                  _search=text;
                  _offset = 0;
                });
              }
              ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                  return Container(
                    width:200,
                    height: 200,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      valueColor:AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 4.0,
                      ),
                  );
                  default: 
                    if(snapshot.hasError) return Container();
                    else return _createGifTable(context,snapshot);
                }
              },
              ) 
            ,)
      ],),   
    );
  }
  int _getCount(List data){
    if(_search==null || _search==""){
      return data.length;
    }else{
      return data.length+1;
    }
  }
  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot){
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing:10.0
      ),
      itemCount: _getCount(snapshot.data["data"]),
      itemBuilder: (context, index){
        print(_search);
        if(_search == null || _search == "" || index<snapshot.data["data"].length){
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
              height: 300.0,
              fit: BoxFit.cover,


              ),
            onTap: (){
              Navigator.push(context,
                MaterialPageRoute(builder: (context)=>GifPage(snapshot.data["data"][index]))
              );
            },
            onLongPress: (){
              Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
            } ,
          )
          ;}
          else{
            return Container(
                color: Colors.blueGrey,
              child: GestureDetector(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.white,size: 70,),
                      Text("Carregar mais...",
                        style: TextStyle(color: Colors.white,fontSize: 18.0),)
                    ],
                  ),
                  onTap: (){
                    setState(() {
                      _offset +=19;
                    });
                  },
                ),
                
            
            );
          }
      },
      );
  }
}