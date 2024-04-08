import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('loginOk') ?? false;
  final role = prefs.getString('role') ?? "";
  final accName = prefs.getString('name') ?? "";
  final usernamea = prefs.getString('username') ?? "";
  final password = prefs.getString('password') ?? "";

  runApp(rotePage(isLoggedIn: isLoggedIn , role : role , accName : accName , usernamea : usernamea , password : password)

  );
}

class rotePage extends StatefulWidget {
  final bool isLoggedIn;
  final String role;
  final String accName;
  final String usernamea;
  final String password;

  const rotePage({super.key, required this.isLoggedIn , required this.role , required this.accName , required this.usernamea , required this.password });


  @override
  State<rotePage> createState() => _rotePageState();
}

class _rotePageState extends State<rotePage> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyApp',
      home: widget.isLoggedIn ? MyHomePage(isLoggedIn: widget.isLoggedIn , role : widget.role , accName :widget.accName , usernamea : widget.usernamea , password : widget.password) : MyApp(),
    );
  }
}



class MyApp extends StatefulWidget {


  const MyApp({super.key,});

  @override

  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  var look = true;
  var name = TextEditingController();
  var passw = TextEditingController();
  String msg = "";

  String _responseData = "";

  Future<void> _makePostRequest( String user, String pass) async {
    String url = "http://192.168.1.6:5000/mobileAPIauth"; // Replace with your API URL

    Map<String, dynamic> data = {
      "username": user,
      "password": pass,
      "action":"Login",
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: data,
      );

      if (response.statusCode == 200) {
        setState(() {
          _responseData = response.body;
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: MaterialApp(

        home: Scaffold(
          appBar:AppBar(
            title: const Text('Campus Coin',style: TextStyle(color: Colors.pink,fontSize: 35.0,fontWeight: FontWeight.bold )),
            backgroundColor: Colors.teal,
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
      // body: MyHomePage(),
            body: Container (
      color: Colors.teal,
      child:
      Padding(
      padding: EdgeInsets.all(20.0),

        child:Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color:Colors.white ,

          ),

        child: ListView(

        children: [
          SizedBox(height: 50.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('LOGIN' ,style: TextStyle(color: Colors.pink,fontSize: 45.0,fontWeight: FontWeight.bold ),),

            ],
          ),

        SizedBox(height: 50.0,),
        Container(child: TextFormField(decoration: InputDecoration(hintText: ' user ' , labelText: 'user name: ' ,border: OutlineInputBorder(),prefixIcon:Icon(Icons.email),


        ),

          controller: name,
          keyboardType: TextInputType.emailAddress,
          onFieldSubmitted: (v){  //onChanged:
            print(v);
          },
        ),
          margin: EdgeInsets.symmetric(horizontal: 20.0),
        ),


        SizedBox(height: 50.0,),

        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.0),
          child: TextFormField(decoration: InputDecoration(hintText: ' pass ' , labelText: 'pass: ' ,border: OutlineInputBorder(),
            prefixIcon:Icon(Icons.lock),
            suffixIcon:IconButton(
              icon: Icon(Icons.remove_red_eye),
              onPressed: () {
                look = !look;
                setState(() {

                });

              },
            ),


          ),
            obscureText: look
            ,
            controller: passw,
            keyboardType: TextInputType.emailAddress,
            onFieldSubmitted: (v){  //onChanged:
              print(v);
            },
          ),
        ),

        Padding(
            padding: EdgeInsets.fromLTRB(80.0, 30.0, 80.0, 30.0), // Adjust margins as needed
            child:MaterialButton(
                padding: EdgeInsets.all(10.0),
                color:Colors.pink,

                child: Text('LOGIN' , style: TextStyle(color: Colors.white,fontSize: 25.0,fontWeight: FontWeight.bold )),
                onPressed:  () async {
                  //await print("");
                  if (passw.text.isNotEmpty && name.text.isNotEmpty  ) {
                    print(passw.text);
                    print(name.text );

                    await _makePostRequest( name.text , passw.text );
                    Map<String, dynamic> jsonData = jsonDecode(_responseData);
                    if (jsonData['loginOK'] == "true"){
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('loginOK', true);
                      await prefs.setString('username', jsonData['username']);
                      await prefs.setString('name', jsonData['name']);
                      await prefs.setString('role', jsonData['role']);
                      await prefs.setString('password', jsonData['password']);
                    }

                    setState(  () {
                      if (jsonData['loginOK'] == "true"){
                        myFunction("login success",5);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage(isLoggedIn: true , role : jsonData['role'] , accName : jsonData['name'] , usernamea : jsonData['username'] , password : jsonData['password'])));



                      }else{
                        myFunction(jsonData['massage'],4);

                      }

                    });

                  }
                  else {
                    setState(() {
                      myFunction("complete the form" ,4);
                    });
                  }


                })
        ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(msg ,style: TextStyle(color: Colors.red,fontSize: 25.0,fontWeight: FontWeight.bold ),),

            ],
          ),



        ],
      )

      ) ,
      ) ,
                    )
        ),
      ),
    );
  }
  void  myFunction(String m , int t) async {
    // Do something before the delay
    msg = m;

    // Wait for 3 seconds
    await Future.delayed(Duration(seconds: t));

    // Do something after the delay
    msg = "";
    setState(() {

    });
  }

}



