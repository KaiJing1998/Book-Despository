import 'dart:convert';
import 'package:bookdepo/books.dart';
import 'package:bookdepo/detailScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animations/loading_animations.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List booksList;
  double screenHeight, screenWidth;
  String titlecenter = "Loading BookList...";
  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('List of Books'),
      ),
      body: Column(
        children: [
          // we need to use this is for the brief second when the data is loading and the layout already come out it won't get error
          booksList == null
              // use flexible to resize base on the data
              // if restList == null, it will execute first layout which is flexible "titlecenter = No Data Found"
              ? Flexible(
                  child: Container(
                      child: Center(
                          child: Text(
                  titlecenter,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ))))
              //display the data, second layout if restList != null
              : Flexible(
                  child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: (screenWidth / screenHeight) / 1.2,
                  children: List.generate(booksList.length, (index) {
                    return Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Card(
                        child: InkWell(
                          //we want to pass index because we want to deals it with restlist
                          onTap: () => _loadBooksDetail(index),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                      height: screenHeight / 2.8,
                                      width: screenWidth / 1.2,
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            "https://techvestigate.com/bookDepo/bookCover/${booksList[index]['bookcover']}.jpg",
                                        fit: BoxFit.fill,
                                        placeholder: (context, url) =>
                                            LoadingFlipping.circle(),
                                        errorWidget: (context, url, error) =>
                                            new Icon(
                                          Icons.broken_image,
                                          size: screenWidth / 3,
                                        ),
                                      )),
                                  Positioned(
                                    child: Container(
                                        //color: Colors.white,
                                        margin: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Colors.white,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        child: Row(
                                          children: [
                                            Text(booksList[index]['bookrating'],
                                                style: TextStyle(
                                                    color: Colors.black)),
                                            Icon(Icons.star,
                                                color: Colors.yellow),
                                          ],
                                        )),
                                    bottom: 10,
                                    right: 10,
                                  )
                                ],
                              ),
                              SizedBox(height: 5),
                              Text(
                                booksList[index]['booktitle'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Align(
                                child: Text(
                                  'By : ' + booksList[index]['bookauthor'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'RM' + booksList[index]['bookprice'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ))
        ],
      ),
    );
  }

  void _loadBooks() {
    http.post("https://techvestigate.com/bookDepo/php/load_books.php",
        body: {}).then((res) {
      print(res.body);
      if (res.body == "nodata") {
        booksList = null;
        setState(() {
          print(" No data");
        });
      } else {
        setState(() {
          var jsondata = json.decode(res.body);
          booksList = jsondata["books"];
        });
      }
    }).catchError((err) {
      print(err);
    });
  }

  _loadBooksDetail(int index) {
    print(booksList[index]['booktitle']);

    Books books = new Books(
        // pass all the parameter
        bookid: booksList[index]['bookid'],
        booktitle: booksList[index]['booktitle'],
        bookauthor: booksList[index]['bookauthor'],
        bookprice: booksList[index]['bookprice'],
        bookdescription: booksList[index]['bookdescription'],
        bookrating: booksList[index]['bookrating'],
        bookpublisher: booksList[index]['bookpublisher'],
        bookisbn: booksList[index]['bookisbn'],
        bookcover: booksList[index]['bookcover']);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => DetailsScreen(books: books)));
  }
}
