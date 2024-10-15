import 'package:aetram/screens/setting.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:aetram/helpers/weather.dart';
import 'package:aetram/helpers/news.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = false;
  bool _selected = false;
  bool isCelsius = true;
  String _newsCategory = "";

  @override
  void initState() {
    super.initState();
    _loadWeatherAndNews();
  }

  Future<void> _loadWeatherAndNews() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loading = false;
      isCelsius = prefs.getBool('isCelsius') ?? true;
      _newsCategory = prefs.getString('news') ?? "";
    });
    Position position = await _determinePosition();
    if (mounted) {
      await Provider.of<WeatherProvider>(context, listen: false).fetchWeather(position.latitude, position.longitude);
    }

    if (mounted) {
      final weatherCondition = Provider.of<WeatherProvider>(context, listen: false).weatherCondition;
      await Provider.of<NewsProvider>(context, listen: false).fetchNews(weatherCondition);
    }
    setState(() {
      loading = true;
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  String truncateText(String input, int maxLength) {
    if (input.length <= maxLength) {
      return input;
    } else {
      return '${input.substring(0, maxLength)}...';
    }
  }

  double convertCelsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final newsProvider = Provider.of<NewsProvider>(context);
    double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
        child: Scaffold(
          backgroundColor: _selected ? Colors.grey : Colors.blue.shade50,
          appBar: AppBar(
            leading: IconButton(
              color: Colors.white,
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Switch(
                  activeColor: Colors.white,
                  inactiveThumbColor: Colors.white,
                  activeTrackColor: Colors.white,
                  thumbColor: WidgetStateProperty.all(Colors.orange),
                  thumbIcon: WidgetStateProperty.all(_selected ? const Icon(Icons.nights_stay) : const Icon(Icons.sunny)),
                  value: _selected,
                  onChanged: (value) {
                    setState(() {
                      _selected = value;
                    });
                  },
                ),
              ),
            ],
            title: const Center(child: Text('Weather & News' , style: TextStyle(color:Colors.white))),
              backgroundColor: _selected ? Colors.black38 : Colors.blue,
          ),
          body: (weatherProvider.temperature == 0.0 || !loading)
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              Container(
                  margin: const EdgeInsets.all(5),
                  height: 90,
                  width: screenWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 2.0,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                    image: DecorationImage(
                      image: const AssetImage("assets/images/clouds.jpg"),
                      colorFilter: _selected ? const ColorFilter.linearToSrgbGamma() : const ColorFilter.srgbToLinearGamma(),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${isCelsius ? "${weatherProvider.temperature.toStringAsFixed(1)}°C" : "${convertCelsiusToFahrenheit(weatherProvider.temperature).toStringAsFixed(1)}°F"} - ${weatherProvider.weatherCondition}' , style: const TextStyle(fontWeight: FontWeight.w600 , fontSize: 15)),
                            const Text('Current Weather' , style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 10)),
                          ],
                        ),
                      ),
                      Icon(_selected ? Icons.nights_stay : Icons.sunny,
                        size: 50,
                        color: _selected ? Colors.black : Colors.orange,
                      ),
                  ])
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("News related to ${_newsCategory != "" ? _newsCategory : "Happiness"}",
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: newsProvider.newsHeadlines.length,
                  itemBuilder: (ctx, i) => SizedBox(
                    width: screenWidth,
                    height: 120,
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white,
                        child: Wrap(
                          alignment: WrapAlignment.spaceEvenly,
                          children: [
                            CircleAvatar(
                              radius: 25.0,
                              backgroundColor: Colors.white,
                              backgroundImage: (newsProvider.newsHeadlines[i] != null && newsProvider.newsHeadlines[i]["urlToImage"] != null)
                                ? NetworkImage(newsProvider.newsHeadlines[i]["urlToImage"])
                                : const AssetImage("assets/images/author.jpg"),
                              child: const Align(alignment: Alignment.bottomRight)
                            ) ,
                            Text(truncateText(newsProvider.newsHeadlines[i]["author"] ?? "Author" , 10) , style: const TextStyle(fontSize: 10))
                          ],
                        ),
                      ),
                      title: Text(truncateText(newsProvider.newsHeadlines[i]["title"] ?? "" , 60) , style: const TextStyle(color: Colors.blue)),
                      subtitle: Text(truncateText(newsProvider.newsHeadlines[i]["description"] ?? "" , 100)),
                      onTap: () {
                        final url = newsProvider.newsHeadlines[i]['url'];
                        if (url != null) {
                          launchUrl(Uri.parse(url));
                        }
                      },
                    ),
                  )
                ),
              ),
            ],
          ),
        )
    );
  }
}