class MyHomePage extends StatefulWidget {
  final bool isLoggedIn;
  final String role;
  final String accName;
  final String usernamea;
  final String password;

  const MyHomePage({super.key, required this.isLoggedIn , required this.role , required this.accName , required this.usernamea , required this.password });


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
String code ="";





  int _selectedIndex = 0;
  String _responseData="";
  List dataList = [];

  List childList = [];
  @override
  void initState() {
    super.initState();
    if(widget.role=="child"){
    _makePostRequest(widget.usernamea);
    }
    _viewChild( widget.usernamea );// Call the API initially when the widget is created
  }
  void _onItemTapped(int index) {
    setState(() {
      if(widget.role=="child"){
        _makePostRequest(widget.usernamea);
      }
      _viewTransaction(widget.usernamea);
      _viewChild( widget.usernamea );
      _selectedIndex = index;
    });
  }
  void _performLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loginOK');
    await prefs.remove('username');
    await prefs.remove('name');
    await prefs.remove('role');
    await prefs.remove('password');
    Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));

    // Navigate to the login screen
  }

  Future<void> _makePostRequest( String user ) async {
    String url = "http://192.168.1.6:5000/mobileAPIauth"; // Replace with your API URL

    Map<String, dynamic> data = {
      "username": user,

      "action":"ChildMoney",
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: data,
      );

      if (response.statusCode == 200) {
        setState(() {
          Map<String, dynamic> jsonData = jsonDecode(response.body);
          _responseData = jsonData['amount'] as String;
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }

Future<void> _viewChild( String user ) async {
  String url = "http://192.168.1.6:5000/mobileAPIauth"; // Replace with your API URL

  Map<String, dynamic> data = {
    "parent": user,

    "action":"viewChild",
  };

  try {

    final response = await http.post(
      Uri.parse(url),
      body: data,
    );


    if (response.statusCode == 200) {
      setState(() {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        //print(jsonData['data']);
        setState(() {
          childList = jsonData['data'];
        });


      });
    } else {
      print("Error: ${response.statusCode}");

    }
  } catch (error) {
    print("Error: $error");
  }
}




  Future<void> _viewTransaction( String user ) async {
    String url = "http://192.168.1.6:5000/mobileAPIauth"; // Replace with your API URL

    Map<String, dynamic> data = {
      "username": user,

      "action":"viewTransaction",
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: data,
      );

      if (response.statusCode == 200) {
        setState(() {
          Map<String, dynamic> jsonData = jsonDecode(response.body);
           //print(jsonData['data']);
          dataList = jsonData['data'];

        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }




  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          centerTitle: true,
            title: const Text('Campus Coin',style: TextStyle(color: Colors.pink,fontSize: 35.0,fontWeight: FontWeight.bold )),
            automaticallyImplyLeading: false,
            actions: [IconButton(icon: Icon(Icons.logout ), onPressed: (){
              _performLogout();
            }
            )
            ]
        ),
        body: _selectedIndex == 0 ?

        Container(
          color: Colors.teal,
          child: Padding(

            padding: const EdgeInsets.all(20.0),
            child: widget.role == "child" ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color:Colors.white ,

              ),

              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(

                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // Set your desired background color
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(40.0, 80.9, 40.0, 20.0),
                            child: Center(
                              child: RichText(overflow: TextOverflow.ellipsis, text: TextSpan(children:[WidgetSpan(child:Icon(Icons.person, size: 26.0),),TextSpan(text:widget.accName, style: TextStyle(color: Colors.black,fontSize: 26.0,fontWeight: FontWeight.bold )) ,])),

                            ),
                          ),

                          Container(
                            padding: EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 85.0),
                            child: Center(
                              child: RichText(overflow: TextOverflow.ellipsis, text: TextSpan(children:[TextSpan(text:'You Have: $_responseData', style: TextStyle(color: Colors.black,fontSize: 26.0,fontWeight: FontWeight.bold )) ,WidgetSpan(child:Icon(Icons.attach_money_outlined, size: 26.0),),])),
                            ),
                          ),

                        ],
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.fromLTRB(40.0, 20.0, 40.0, 85.0),

                      child: Center(

                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink, // Set button color
                          ),
                          onPressed: () async {
                            String DataCode= "";
                            DataCode = await FlutterBarcodeScanner.scanBarcode(
                                '#ff6666', 'Cancel', true, ScanMode.QR);
                            String decodedString = base64Decode(DataCode);
                             // Output: "Hello, world!"
                            List<String> stringList = decodedString.split("-");
                            await _makePayment(stringList[1] ,widget.usernamea,stringList[0] ,stringList[2] );
                            await  _makePostRequest(widget.usernamea);

                            setState(() {

                            });

                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Sacne' , style: TextStyle(color: Colors.white,fontSize: 25.0,fontWeight: FontWeight.bold )),
                              SizedBox(width: 5.0),
                              Icon(Icons.camera_alt_outlined ,size: 35.0,color: Colors.white,),
                            ],
                          ),
                        ),

                      ),
                    ),
                    Text(code,style: TextStyle(color: Colors.red ,fontSize: 20.0,fontWeight: FontWeight.bold )),
                  ],

                ),
              ),
            ) : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color:Colors.white ,

              ),

              child: Column(

                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(40.0, 80.9, 40.0, 15.0),
                    child: Center(
                      child: Text(widget.accName ,style: TextStyle(color: Colors.black,fontSize: 25.0,fontWeight: FontWeight.bold ),),
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.fromLTRB(40.0, 5.0, 40.0, 5.0),
                    child: Center(
                      child: Text(code ,style: TextStyle(color: Colors.red,fontSize: 20.0,fontWeight: FontWeight.bold ),),
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 20.0),

                    child: Center(

                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink, // Set button color
                        ),
                        onPressed: () async {
                          final userInput = await showThreeInputDialog(
                            context,
                            title: "Enter Child Details:",
                            hintText1: "Name",
                            hintText2: "Email",
                            hintText3: "Password",
                          );
                          print(userInput);
                                                  },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Add Child' , style: TextStyle(color: Colors.white,fontSize: 25.0,fontWeight: FontWeight.bold )),
                            SizedBox(width: 5.0),
                            Icon(Icons.add_circle_outline_outlined , color: Colors.white,),
                          ],
                        ),
                      ),

                    ),

                  ),

                  Container(

                    child: Expanded(

                      child: ListView(

                          children: childList.map((item) => Container(
                              padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200], // Set your desired background color
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Row(

                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(8.0, 5.0, 5.0, 5.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          RichText(overflow: TextOverflow.ellipsis, text: TextSpan(children:[WidgetSpan(child:Icon(Icons.email_outlined, size: 15.0),),TextSpan(text:item[2], style: TextStyle(color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold )) ,])),
                                          RichText(overflow: TextOverflow.ellipsis, text: TextSpan(children:[WidgetSpan(child:Icon(Icons.person, size: 15.0),),TextSpan(text:item[3], style: TextStyle(color: Colors.blueGrey,fontSize: 15.0,fontWeight: FontWeight.bold )) ,])),
                                          RichText(overflow: TextOverflow.ellipsis, text: TextSpan(children:[WidgetSpan(child:Icon(Icons.remove_red_eye, size: 15.0),),TextSpan(text:" pass:"+item[4], style: TextStyle(color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold )) ,])),
                                          RichText(overflow: TextOverflow.ellipsis, text: TextSpan(children:[WidgetSpan(child:Icon(Icons.wallet, size: 15.0),),TextSpan(text:"Value:"+item[5].toString(), style: TextStyle(color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold )) ,WidgetSpan(child:Icon(Icons.attach_money, size: 15.0),),])),



                                        ],
                                                                            ),
                                      )),
                                    Expanded(
                                      child: Column(

                                        children: [

                                          ElevatedButton(

                                            onPressed: ()async{
                                              final userInput = await showFourInputDialog(
                                                context,
                                                title: "Enter Payment details:",
                                                hintText1: "Payment Value",
                                                hintText2: "Card Number",
                                                hintText3: "Expiry Date",
                                                hintText4: "CVV",
                                                  child: item[2],
                                              );
                                            },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text('Pay' , style: TextStyle(color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold )),
                                                SizedBox(width: 5.0),
                                                Icon(Icons.add_card , color: Colors.black,),
                                              ],
                                            ),
                                          ),


                                          ElevatedButton(
                                            onPressed: (){
                                              _viewTransActions( item[2] ,context );
                                            },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [

                                                Text('View ' , style: TextStyle(color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold )),
                                                SizedBox(width: 5.0),
                                                Icon(Icons.person_search , color: Colors.black,),
                                              ],
                                            ),
                                          ),

                                        ],
                                      ),
                                    )


                                  ],
                                ),
                              )

                          ),).toList(),


                      ),
                    ),
                  ),


                ],

              ),
            ),
          ),
        ) : Container(
            color: Colors.teal,
            child:Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(

                  borderRadius: BorderRadius.circular(20.0),
                  color:Colors.white ,

                ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                          child: Center(
                            child: ListView(


                                        children: [Center(child:
                                        RichText(overflow: TextOverflow.ellipsis, text: TextSpan(children:[TextSpan(text:'Transaction', style: TextStyle(color: Colors.black,fontSize: 18.0,fontWeight: FontWeight.bold )) ,])),

                                            ),
                                          Table(
                                            border: TableBorder.all(color: Colors.black), // Add border for clarity (optional)
                                            children: [
                                              // Header row
                                              TableRow(
                                                children: [
                                                  TableCell(child:
                                                  RichText(overflow: TextOverflow.ellipsis, text: TextSpan(children:[WidgetSpan(child:Icon(Icons.email_outlined, size: 15.0),),TextSpan(text:'From', style: TextStyle(color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold )) ,])),

                                                  ),
                                                  TableCell(child:RichText(overflow: TextOverflow.ellipsis, text: TextSpan(children:[WidgetSpan(child:Icon(Icons.email_outlined, size: 15.0),),TextSpan(text:'To', style: TextStyle(color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold )) ,])),),
                                                  TableCell(child:RichText(overflow: TextOverflow.ellipsis, text: TextSpan(children:[WidgetSpan(child:Icon(Icons.credit_card, size: 15.0),),TextSpan(text:'Card Number', style: TextStyle(color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold )) ,])),),
                                                  TableCell(child:RichText(overflow: TextOverflow.ellipsis, text: TextSpan(children:[WidgetSpan(child:Icon(Icons.attach_money_outlined, size: 15.0),),TextSpan(text:'Value', style: TextStyle(color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold )) ,])),),
                                                  TableCell(child:RichText(overflow: TextOverflow.ellipsis, text: TextSpan(children:[WidgetSpan(child:Icon(Icons.access_time_filled_outlined, size: 15.0),),TextSpan(text:'Time', style: TextStyle(color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold )) ,])),),





                                                ],
                                              ),
                                              // Data rows

                                              for (var item in dataList)
                                                TableRow(
                                                  children: [
                                                    TableCell(child:SingleChildScrollView(
                                                      scrollDirection: Axis.horizontal,
                                                      child: Row(
                                                        children: [
                                                          RichText( text: TextSpan(children:[WidgetSpan(child:Icon(Icons.email_outlined, size: 15.0),),TextSpan(text:item[1], style: TextStyle(color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold )) ,])),
                                                        ],
                                                      ),
                                                    ),),                                                    TableCell(child:SingleChildScrollView(
                                                      scrollDirection: Axis.horizontal,
                                                      child: Row(
                                                        children: [
                                                          RichText( text: TextSpan(children:[WidgetSpan(child:Icon(Icons.email_outlined, size: 15.0),),TextSpan(text:item[2], style: TextStyle(color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold )) ,])),
                                                        ],
                                                      ),
                                                    ),),
                                                    TableCell(child:SingleChildScrollView(
                                                      scrollDirection: Axis.horizontal,
                                                      child: Row(
                                                        children: [
                                                          RichText( text: TextSpan(children:[WidgetSpan(child:Icon(Icons.credit_card, size: 15.0),),TextSpan(text:item[3].toString(), style: TextStyle(color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold )) ,])),
                                                        ],
                                                      ),
                                                    ),),
                                                    TableCell(child:SingleChildScrollView(
                                                      scrollDirection: Axis.horizontal,
                                                      child: Row(
                                                        children: [
                                                          RichText( text: TextSpan(children:[TextSpan(text:" "+item[6].toString(), style: TextStyle(color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold )),WidgetSpan(child:Icon(Icons.attach_money_outlined, size: 15.0),) ,])),
                                                        ],
                                                      ),
                                                    ),),


                                                    TableCell(child:SingleChildScrollView(
                                                      scrollDirection: Axis.horizontal,
                                                      child: Row(
                                                        children: [
                                                          RichText( text: TextSpan(children:[WidgetSpan(child:Icon(Icons.access_time, size: 15.0),) ,TextSpan(text:" "+item[8].toString(), style: TextStyle(color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold )),])),
                                                        ],
                                                      ),
                                                    ),),
                                                  ],
                                                ),
                                            ],
                                          ),


                                        ]
                                           ),
                          ),
                        ),
                      ),
            )
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.table_chart_outlined),
              label: 'Transactions',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }


