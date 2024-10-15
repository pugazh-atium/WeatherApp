import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class NewsProvider with ChangeNotifier {
  List<dynamic> _newsHeadlines = [];

  List<dynamic> get newsHeadlines => _newsHeadlines;

  Future<void> fetchNews(String weatherCondition) async {
    const apiKey = '574ffaf87f6542c6bd9a3a3e75b22866';
    String category = '';

    final prefs = await SharedPreferences.getInstance();

    // Filter news based on weather
    if (weatherCondition == "Cold" || prefs.getString('news') == "Depressing news headlines.") {
      category = "sad";
    } else if (weatherCondition == "Hot" || prefs.getString('news') == "News articles related to fear.") {
      category = "fear";
    } else {
      category = "happiness&winning";
    }

    final url = 'https://newsapi.org/v2/everything?q=$category&apiKey=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      _newsHeadlines = data['articles'];
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}
