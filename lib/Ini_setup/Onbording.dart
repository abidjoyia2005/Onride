import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/Ini_setup/Login_Screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  PageController pageController = PageController();
  final List<String> _titlesList = [
    'Add Address',
    'Choose Your Favorite Food',
    'Fastest Delivery',
  ];

  final List<String> _subtitlesList = [
    'Find perfect restaurant nearby or place order at your favorite restaurant in few clicks.',
    'A diverse list of different dining restaurants throughout the territory and around your area carefully selected',
    'Get your favorite food fastest delivered at your doorstep',
  ];

  final List<String> _imageList = [
    'assets/images/intro_1.png',
    'assets/images/intro_2.png',
    'assets/images/intro_3.png',
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = this.isDarkMode(context);
    final imageList = _imageList;

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0XFF151618) : Colors.white,
      body: Stack(
        children: <Widget>[
          PageView.builder(
            itemCount: imageList.length,
            controller: pageController,
            itemBuilder: (context, index) => getPage(
              imageList[index],
              _titlesList[index],
              _subtitlesList[index],
              context,
              (index + 1) == imageList.length,
            ),
            onPageChanged: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          if (_currentIndex + 1 == _imageList.length)
            Positioned(
              right: 13,
              bottom: 17,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.94,
                height: MediaQuery.of(context).size.height * 0.08,
                padding: EdgeInsets.all(10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    "GET STARTED",
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    setFinishedOnBoarding();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                ),
              ),
            ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 130),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SmoothPageIndicator(
                  controller: pageController,
                  count: _imageList.length,
                  effect: ScrollingDotsEffect(
                    spacing: 20,
                    activeDotColor: Colors.green,
                    dotColor: Color(0XFFFBDBD1),
                    dotWidth: 7,
                    dotHeight: 7,
                  ),
                ),
              ),
            ),
          ),
          if (_currentIndex + 1 != _imageList.length)
            Positioned(
              right: 20,
              top: 40,
              child: InkWell(
                onTap: () {
                  setFinishedOnBoarding();
                  // pushReplacement(context, AuthScreen());
                },
                child: Text(
                  "SKIP",
                  style: TextStyle(
                    fontSize: 19,
                    color: Colors.blue,
                    fontFamily: 'Poppinsm',
                  ),
                ),
              ),
            ),
          if (_currentIndex + 1 != _imageList.length)
            Positioned(
              right: 13,
              bottom: 17,
              child: InkWell(
                onTap: () {
                  pageController.nextPage(
                    duration: Duration(milliseconds: 100),
                    curve: Curves.bounceIn,
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.94,
                  height: MediaQuery.of(context).size.height * 0.08,
                  padding: EdgeInsets.all(10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                    child: Text(
                      "NEXT",
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            isDarkMode ? Color(0xffFFFFFF) : Color(0XFF333333),
                      ),
                    ),
                    onPressed: () {
                      pageController.nextPage(
                        duration: Duration(milliseconds: 100),
                        curve: Curves.bounceIn,
                      );
                    },
                  ),
                ),
              ),
            ),
          if (_currentIndex + 1 == _imageList.length)
            Positioned(
              left: 15,
              top: 30,
              child: GestureDetector(
                onTap: () {
                  pageController.previousPage(
                    duration: Duration(milliseconds: 100),
                    curve: Curves.bounceIn,
                  );
                },
                child: Icon(
                  Icons.chevron_left,
                  size: 40,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget getPage(String image, String title, String subtitle,
      BuildContext context, bool isLastPage) {
    final isDarkMode = this.isDarkMode(context);

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: isDarkMode ? Color(0XFF242528) : Color(0XFFFCEEE9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.elliptical(400, 180),
                  bottomRight: Radius.elliptical(400, 180),
                ),
              ),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(image),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.08),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Color(0XFF333333),
              fontFamily: 'Poppinsm',
              fontSize: 20,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 30),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Color(0XFF333333),
                fontFamily: 'Poppinsl',
                height: 2,
                letterSpacing: 1.2,
                fontSize: 15,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        ],
      ),
    );
  }

  Future<void> setFinishedOnBoarding() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("FINISHED_ON_BOARDING", true);
  }

  bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}
