import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  var switcher1 = false;

  var switcher2 = false;

  var switcher3 = false;

  var switcher4 = false;

  Widget _buildSettingSwitchListTile(
    bool newValue,
    String title,
    String subtitle,
    Function toggler,
  ) {
    return SwitchListTile(
      value: newValue,
      onChanged: toggler,
      title: Text(
        title,
        style: TextStyle(color: Colors.black87),
      ),
      subtitle: Text(subtitle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Text(
              "Adjust the app to fit your style",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildSettingSwitchListTile(
                  switcher1,
                  "Setting 1",
                  "It does so and so",
                  null,
                ),
                _buildSettingSwitchListTile(
                  switcher2,
                  "Setting 2",
                  "It does so and so",
                  null,
                ),
                _buildSettingSwitchListTile(
                  switcher3,
                  "Setting 3",
                  "It does so and so",
                  null,
                ),
                _buildSettingSwitchListTile(
                  switcher4,
                  "Setting 4",
                  "It does so and so",
                  null,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
