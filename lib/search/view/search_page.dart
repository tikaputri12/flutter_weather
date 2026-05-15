import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage._();

  static Route<String> route() {
    return MaterialPageRoute(builder: (_) => const SearchPage._());
  }

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _textController = TextEditingController();

  String get _text => _textController.text;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('City Search')),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: _textController,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  final city = value.trim();

                  if (city.isEmpty) return;

                  Navigator.of(context).pop(city);
                },
                decoration: InputDecoration(
                  labelText: 'City',
                  hintText: 'Chicago',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _textController.clear();
                    },
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            key: const Key('searchPage_search_iconButton'),
            icon: const Icon(Icons.search, semanticLabel: 'Submit'),
            onPressed: () {
              final city = _textController.text.trim();

              if (city.isEmpty) return;

              Navigator.of(context).pop(city);
            },
          ),
        ],
      ),
    );
  }
}
