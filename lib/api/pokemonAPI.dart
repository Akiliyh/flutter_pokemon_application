import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  final bool isFavorited;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.isFavorited,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'],
      name: json['name'],
      imageUrl:
          json['sprites']['front_default'] ??
          "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/" +
              json['id'].toString() +
              ".png",
      isFavorited: false,
    );
  }
}