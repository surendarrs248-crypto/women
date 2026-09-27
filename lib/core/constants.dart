// SAKHI constants: palette, Bengaluru seeds, and demo route.
// Faithful to the HTML prototype's :root vars and seed data.
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class C {
  // Night street palette.
  static const night = Color(0xFF0E0B16);
  static const night2 = Color(0xFF141021);
  static const sheetBg = Color(0xFF161126);
  static const toastBg = Color(0xFF1D1730);
  static const ink = Color(0xFFF4EFFA);
  static const muted = Color(0xFF9C93B3);
  static const faint = Color(0xFF655C7E);
  static const rose = Color(0xFFFF3D6E);
  static const roseDeep = Color(0xFFD91E4F);
  static const amber = Color(0xFFFFB84D);
  static const guard = Color(0xFF5EE6A8);
  static const violet = Color(0xFF8B6CFF);
  static Color get panel => Colors.white.withValues(alpha: .045);
  static Color get panel2 => Colors.white.withValues(alpha: .075);
  static Color get line => Colors.white.withValues(alpha: .10);
  static const r = 18.0;
  static const rSm = 12.0;
}

const kMono = TextStyle(
  fontFamily: 'monospace',
  fontFamilyFallback: ['Courier'],
);

// Bengaluru center.
final blr = LatLng(12.9757, 77.6011);

// Demo route: MG Road to Trinity to Indiranagar.
final routeAnchors = <LatLng>[
  LatLng(12.9757, 77.6011),
  LatLng(12.9750, 77.6060),
  LatLng(12.9737, 77.6112),
  LatLng(12.9722, 77.6169),
  LatLng(12.9733, 77.6229),
  LatLng(12.9748, 77.6297),
  LatLng(12.9762, 77.6353),
  LatLng(12.9784, 77.6408),
];

class DestOption {
  final String label;
  final LatLng point;

  const DestOption(this.label, this.point);
}

final destOptions = <DestOption>[
  DestOption('Home · Indiranagar', LatLng(12.9784, 77.6408)),
  DestOption('PG · Koramangala', LatLng(12.9352, 77.6245)),
  DestOption('MG Road Metro', LatLng(12.9757, 77.6011)),
];

// Crowdsourced heat seeds: latitude, longitude, weight.
final seedHeat = <List<double>>[
  [12.9757, 77.6011, .6],
  [12.9698, 77.5991, .9],
  [12.9611, 77.5847, .7],
  [12.9352, 77.6245, .5],
  [12.9271, 77.6191, .8],
  [12.9784, 77.6408, .4],
  [12.9906, 77.5709, .85],
  [12.9490, 77.6420, .6],
  [13.0027, 77.6094, .7],
];

class HelpSpot {
  final String name;
  final LatLng point;
  final String type;

  const HelpSpot(this.name, this.point, this.type);
}

final helpSpots = <HelpSpot>[
  HelpSpot('Cubbon Park Police Stn', LatLng(12.9763, 77.5929), 'Police'),
  HelpSpot('Indiranagar Police Stn', LatLng(12.9719, 77.6412), 'Police'),
  HelpSpot('Koramangala Police Stn', LatLng(12.9349, 77.6198), 'Police'),
  HelpSpot(
    'Manipal Hospital, Old Airport Rd',
    LatLng(12.9592, 77.6483),
    'Hospital',
  ),
  HelpSpot("St. John's Medical", LatLng(12.9299, 77.6198), 'Hospital'),
];

class Helpline {
  final String number;
  final String label;
  final String emoji;

  const Helpline(this.number, this.label, this.emoji);
}

const helplines = <Helpline>[
  Helpline('112', '112 Police', '🚨'),
  Helpline('1091', '1091 Women', '👮‍♀️'),
  Helpline('181', '181 Support', '🛟'),
  Helpline('108', '108 Medical', '🚑'),
];