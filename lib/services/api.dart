import 'package:flutter/material.dart';



class API {
  final BuildContext context;
  String pageText='';
  Map<String, String> query = {
    'user': '',
    'status': '',
    'created_at__gte': '',
    'created_at__lte': ''
  };

  API({required this.context});

  String getToday(DateTime today) {
    DateTime yesterday = today.subtract(Duration(days: 1));
    String todayYear = yesterday.year.toString();
    String todayMonth = yesterday.month.toString().padLeft(2, '0');
    String todayDay = yesterday.day.toString().padLeft(2, '0');
    String queryToday = "$todayYear-$todayMonth-$todayDay";

    return queryToday;
  }

  String getTomorrow(DateTime today) {
    DateTime tomorrow = DateTime(today.year, today.month, today.day + 1);
    String tomorrowYear = tomorrow.year.toString();
    String tomorrowMonth = tomorrow.month.toString().padLeft(2, '0');
    String tomorrowDay = tomorrow.day.toString().padLeft(2, '0');
    String queryTomorrow = "$tomorrowYear-$tomorrowMonth-$tomorrowDay";

    return queryTomorrow;
  }

  void setShowOption(int opt) {
    if (opt == 1) {
      pageText = "Στον χάρτη παρουσιάζονται όλα τα δοχεία συλλογής";
      query['user'] = '';
      query['status'] = '';
      query['created_at__gte'] = '';
      query['created_at__lte'] = '';
    }
    if (opt == 2) {
      pageText = "Στον χάρτη παρουσιάζονται όλα τα σημερινά δοχεία συλλογής";
      DateTime today = DateTime.now();
      String queryToday = getToday(today);
      String queryTomorrow = getTomorrow(today);
      query['user'] = '';
      query['status'] = '';
      query['created_at__gte'] = queryToday;
      query['created_at__lte'] = queryTomorrow;
    }
    if (opt == 3) {
      pageText = "Στον χάρτη παρουσιάζονται όλα τα σημερινά, μη συλλεχθέντα δοχεία συλλογής";
      DateTime today = DateTime.now();
      String queryToday = getToday(today);
      String queryTomorrow = getTomorrow(today); 
      query['user'] = '';
      query['status'] = 'False';
      query['created_at__gte'] = queryToday;
      query['created_at__lte'] = queryTomorrow;
    }
    
  }
}