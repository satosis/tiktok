import 'package:flutter/material.dart';

class Canvas extends StatelessWidget {
  Canvas({
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x00000000),
      body: Stack(
        children: <Widget>[
          // Adobe XD layer: 'Background' (shape)
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/bg-signup.jpg'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(25.0, 200.0),
            child:
                // Adobe XD layer: 'Layer 35' (shape)
                Container(
              width: 343.0,
              height: 404.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(''),
                  fit: BoxFit.fill,
                  colorFilter: new ColorFilter.mode(
                      Colors.black.withOpacity(0.1), BlendMode.dstIn),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(496.0, 1225.0),
            child:
                // Adobe XD layer: 'Layer 35 copy 4' (shape)
                Container(
              width: 304.0,
              height: 358.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(''),
                  fit: BoxFit.fill,
                  colorFilter: new ColorFilter.mode(
                      Colors.black.withOpacity(0.1), BlendMode.dstIn),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(-77.0, 966.0),
            child:
                // Adobe XD layer: 'Layer 35 copy 3' (shape)
                Container(
              width: 278.0,
              height: 327.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(''),
                  fit: BoxFit.fill,
                  colorFilter: new ColorFilter.mode(
                      Colors.black.withOpacity(0.11), BlendMode.dstIn),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(-34.0, -144.0),
            child:
                // Adobe XD layer: 'Layer 35 copy 2' (shape)
                Container(
              width: 343.0,
              height: 404.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(''),
                  fit: BoxFit.fill,
                  colorFilter: new ColorFilter.mode(
                      Colors.black.withOpacity(0.11), BlendMode.dstIn),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(-43.0, -153.0),
            child:
                // Adobe XD layer: 'Layer 35 copy 5' (shape)
                Container(
              width: 370.0,
              height: 436.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(''),
                  fit: BoxFit.fill,
                  colorFilter: new ColorFilter.mode(
                      Colors.black.withOpacity(0.11), BlendMode.dstIn),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(26.0, 218.0),
            child:
                // Adobe XD layer: 'Layer 45' (shape)
                Container(
              width: 741.0,
              height: 651.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(''),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(26.0, 809.0),
            child:
                // Adobe XD layer: 'Layer 46' (shape)
                Container(
              width: 741.0,
              height: 338.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(''),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(346.0, 795.0),
            child:
                // Adobe XD layer: 'Layer 53' (shape)
                Container(
              width: 1.0,
              height: 74.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(''),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(347.0, 795.0),
            child:
                // Adobe XD layer: 'Layer 53 copy' (shape)
                Container(
              width: 1.0,
              height: 74.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(''),
                  fit: BoxFit.fill,
                  colorFilter: new ColorFilter.mode(
                      Colors.black.withOpacity(0.22), BlendMode.dstIn),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(-59.0, 987.0),
            child:
                // Adobe XD layer: 'Layer 35 copy' (shape)
                Container(
              width: 242.0,
              height: 285.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(''),
                  fit: BoxFit.fill,
                  colorFilter: new ColorFilter.mode(
                      Colors.black.withOpacity(0.11), BlendMode.dstIn),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(668.0, 273.0),
            child:
                // Adobe XD layer: 'Layer 35 copy 6' (shape)
                Container(
              width: 155.0,
              height: 183.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(''),
                  fit: BoxFit.fill,
                  colorFilter: new ColorFilter.mode(
                      Colors.black.withOpacity(0.11), BlendMode.dstIn),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(678.0, 285.0),
            child:
                // Adobe XD layer: 'Layer 35 copy 6' (shape)
                Container(
              width: 135.0,
              height: 159.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(''),
                  fit: BoxFit.fill,
                  colorFilter: new ColorFilter.mode(
                      Colors.black.withOpacity(0.11), BlendMode.dstIn),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(62.0, 543.0),
            child:
                // Adobe XD layer: 'Layer 25 copy' (shape)
                Container(
              width: 669.0,
              height: 82.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(''),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(62.0, 1252.0),
            child:
                // Adobe XD layer: 'Layer 25 copy 2' (shape)
                Container(
              width: 669.0,
              height: 82.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(''),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(95.0, 1375.0),
            child:
                // Adobe XD layer: 'Layer 32' (shape)
                Container(
              width: 634.0,
              height: 1.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(''),
                  fit: BoxFit.fill,
                  colorFilter: new ColorFilter.mode(
                      Colors.black.withOpacity(0.22), BlendMode.dstIn),
                ),
              ),
            ),
          ),
          // Adobe XD layer: 'Layer 24' (shape)
          Container(
            width: 0.0,
            height: 0.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage(''),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(132.0, 229.94),
            child: Text(
              'CREATE AN ACCOUNT',
              style: TextStyle(
                fontFamily: 'QueenofCamelot2.0',
                fontSize: 57.511661529541016,
                color: const Color(0xff06638f),
                letterSpacing: 1.1502332305908203,
                height: 2.5660397482491932,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Transform.translate(
            offset: Offset(296.0, 47.94),
            child: Text(
              'SIGN UP',
              style: TextStyle(
                fontFamily: 'QueenofCamelot2.0',
                fontSize: 57.511661529541016,
                color: const Color(0xffffffff),
                letterSpacing: 1.1502332305908203,
                height: 2.5660397482491932,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Transform.translate(
            offset: Offset(264.0, 504.4),
            child: Text(
              'USE PHONE OR EMAIL',
              style: TextStyle(
                fontFamily: 'Rockwell',
                fontSize: 25,
                color: const Color(0xffffffff),
                height: 4.105663452148438,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Transform.translate(
            offset: Offset(96.0, 408.6),
            child: SizedBox(
              width: 612.0,
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontFamily: 'Rockwell',
                    fontSize: 30,
                    color: const Color(0xff000000),
                    height: 1.3333333333333333,
                  ),
                  children: [
                    TextSpan(
                      text: 'Create a profile, follow other accounts,\n',
                    ),
                    TextSpan(
                      text: 'make your own video, and more.',
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Adobe XD layer: 'Layer 36' (shape)
          Container(
            width: 800.0,
            height: 67.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage(''),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(25.0, 4.6),
            child: SizedBox(
              width: 72.0,
              child: Text(
                '8:10',
                style: TextStyle(
                  fontFamily: 'Roboto-Regular',
                  fontSize: 30,
                  color: const Color(0xffffffff),
                  height: 1.3333333333333333,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(689.0, 11.0),
            child:
                // Adobe XD layer: 'Layer 21' (shape)
                Container(
              width: 35.0,
              height: 32.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(''),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(746.0, 24.0),
            child:
                // Adobe XD layer: 'Layer 22' (shape)
                Container(
              width: 35.0,
              height: 17.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(''),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(22.0, 993.0),
            child:
                // Adobe XD layer: 'Layer 48' (shape)
                Container(
              width: 746.0,
              height: 458.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(''),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(62.0, 1294.0),
            child:
                // Adobe XD layer: 'Layer 25 copy 3' (shape)
                Container(
              width: 669.0,
              height: 82.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(''),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(347.0, 1260.4),
            child: Text(
              'Login',
              style: TextStyle(
                fontFamily: 'Rockwell',
                fontSize: 35,
                color: const Color(0xffffffff),
                letterSpacing: 1.75,
                height: 2.932616751534598,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Transform.translate(
            offset: Offset(271.5, 1182.66),
            child: SizedBox(
              width: 258.0,
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontFamily: 'Rockwell',
                    fontSize: 19.999990463256836,
                    color: const Color(0xff000000),
                    height: 2.951713634354417,
                  ),
                  children: [
                    TextSpan(
                      text: 'Already',
                    ),
                    TextSpan(
                      text: ' have an account',
                      style: TextStyle(
                        color: const Color(0xff06638f),
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(114.0, 390.0),
            child:
                // Adobe XD layer: 'Layer 54 copy' (shape)
                Container(
              width: 562.0,
              height: 1.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(''),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(258.0, 800.0),
            child:
                // Adobe XD layer: 'Layer 33' (shape)
                Container(
              width: 64.0,
              height: 64.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(''),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(282.0, 816.0),
            child:
                // Adobe XD layer: 'Layer 57' (shape)
                Container(
              width: 16.0,
              height: 30.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(''),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(375.0, 800.0),
            child:
                // Adobe XD layer: 'Layer 31' (shape)
                Container(
              width: 64.0,
              height: 64.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(''),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(394.0, 818.0),
            child:
                // Adobe XD layer: 'Layer 56' (shape)
                Container(
              width: 26.0,
              height: 27.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(''),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(471.0, 795.0),
            child:
                // Adobe XD layer: 'Layer 53 copy 2' (shape)
                Container(
              width: 1.0,
              height: 74.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(''),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(472.0, 795.0),
            child:
                // Adobe XD layer: 'Layer 53 copy 2' (shape)
                Container(
              width: 1.0,
              height: 74.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(''),
                  fit: BoxFit.fill,
                  colorFilter: new ColorFilter.mode(
                      Colors.black.withOpacity(0.22), BlendMode.dstIn),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(500.0, 800.0),
            child:
                // Adobe XD layer: 'Layer 55' (shape)
                Container(
              width: 59.0,
              height: 59.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(''),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(295.5, 699.37),
            child: SizedBox(
              width: 216.0,
              child: Text(
                'Continue With',
                style: TextStyle(
                  fontFamily: 'Rockwell',
                  fontSize: 28.40291976928711,
                  color: const Color(0xff000000),
                  height: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(391.5, 634.96),
            child: SizedBox(
              width: 36.0,
              child: Text(
                'OR',
                style: TextStyle(
                  fontFamily: 'Rockwell',
                  fontSize: 19.996810913085938,
                  color: const Color(0xff000000),
                  height: 2.8407449460553935,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
