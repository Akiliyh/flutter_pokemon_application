import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

Future<List<Pokemon>> fetchAllPokemonDetails() async {
  final listResponse = await http.get(
    Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=2000'),
  );

  if (listResponse.statusCode != 200) {
    throw Exception('Failed to load pokemon list');
  }

  final data = jsonDecode(listResponse.body);
  final List results = data['results'];

  final pokemons = await Future.wait(
    results.map((item) async {
      final detailResponse = await http.get(Uri.parse(item['url']));
      return Pokemon.fromJson(jsonDecode(detailResponse.body));
    }),
  );

  return pokemons;
}

class Pokemon {
  final int id;
  final String name;
  final String imageUrl;

  const Pokemon({required this.id, required this.name, required this.imageUrl});

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'],
      name: json['name'],
      imageUrl:
          json['sprites']['front_default'] ??
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${json['id']}.png',
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokemon app',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.green),
      ),
      home: const MyHomePage(title: 'Pokemon Application'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController _searchController;
  List<Pokemon> _allPokemons = [];
  List<Pokemon> _filteredPokemons = [];
  late Future<List<Pokemon>> futurePokemons;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    futurePokemons = fetchAllPokemonDetails();

    futurePokemons.then((list) {
    setState(() {
      _allPokemons = list;
      _filteredPokemons = list;
    });
  });

  _searchController.addListener(() {
    filterPokemons();
  });
  
  }

  void filterPokemons() {
  final query = _searchController.text.toLowerCase();
  setState(() {
    _filteredPokemons = _allPokemons.where((pokemon) {
      return pokemon.name.toLowerCase().contains(query);
    }).toList();
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const IconButton(
              icon: Icon(Icons.search),
              tooltip: 'Search',
              onPressed: null,
            ),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter a pokemon here',
              ),
            ),

            Expanded(
              child: FutureBuilder<List<Pokemon>>(
                future: futurePokemons, // cached in initState
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  return ListView.builder(
                    itemCount: _filteredPokemons.length,
                    itemBuilder: (context, index) {
                      return PokeCard(pokemon: _filteredPokemons[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PokeCard extends StatelessWidget {
  final Pokemon pokemon;
  const PokeCard({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56, // in logical pixels
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: Colors.blue[500]),
      child: Row(
        children: [
          Image.network(
            pokemon.imageUrl,
            width: 56,
            height: 56,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.image_not_supported);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const SizedBox(
                width: 56,
                height: 56,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            },
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              pokemon.name,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
