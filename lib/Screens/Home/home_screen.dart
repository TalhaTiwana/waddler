import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';
import 'package:waddler/Common/common_functions.dart';
import 'package:waddler/Screens/Auth/login_screen.dart';
import 'package:waddler/Style/colors.dart';
import 'package:weather/weather.dart';
import 'package:geolocator/geolocator.dart';

import '../../SignIn.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String key = '1c75f13d1c68230fd69b0ca692ed1ac1';
  WeatherFactory ws;
  List<Weather> _data = [];



  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
Position _geolocator;
  String name;
  Position position;
  Temperature temperature;
  Weather weather;
  bool searchIsVisible;
   TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    searchIsVisible = false;
    _determinePosition().then((value) {
      _geolocator = value;
    });

    ws = new WeatherFactory(key);
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((
        value) {
      position = value;
    }).whenComplete(() async {
       weather = await ws.currentWeatherByLocation(
          position.latitude, position.longitude);
       _data = await ws.fiveDayForecastByLocation(  position.latitude, position.longitude);
     weather.areaName;
      temperature  =  weather.temperature;
      print(weather.country);
      setState(() {});
    });

    super.initState();

    List<Weather> forecasts;
    List<Weather> data;


    List<dynamic> days = [
      "10.00",
      "11.15",
      "02.20",
      "05.05",
      "06.50"
    ];
  }

  searchWeather({String text})async{
    setState(() {
      weather = null;
    });
    weather =await ws.currentWeatherByCityName("$text");
    _data = await ws.fiveDayForecastByCityName("$text");
    setState(() {});
  }

  BuildContext _context;
  Size size;

    @override
    Widget build(BuildContext context) {
      setState(() {
        _context = context;
      });
       size = MediaQuery
          .of(context)
          .size;
      return SafeArea(child: Scaffold(

          appBar: AppBar(leading: IconButton(
            tooltip: 'Logout',
            icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black,),
            onPressed: () {
              _showDialog(size,_context);
            },),
            backgroundColor: primaryClr.withOpacity(0.8),
            actions: [


              Visibility(
                visible: searchIsVisible,
                child: Container(margin: EdgeInsets.only(top: size.height*0.02,right: size.width*0.04),
                  width: size.width*0.7,
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
border: InputBorder.none,
                      prefixIcon: Icon(Icons.search),
                      hintText: "Search by city or country"
                    ),
                  ),
                ),
              ),

              Container(
                margin: EdgeInsets.only(right: size.width*0.04,top: size.height*0.03),
                child:searchIsVisible?InkWell(
                  onTap: (){
                    searchWeather(text: _controller.text);
                  },
                  child: Container(
                    width: size.width*0.1,
                    height: size.height*0.01,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: primaryDarkClr,
                    ),
                    child: Icon(Icons.arrow_right_alt_sharp,color: Colors.white,),
                  ),
                ): InkWell(
                onTap: (){
                  setState(() {
                    searchIsVisible =!searchIsVisible;
                  });
                },
                    child: Icon(Icons.search,color: Colors.black,)),
              )
            ], elevation: 0,
          ),

          body: Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: const FractionalOffset(0.0, 0.0),
                    end: const FractionalOffset(2.0, 2.0),
                    colors: [
                      primaryClr.withOpacity(0.8),
                      primaryClr.withOpacity(0.5)
                    ]
                )
            ),
            child: weather==null?Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ):SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(children: [
                    Container(
                      margin: EdgeInsets.only(top: size.height * 0.04),
                      child: Text("${weather.areaName}\n${weather.country}", style: GoogleFonts.varela(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: size.width * 0.05
                      ),textAlign: TextAlign.center,),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: size.height * 0.01),
                      child: Text("${weather.weatherDescription}", style: GoogleFonts.cabin(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: size.width * 0.04
                      ),textAlign: TextAlign.center,),
                    ),

                    Container(
                      margin: EdgeInsets.only(top: size.height * 0.02),
                      width: size.width * 0.5,

                      child: Image.asset("images/sunwithcloud.png"),
                    ),
                    Container(
                      alignment: Alignment.center,

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: size.height * 0.01),
                            child: Text("${temperature.celsius.toString().split('.').first} C", style: GoogleFonts.cabin(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: size.width * 0.07
                            ),),
                          ), Container(
                            margin: EdgeInsets.only(top: size.height * 0.015,
                                left: size.width * 0.01),
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border(
                                    bottom: BorderSide(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                    top: BorderSide(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                    right: BorderSide(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                    left: BorderSide(
                                      color: Colors.black,
                                      width: 2,
                                    )
                                )
                            ),
                          )
                        ],),
                    ),
                  ],),

                  /// Today
                  Column(children: [
                    Container(
                      margin: EdgeInsets.only(
                          left: size.width * 0.04, bottom: size.height * 0.03),
                      width: size.width,
                      child: Text("Today", style: GoogleFonts.cabin(
                          color: Colors.black,
                          fontSize: size.width * 0.05,
                          fontWeight: FontWeight.w800),),
                    ),

                    Container(
                        width: size.width,
                        height: size.height * 0.22,
                        child:ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            /// Max Temp
                            Container(
                              height: size.height * 0.1,
                              width: size.width * 0.22,
                              margin: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.03),
                              decoration: BoxDecoration(
                                  color:Colors.white ,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey[400].withOpacity(
                                            0.6),
                                        blurRadius: 3,
                                        spreadRadius: 1,
                                        offset: Offset(2, 0)
                                    ),
                                    BoxShadow(
                                        color: Colors.grey[400].withOpacity(
                                            0.6),
                                        blurRadius: 3,
                                        spreadRadius: 1,
                                        offset: Offset(-2, 2)
                                    )
                                  ]
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceAround,
                                children: [
                                  Container(
                                    child: Text("MAX Temp",
                                      style: GoogleFonts.cabin(
                                        fontWeight: FontWeight.w800,),),
                                    margin: EdgeInsets.only(
                                        top: size.height * 0.02),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: AssetImage(
                                                "images/sun.png"),
                                            colorFilter: ColorFilter
                                                .srgbToLinearGamma()
                                        )
                                    ),
                                    width: size.width * 0.14,
                                    height: size.height * 0.08,
                                  ),

                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        child: Text("${weather.tempMax.celsius.toString().split('.').first} C", style: GoogleFonts.cabin(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                            fontSize: size.width * 0.04
                                        ),),
                                      ), Container(
                                        margin: EdgeInsets.only(
                                            left: size.width * 0.01),
                                        width: 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.black,
                                                  width: 2,
                                                ),
                                                top: BorderSide(
                                                  color: Colors.black,
                                                  width: 2,
                                                ),
                                                right: BorderSide(
                                                  color: Colors.black,
                                                  width: 2,
                                                ),
                                                left: BorderSide(
                                                  color: Colors.black,
                                                  width: 2,
                                                )
                                            )
                                        ),
                                      )
                                    ],),
                                  Text("${weather.weatherDescription}", style: GoogleFonts.cabin(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: size.width * 0.04
                                  ),
                                  textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: size.height * 0.02,
                                  ),
                                ],
                              ),
                            ),

                            /// Max Temp
                            Container(
                              height: size.height * 0.1,
                              width: size.width * 0.22,
                              margin: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.03),
                              decoration: BoxDecoration(
                                  color:Colors.white ,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey[400].withOpacity(
                                            0.6),
                                        blurRadius: 3,
                                        spreadRadius: 1,
                                        offset: Offset(2, 0)
                                    ),
                                    BoxShadow(
                                        color: Colors.grey[400].withOpacity(
                                            0.6),
                                        blurRadius: 3,
                                        spreadRadius: 1,
                                        offset: Offset(-2, 2)
                                    )
                                  ]
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceAround,
                                children: [
                                  Container(
                                    child: Text("Sunset",
                                      style: GoogleFonts.cabin(
                                        fontWeight: FontWeight.w800,),),
                                    margin: EdgeInsets.only(
                                        top: size.height * 0.02),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: AssetImage(
                                                "images/sun.png"),
                                            colorFilter: ColorFilter
                                                .srgbToLinearGamma()
                                        )
                                    ),
                                    width: size.width * 0.14,
                                    height: size.height * 0.08,
                                  ),

                                  Text("Time:${weather.sunset.hour}:00", style: GoogleFonts.cabin(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: size.width * 0.035
                                  ),),
                                  Text("${weather.weatherDescription}", style: GoogleFonts.cabin(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: size.width * 0.04
                                  ),   textAlign: TextAlign.center,),
                                  SizedBox(
                                    height: size.height * 0.02,
                                  ),
                                ],
                              ),
                            ),


                            /// Min Temp
                            Container(
                              height: size.height * 0.1,
                              width: size.width * 0.22,
                              margin: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.03),
                              decoration: BoxDecoration(
                                  color:primaryClr.withOpacity(0.9) ,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey[400].withOpacity(
                                            0.6),
                                        blurRadius: 3,
                                        spreadRadius: 1,
                                        offset: Offset(2, 0)
                                    ),
                                    BoxShadow(
                                        color: Colors.grey[400].withOpacity(
                                            0.6),
                                        blurRadius: 3,
                                        spreadRadius: 1,
                                        offset: Offset(-2, 2)
                                    )
                                  ]
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceAround,
                                children: [
                                  Container(
                                    child: Text("MIN Temp",
                                      style: GoogleFonts.cabin(
                                        fontWeight: FontWeight.w800,),),
                                    margin: EdgeInsets.only(
                                        top: size.height * 0.02),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: AssetImage(
                                                "images/sunwithcloud2.png"),
                                            colorFilter: ColorFilter
                                                .srgbToLinearGamma()
                                        )
                                    ),
                                    width: size.width * 0.14,
                                    height: size.height * 0.08,
                                  ),

                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        child: Text("${weather.tempMin.toString().split('.').first} C", style: GoogleFonts.cabin(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                            fontSize: size.width * 0.04
                                        ),),
                                      ), Container(
                                        margin: EdgeInsets.only(
                                            left: size.width * 0.01),
                                        width: 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.black,
                                                  width: 2,
                                                ),
                                                top: BorderSide(
                                                  color: Colors.black,
                                                  width: 2,
                                                ),
                                                right: BorderSide(
                                                  color: Colors.black,
                                                  width: 2,
                                                ),
                                                left: BorderSide(
                                                  color: Colors.black,
                                                  width: 2,
                                                )
                                            )
                                        ),
                                      )
                                    ],),
                                  Text("${weather.weatherDescription}", style: GoogleFonts.cabin(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: size.width * 0.04
                                  ),   textAlign: TextAlign.center,),
                                  SizedBox(
                                    height: size.height * 0.02,
                                  ),
                                ],
                              ),
                            ),

                            /// Wind Speed
                            Container(
                              height: size.height * 0.1,
                              width: size.width * 0.22,
                              margin: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.03),
                              decoration: BoxDecoration(
                                  color:primaryClr.withOpacity(0.9) ,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey[400].withOpacity(
                                            0.6),
                                        blurRadius: 3,
                                        spreadRadius: 1,
                                        offset: Offset(2, 0)
                                    ),
                                    BoxShadow(
                                        color: Colors.grey[400].withOpacity(
                                            0.6),
                                        blurRadius: 3,
                                        spreadRadius: 1,
                                        offset: Offset(-2, 2)
                                    )
                                  ]
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceAround,
                                children: [
                                  Container(
                                    child: Text("Wind Speed",
                                      style: GoogleFonts.cabin(
                                        fontWeight: FontWeight.w800,),),
                                    margin: EdgeInsets.only(
                                        top: size.height * 0.02),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: AssetImage(
                                                "images/wind.png"),
                                            colorFilter: ColorFilter
                                                .srgbToLinearGamma()
                                        )
                                    ),
                                    width: size.width * 0.12,
                                    height: size.height * 0.08,
                                  ),

                                  Text("${weather.windSpeed} mph", style: GoogleFonts.cabin(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: size.width * 0.04
                                  ),),
                                  Text("${weather.weatherDescription}", style: GoogleFonts.cabin(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: size.width * 0.04
                                  ),   textAlign: TextAlign.center,),
                                  SizedBox(
                                    height: size.height * 0.02,
                                  ),
                                ],
                              ),
                            )
                          ],
                        )
                    )
                  ],),


                  /// Tomorrow
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: size.width * 0.05,
                            bottom: size.height * 0.01,
                            top: size.height * 0.02),
                        width: size.width,
                        child: Text("Tomorrow", style: GoogleFonts.cabin(
                            color: Colors.black,
                            fontSize: size.width * 0.05,
                            fontWeight: FontWeight.w800),),
                      ),
                      _data!=null?Container(
                        height: size.height * 0.1,
                        width: size.width,
                        margin: EdgeInsets.only(left: size.width * 0.04,
                            right: size.width * 0.04,
                            bottom: size.height * 0.03),
                        decoration: BoxDecoration(
                            color: primaryClr,
                            borderRadius: BorderRadius.circular(25)
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text("${_data[1].weatherDescription}", style: TextStyle(color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: size.width * 0.04),)

                            , Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          "images/sunwithcloud2.png"),
                                      colorFilter: ColorFilter
                                          .srgbToLinearGamma()
                                  )
                              ),
                              width: size.width * 0.13,
                              height: size.height * 0.06,
                            )

                            , Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: size.height * 0.01),
                                    child: Text("${_data[0].tempMax}", style: GoogleFonts.cabin(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: size.width * 0.05
                                    ),),
                                  ), Container(
                                    margin: EdgeInsets.only(
                                        top: size.height * 0.01),
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border(
                                            bottom: BorderSide(
                                              color: Colors.black,
                                              width: 2,
                                            ),
                                            top: BorderSide(
                                              color: Colors.black,
                                              width: 2,
                                            ),
                                            right: BorderSide(
                                              color: Colors.black,
                                              width: 2,
                                            ),
                                            left: BorderSide(
                                              color: Colors.black,
                                              width: 2,
                                            )
                                        )
                                    ),
                                  )
                                ],),
                            ),
                          ],
                        ),
                      ):Container()
                    ],
                  )
                ],
              ),
            ),
          )
      ),
      );
    }


  _showDialog(Size size, BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text("Are you sure to logout?"),
        actions: [
          MaterialButton(
            onPressed: () {
              FirebaseAuth.instance.signOut().whenComplete(() {
                Toast.show("Successfully logout", context,
                    gravity: 1,
                    duration: 1,
                    textColor: Colors.black,
                    backgroundColor: primaryClr);
              });
              Navigator.pop(context);
              screenPushRep(context, LoginScreen());
            },
            child: Text("Yes"),
          ),
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("No"),
          )
        ],
      ),
    );
  }
  }