import 'package:flutter/material.dart';
import 'pages/fav_page.dart';
import 'pages/home_page.dart';
import 'api/pokemon_api.dart';

void main() {
  runApp(const PokemonApp());
}

class PokemonApp extends StatefulWidget {
  const PokemonApp({super.key});

  @override
  State<PokemonApp> createState() => _PokemonAppState();
}

class _PokemonAppState extends State<PokemonApp> {
  final RouterDelegate<Object> delegate = MyRouterDelegate();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pokemon app',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.green)),
      routerDelegate: delegate,
    );
  }
}

class MyRouterDelegate extends RouterDelegate<Object>
    with PopNavigatorRouterDelegateMixin<Object>, ChangeNotifier {

  @override
  Future<void> setNewRoutePath(Object configuration) async =>
      throw UnimplementedError();

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static MyRouterDelegate of(BuildContext context) =>
      Router.of(context).routerDelegate as MyRouterDelegate;

  bool get showFavPage => _showFavPage;
  bool _showFavPage = false;
  set showFavPage(bool value) {
    if (_showFavPage == value) {
      return;
    }
    _showFavPage = value;
    notifyListeners();
  }

  List<Pokemon> allPokemons = [];

  void setPokemons(List<Pokemon> list) {
    allPokemons = list;
    notifyListeners();
  }

  List<Page<Object?>> _getPages() {
    return <Page<Object?>>[
      MaterialPage<void>(
        key: ValueKey<String>('home'),
        child: MyHomePage(title: 'Home', 
        allPokemonsCallback: (list) {
            allPokemons = list;
            notifyListeners();
          },),
      ),
      if (showFavPage)
        MaterialPage<void>(
          key: const ValueKey<String>('favorites'),
          child: FavPage(title: 'Favorite pokemons',
          allPokemonsCallback: (list) {
            allPokemons = list;
            notifyListeners();
          },
          allPokemons: allPokemons,
          favPokemons: allPokemons.where((p) => p.isFavorited).toList(),), // we display only the favorited pokemons
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: _getPages(),
      onDidRemovePage: (Page<Object?> page) {
        assert(page.key == const ValueKey<String>('favorites'));
        showFavPage = false;
      },
    );
  }
}
