import 'package:flutter/material.dart';

const double NavHeight = 52;
const double NavElevation = 0.5;
const double HorizontalPadding = 15;
const double VerticalPadding = 10;

const FColorBlue = 0xFF0062FF;
const FColorWhite = 0xFFFFFFFF;
const FColorRed = 0xFFF5222D;
const FColorBackground = 0xFFF7F7F7;

const FTips0 = 0xFF000000;
const FTips1 = 0xFF333333;
const FTips2 = 0xFF999999;
const FTips3 = 0xFFd8d8d8;

const WLevel1 = 0xFFF5222D;
const WLevel2 = 0xFFFF7A45;
const WLevel3 = 0xFFEDDB4D;
const WLevel4 = 0xFF389E0D;

const TitleStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Color(FTips1));

const SubTitleStyle = TextStyle(fontSize: 15);

const FootTextStyle = TextStyle(fontSize: 12);

const BodyTextStyle = TextStyle(fontSize: 14, color: Color(FTips1));

const NavTitleStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(FTips1));

const ListLabelStyle = TextStyle(fontSize: 16, color: Color(FTips1));

const BlueBtnShadow = BoxShadow(
  blurRadius: 9,
  color: Color.fromRGBO(0, 98, 255, 0.3),
  spreadRadius: 1,
);

const BlueBtnTextStyle = TextStyle(fontSize: 15, color: Colors.white);

const TipTextStyle = TextStyle(fontSize: 14, color: Color(FTips2));

const NavLeadingAlign = Alignment(-0.5, 0);

const PagePadding = EdgeInsets.symmetric(horizontal: HorizontalPadding, vertical: VerticalPadding);

const WalletShadows = <BoxShadow>[
  BoxShadow(
    color: Color.fromRGBO(6, 47, 240, 0.2),
    blurRadius: 12,
    spreadRadius: 4,
  ),
  BoxShadow(
    color: Color.fromRGBO(6, 47, 240, 0.2),
    blurRadius: 12,
    spreadRadius: 4,
  )
];

const WalletGradients = <LinearGradient>[
  LinearGradient(
    begin: const Alignment(-1.6, 0.0),
    end: const Alignment(1.0, 0.0),
    colors: <Color>[
      const Color(0xff2b98ff),
      const Color(0xff0062ff)
    ],
  ),
  LinearGradient(
    begin: const Alignment(-1.6, 0.0),
    end: const Alignment(1.0, 0.0),
    colors: <Color>[
      const Color(0xff6c6c6c),
      const Color(0xff5e5e5e),
      const Color(0xff4f4f4f),
      const Color(0xff121212),
    ],
  ),
];

