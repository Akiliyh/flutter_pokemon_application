import 'package:flutter/material.dart';
import '../api/pokemonAPI.dart';
import '../widgets/pokeCard.dart';
import '../main.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.allPokemonsCallback,
  });

  final String title;
  final ValueChanged<List<Pokemon>> allPokemonsCallback;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController _searchController;
  List<Pokemon> _allPokemons = [];
  List<Pokemon> _filteredPokemons = [];
  late Future<List<Pokemon>> futurePokemons;
  MyRouterDelegate get router => MyRouterDelegate.of(context);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    futurePokemons = fetchAllPokemonDetails();

    futurePokemons.then((list) {
      setState(() {
        _allPokemons = list;
        router.allPokemons = list;
        _filteredPokemons = list;
        widget.allPokemonsCallback(_allPokemons);
      });
    });

    _searchController.addListener(() {
      filterPokemons();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    router.addListener(_onRouterChanged);
  }

  void _onRouterChanged() {
    if (!mounted) return;

    setState(() {
      filterPokemons(); // refresh list from router
    });
  }

  void filterPokemons() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPokemons = router.allPokemons.where((pokemon) {
        return pokemon.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void toggleLikeCurPokemon(int id) {
    setState(() {
      // we update the value of isFavorited pokemons
      _allPokemons = router.allPokemons.map((pokemon) {
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

      _filteredPokemons = _filteredPokemons.map((pokemon) {
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

      widget.allPokemonsCallback(_allPokemons);
    });
  }

  final RouterDelegate<Object> delegate = MyRouterDelegate();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.amber, title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            TextButton(
              onPressed: () {
                MyRouterDelegate.of(context).showFavPage = true;
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('See your favorite pokemons'),
                  SizedBox(width: 8),
                  Icon(Icons.favorite),
                ],
              ),
            ),
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
                      final pokemon = _filteredPokemons[index];
                      return PokeCard(
                        pokemon: pokemon,
                        onLikeToggle: () {
                          toggleLikeCurPokemon(pokemon.id);
                        },
                      );
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