Future<List<String>?> showFourInputDialog(BuildContext context,
    {String title = "", String hintText1 = "", String hintText2 = "", String hintText3 = "", String hintText4 = "" , String child =""}) async {
  final _textController1 = TextEditingController();
  final _textController2 = TextEditingController();
  final _textController3 = TextEditingController();
  final _textController4 = TextEditingController();

  return await showDialog<List<String>>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _textController1,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(hintText: hintText1),
            ),
            SizedBox(height: 10.0), // Add spacing between input fields
            TextField(
              keyboardType: TextInputType.number,
              controller: _textController2,
              decoration: InputDecoration(hintText: hintText2),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _textController3,
              decoration: InputDecoration(hintText: hintText3),
            ),
            SizedBox(height: 10.0),
            TextField(
              keyboardType: TextInputType.number,
              controller: _textController4,
              decoration: InputDecoration(hintText: hintText4),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final text1 = _textController1.text;
              final text2 = _textController2.text;
              final text3 = _textController3.text;
              final text4 = _textController4.text;
              if (text1.isNotEmpty && text2.isNotEmpty && text3.isNotEmpty && text4.isNotEmpty) {



                _TransferPayment( widget.usernamea,child,text1 ,text2,text3,text4);
                setState(() {

                });
                Navigator.pop(context, [text1, text2, text3, text4]);
              }
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

Future<void> _TransferPayment( String parentAccount,String childAccount,String value ,String CardNumber,String ExpiryDate,String CVV) async {
  String url = "http://192.168.1.6:5000/mobileAPIauth"; // Replace with your API URL

  Map<String, dynamic> data = {

    'action':'PAY',
    'parent':parentAccount,
    'childEmail':childAccount,
    'value':value,
    'CardNumber':CardNumber,
    'ExpiryDate':ExpiryDate,
    'CVV':CVV,

  };

  try {
    final response = await http.post(
      Uri.parse(url),
      body: data,
    );

    if (response.statusCode == 200) {
      setState(() {

        code = response.body as String;
        myFunction(code , 3);
        setState(() {

        });

      });
    } else {
      print("Error: ${response.statusCode}");
    }
  } catch (error) {
    print("Error: $error");
  }
}



Future<List<String>?> showThreeInputDialog(BuildContext context,
    {String title = "", String hintText1 = "", String hintText2 = "", String hintText3 = ""}) async {
  final _textController1 = TextEditingController();
  final _textController2 = TextEditingController();
  final _textController3 = TextEditingController();

  return await showDialog<List<String>>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _textController1,
              autofocus: true,
              decoration: InputDecoration(hintText: hintText1),
            ),
            SizedBox(height: 10.0), // Add spacing between input fields
            TextField(
              controller: _textController2,
              decoration: InputDecoration(hintText: hintText2),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _textController3,
              decoration: InputDecoration(hintText: hintText3),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final text1 = _textController1.text;
              final text2 = _textController2.text;
              final text3 = _textController3.text;
              if (text1.isNotEmpty && text2.isNotEmpty && text3.isNotEmpty) {
                _addChild(widget.usernamea, text2,text1 ,text3);
                setState(() {

                });
                Navigator.pop(context, [text1, text2, text3]);

              }
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

Future<void> showListDialog(BuildContext context , List items) async {



  return await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("View Transaction"),
        content: SizedBox(
          height: 300.0, // Set a maximum height for scrollable content
          child: SingleChildScrollView(
            child: Column(
              children: items.map((item) => Container(
                  margin: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color:Colors.white ,

                ),
                padding:EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0) ,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(overflow: TextOverflow.ellipsis, text: TextSpan(children:[WidgetSpan(child:Icon(Icons.email_outlined, size: 15.0),),TextSpan(text:item[1], style: TextStyle(color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold )) ,])),
                    RichText(overflow: TextOverflow.ellipsis, text: TextSpan(children:[WidgetSpan(child:Icon(Icons.mark_email_read_outlined, size: 15.0),),TextSpan(text:item[2], style: TextStyle(color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold )) ,])),
                    RichText(overflow: TextOverflow.ellipsis, text: TextSpan(children:[WidgetSpan(child:Icon(Icons.wallet, size: 15.0),),TextSpan(text:"Value: "+item[6].toString(), style: TextStyle(color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold )) ,WidgetSpan(child:Icon(Icons.attach_money, size: 15.0),),])),
                    RichText(overflow: TextOverflow.ellipsis, text: TextSpan(children:[WidgetSpan(child:Icon(Icons.access_time_rounded, size: 15.0),),TextSpan(text:"Time: "+item[8].toString(), style: TextStyle(color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold )) ,WidgetSpan(child:Icon(Icons.attach_money, size: 15.0),),])),
                  ],
                ),
              )).toList(),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}


String base64Decode(String encodedString) {
  // Decode the base64 string
  final bytes = base64.decode(encodedString);
  // Convert the byte array back to a string using UTF-8 encoding
  return utf8.decode(bytes);
}


Future<void> _makePayment( String mercent,String childEmail,String Value ,String Time ) async {
  String url = "http://192.168.1.6:5000/mobileAPIauth"; // Replace with your API URL

  Map<String, dynamic> data = {

    'mercent':mercent,
    'childEmail':childEmail,
    'value':Value,
    'creationTime':Time,
    "action":"childPay",
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      body: data,
    );

    if (response.statusCode == 200) {
      setState(() {

        code = response.body as String;
        myFunction(code , 3);

      });
    } else {
      print("Error: ${response.statusCode}");
    }
  } catch (error) {
    print("Error: $error");
  }
}



