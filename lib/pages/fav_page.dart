import 'package:flutter/material.dart';
import '../widgets/poke_card.dart';
import '../main.dart';
import '../api/pokemon_api.dart';

class FavPage extends StatefulWidget {
  final String title;
  final List<Pokemon> favPokemons; // only favorited ones
  final ValueChanged<List<Pokemon>> allPokemonsCallback;
  final List<Pokemon> allPokemons;

  const FavPage({super.key, required this.title, required this.allPokemonsCallback, required this.allPokemons, required this.favPokemons});

  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  List<Pokemon> _allPokemons = [];
  late Future<List<Pokemon>> futurePokemons;
  late List<Pokemon> _favPokemons;

  MyRouterDelegate get router => MyRouterDelegate.of(context);

  @override
  void initState() {
    super.initState();
    _allPokemons = widget.allPokemons;
    _favPokemons = widget.favPokemons;
  }

  void toggleLikeCurPokemon(int id) {
    setState(() {
      // we update the value of isFavorited pokemons
      _allPokemons = _allPokemons.map((pokemon) {
        if (pokemon.id == id) {
          return Pokemon(
            id: pokemon.id,
            name: pokemon.name,
            imageUrl: pokemon.imageUrl,
            isFavorited: !pokemon.isFavorited,
          );
        }
        return pokemon;
      }).toList();

      _favPokemons = _allPokemons.where((pokemon) => pokemon.isFavorited).toList();

      widget.allPokemonsCallback(_allPokemons);
      router.allPokemons = _allPokemons;
    });
  }

  final RouterDelegate<Object> delegate = MyRouterDelegate();

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.amber, title: Text(widget.title)),
      body: _favPokemons.isEmpty
          ? const Center(child: Text("No favorites yet!"))
          : ListView.builder(
              itemCount: _favPokemons.length,
              itemBuilder: (context, index) {
                final pokemon = _favPokemons[index];
                return PokeCard(
                  pokemon: pokemon,
                  onLikeToggle: () {
                    toggleLikeCurPokemon(pokemon.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Unfavorited " + pokemon.name)),
                    );
                  },
                );
              },
            ),
    );
  }
}