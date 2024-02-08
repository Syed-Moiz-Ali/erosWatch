// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchDropDown extends StatefulWidget {
  final Function fetch;

  const SearchDropDown({Key? key, required this.fetch}) : super(key: key);

  @override
  State<SearchDropDown> createState() => _DropDownState();
}

class _DropDownState extends State<SearchDropDown> {
  void _showBottomSheet(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    late String date = prefs.getString('selectedDate') ?? 'all';
    late String quality = prefs.getString('selectedQuality') ?? 'all';
    late String duration = prefs.getString('selectedDuration') ?? 'all';
    List<Map<String, String>> dateItems = [
      {'value': 'all', 'title': 'All'},
      {'value': 'd', 'title': 'Day'},
      {'value': 'w', 'title': 'Week'},
      {'value': 'm', 'title': 'Month'},
      {'value': 'y', 'title': 'Year'},
    ];

    List<Map<String, String>> durationItems = [
      {'value': 'all', 'title': 'All'},
      {'value': '10', 'title': '10 mins'},
      {'value': '20', 'title': '20 mins'},
      {'value': '40', 'title': '40 mins'},
    ];

    List<Map<String, String>> qualityItems = [
      {'value': 'all', 'title': 'All'},
      {'value': 'hd', 'title': 'HD'},
      {'value': 'fhd', 'title': 'Full HD'},
      {'value': 'uhd', 'title': 'Ultra HD'},
    ];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDropdown('Date', date, dateItems, (newValue) {
                    setState(() {
                      date = newValue!;
                    });
                  }),
                  _buildDropdown('Duration', duration, durationItems,
                      (newValue) {
                    setState(() {
                      duration = newValue!;
                    });
                  }),
                  _buildDropdown('Quality', quality, qualityItems, (newValue) {
                    setState(() {
                      quality = newValue!;
                    });
                  }),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await prefs.setString('selectedDate', date);
                      await prefs.setString('selectedDuration', duration);
                      await prefs.setString('selectedQuality', quality);
                      await widget.fetch();
                      Navigator.pop(context);
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDropdown(String label, String value,
      List<Map<String, String>> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            items: items
                .map<DropdownMenuItem<String>>(
                  (Map<String, String> item) => DropdownMenuItem<String>(
                    value: item['value']!,
                    child: Text(item['title']!),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 60,
        left: 10,
      ),
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
      child: FloatingActionButton(
        // heroTag: 'float',
        heroTag: UniqueKey(),
        onPressed: () {
          _showBottomSheet(context);
        },
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.filter_list_rounded,
          color: Colors.white,
        ),
      ),
    );
  }
}
