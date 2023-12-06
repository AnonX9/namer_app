import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var history = <WordPair>[];

  GlobalKey? historyListKey;

  void getNext() {
    history.insert(0, current);
    var animatedList = historyListKey?.currentState as AnimatedListState;
    animatedList.insertItem(0);
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (!favorites.contains(current)) {
      favorites.add(current);
    } else {
      favorites.remove(current);
    }
    notifyListeners();
  }

  void toggleHistoryFavorite(WordPair pair) {
    if (!favorites.contains(pair)) {
      favorites.add(pair);
    } else {
      favorites.remove(pair);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    if (favorites.contains(pair)) favorites.remove(pair);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const GeneratorPage();
        break;
      case 1:
        page = const FavoritesPage();
      default:
        throw UnimplementedError(
            "widget do not exist for index $selectedIndex");
    }

    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,
      child: page,
    );

    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth >= 450) {
          return Row(
            children: [
              NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text("home"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text("favorites"),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
              Expanded(child: mainArea)
            ],
          );
        } else {
          return Column(
            children: [
              Expanded(child: mainArea),
              BottomNavigationBar(
                currentIndex: selectedIndex,
                onTap: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: "home",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite),
                    label: "Favorites",
                  ),
                ],
              )
            ],
          );
        }
      }),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);

    if (appState.favorites.isEmpty) {
      return const Center(
        child: Text("No favorites yet."),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text("You have ${appState.favorites.length} favorites : "),
        ),
        Expanded(
          child: GridView(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400, childAspectRatio: 400 / 80),
            children: [
              ...appState.favorites.map(
                (e) => ListTile(
                  leading: IconButton(
                      onPressed: () => appState.removeFavorite(e),
                      icon: Icon(Icons.delete_outline,
                          color: theme.primaryColor)),
                  title: Text(e.asLowerCase),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final pair = appState.current;

    IconData icon = appState.favorites.contains(pair)
        ? Icons.favorite
        : Icons.favorite_border_outlined;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(child: HistoryListView()),
          const SizedBox(height: 25),
          BigCard(pair: pair),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () => appState.toggleFavorite(),
                icon: Icon(icon),
                label: const Text("Like"),
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                onPressed: () => appState.getNext(),
                child: const Text("Next"),
              ),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final style = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary);

    return Card(
      color: theme.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 400),
          child: MergeSemantics(
            child: Wrap(
              children: [
                Text(
                  pair.first,
                  style: style.copyWith(fontWeight: FontWeight.w200),
                ),
                Text(
                  pair.second,
                  style: style.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HistoryListView extends StatefulWidget {
  const HistoryListView({super.key});

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  final _key = GlobalKey();

  static const Gradient _maskingGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.transparent, Colors.red],
      stops: [0.0, 0.5]);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.historyListKey = _key;

    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        initialItemCount: appState.history.length,
        itemBuilder: (context, index, animation) {
          final pair = appState.history[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: TextButton.icon(
                onPressed: () => appState.toggleHistoryFavorite(pair),
                icon: Icon(
                  appState.favorites.contains(pair) ? Icons.favorite : null,
                ),
                label: Text(pair.asLowerCase),
              ),
            ),
          );
        },
      ),
    );
  }
}
