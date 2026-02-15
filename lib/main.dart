import 'package:flutter/material.dart';
import 'widgets/pokeCard.dart';
import 'pages/detailsPage.dart';
import 'pages/homePage.dart';
import 'api/pokemonAPI.dart';

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

  bool get showDetailPage => _showDetailPage;
  bool _showDetailPage = false;
  set showDetailPage(bool value) {
    if (_showDetailPage == value) {
      return;
    }
    _showDetailPage = value;
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
        child: MyHomePage(title: 'home', 
        allPokemonsCallback: (list) {
            allPokemons = list;
            notifyListeners();
          },),
      ),
      if (showDetailPage)
        MaterialPage<void>(
          key: const ValueKey<String>('details'),
          child: DetailsPage(title: 'details',
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
        assert(page.key == const ValueKey<String>('details'));
        showDetailPage = false;
      },
    );
  }
}