Future<void> _viewTransActions( String childEmail , BuildContext context ) async {
  String url = "http://192.168.1.6:5000/mobileAPIauth"; // Replace with your API URL

  Map<String, dynamic> data = {

    "action":"ViewChaild",

    "childEmail":childEmail

  };

  try {
    final response = await http.post(
      Uri.parse(url),
      body: data,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      //print(jsonData['data']);
      dataList = jsonData['data'];
      showListDialog(context,dataList);
    } else {
      print("Error: ${response.statusCode}");
    }
  } catch (error) {
    print("Error: $error");
  }
}

Future<void> _addChild( String parent,String childEmail,String cname ,String CPassword ) async {
  String url = "http://192.168.1.6:5000/mobileAPIauth"; // Replace with your API URL

  Map<String, dynamic> data = {


    'parent':parent,
    'childEmail':childEmail,
    'childName':cname,
    'childPassword':CPassword,
    "action":"addChild",
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      body: data,
    );

    if (response.statusCode == 200) {
      setState(() {

        code = response.body as String;
        print(code);
        myFunction(code , 4);

      });
    } else {
      print("Error: ${response.statusCode}");
    }
  } catch (error) {
    print("Error: $error");
  }
}


void  myFunction(String m , int t) async {
  // Do something before the delay
  code = m;

  // Wait for 3 seconds
  await Future.delayed(Duration(seconds: t));

  // Do something after the delay
  code = "";
  setState(() {

  });


}

}
