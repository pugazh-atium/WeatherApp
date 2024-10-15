import 'package:aetram/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isCelsius = true;
  String _newsCategory = "";

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isCelsius = prefs.getBool('isCelsius') ?? true;
      _newsCategory = prefs.getString('news') ?? "";
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isCelsius', isCelsius);
    prefs.setString('news', _newsCategory);
  }

  void _handleGenderChange(String? value) {
    setState(() {
      _newsCategory = value ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Settings' , style: TextStyle(color: Colors.white)),
        backgroundColor:  Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          },
        ),
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Temperature Unit'),
            subtitle: Text(isCelsius ? 'Celsius' : 'Fahrenheit'),
            value: isCelsius,
            onChanged: (val) {
              setState(() {
                isCelsius = val;
              });
            },
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(10, 15, 10, 00),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('News categories : '),
                Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: [
                          Radio<String>(
                            value: "News articles related to fear.",
                            activeColor: Colors.black,
                            groupValue: _newsCategory,
                            onChanged: _handleGenderChange,
                          ),
                          const Text("News articles related to fear.",style: TextStyle(color: Colors.black)),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: "Winning & happiness.",
                            activeColor: Colors.black,
                            groupValue: _newsCategory,
                            onChanged: _handleGenderChange,
                          ),
                          const Text("Winning & happiness." , style: TextStyle(color: Colors.black)),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: "Depressing news headlines.",
                            activeColor: Colors.black,
                            groupValue: _newsCategory,
                            onChanged: _handleGenderChange,
                          ),
                          const Text("Depressing news headlines." ,style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                _savePreferences();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Updated !!!'),
                    backgroundColor: Colors.green.withOpacity(0.8),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text(
                'Update',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    )
    );
  }
}
