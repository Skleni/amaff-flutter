import 'package:flutter/material.dart';

typedef PlayerChanged = void Function(
    Position position, int index, Player player);

void main() {
  runApp(MyApp());
}

// Package Provider -> wrappen in Consumer<AppState>

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AMAFF',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primaryColor: Colors.green,
      ),
      home: Scaffold(appBar: AppBar(title: Text('AMAFF')), body: LineUp()),
    );
  }
}

class Formation {
  final Map<Position, int> playersPerPosition;

  Formation(int defense, int midfield, int forward)
      : assert(defense + midfield + forward == 10),
        playersPerPosition = Map<Position, int>() {
    playersPerPosition[Position.goalkeeper] = 1;
    playersPerPosition[Position.defense] = defense;
    playersPerPosition[Position.midfield] = midfield;
    playersPerPosition[Position.forward] = forward;
  }
}

enum Position { goalkeeper, defense, midfield, forward }

class Player {
  final String name;
  final List<Position> positions;

  Player(this.name, this.positions);
}

class LineUp extends StatefulWidget {
  @override
  _LineUpState createState() => _LineUpState();
}

class _LineUpState extends State<LineUp> {
  final _players = [
    Player('Manuel Neuer', [Position.goalkeeper]),
    Player('Thibaut Courtois', [Position.goalkeeper]),
    Player('Alisson', [Position.goalkeeper]),
    Player('Sergio Ramos', [Position.defense]),
    Player('Andrew Robertson', [Position.defense]),
    Player('Virgil van Dijk', [Position.defense]),
    Player('David Alaba', [Position.defense, Position.midfield]),
    Player('Kevin De Bruyne', [Position.midfield]),
    Player('Thiago', [Position.midfield]),
    Player('Lionel Messi', [Position.midfield, Position.forward]),
    Player('Marko Arnautovic', [Position.midfield, Position.forward]),
    Player('Robert Lewandowski', [Position.forward]),
    Player('Erling Haaland', [Position.forward]),
  ];

  final _formation = Formation(3, 5, 2);

  var _selectedPlayers = Map<Position, List<Player>>();

  _LineUpState() {
    initializeSelectedPlayers();
  }

  initializeSelectedPlayers() {
    _selectedPlayers.clear();
    for (var position in _formation.playersPerPosition.keys) {
      _selectedPlayers[position] =
          List.filled(_formation.playersPerPosition[position], null);
    }
  }

  void onPlayerSelected(Position position, int number, Player player) {
    setState(() {
      _selectedPlayers.forEach((position, players) {
        for (var i = 0; i < players.length; i++) {
          if (players[i] == player) {
            players[i] = null;
          }
        }
      });
      _selectedPlayers[position][number] = player;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: _formation.playersPerPosition.keys
            .map((position) => PositionPlayerSelections(
                _selectedPlayers, position, _players, onPlayerSelected))
            .toList());
  }
}

class PositionPlayerSelections extends StatelessWidget {
  final Map<Position, List<Player>> _selectedPlayers;
  final Position _position;
  final List<Player> _players;
  final PlayerChanged onPlayerSelected;

  PositionPlayerSelections(this._selectedPlayers, this._position, this._players,
      this.onPlayerSelected);

  @override
  Widget build(BuildContext context) {
    final children =
        List<PlayerSelection>.filled(_selectedPlayers[_position].length, null);
    for (var i = 0; i < children.length; i++)
      children[i] = PlayerSelection(
          _position,
          _players,
          this._selectedPlayers[_position][i],
          (player) => onPlayerSelected(_position, i, player));
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: children);
  }
}

class PlayerSelection extends StatelessWidget {
  final Position _position;
  final List<Player> _players;
  final Player _selectedPlayer;

  final ValueChanged<Player> onPlayerSelected;

  PlayerSelection(this._position, this._players, this._selectedPlayer,
      this.onPlayerSelected);

  @override
  Widget build(BuildContext context) {
    final text = _selectedPlayer?.name ??
        _position.toString()[9].toUpperCase() +
            _position.toString().substring(10);

    return Column(children: [
      PopupMenuButton<Player>(
          onSelected: (Player player) => onPlayerSelected(player),
          icon: Icon(
            Icons.circle,
            color: _selectedPlayer != null
                ? Theme.of(context).primaryColor
                : Theme.of(context).disabledColor,
          ),
          itemBuilder: (BuildContext context) => _players
              .where((player) => player.positions.contains(_position))
              .map((player) => PopupMenuItem<Player>(
                  value: player, child: Text(player.name)))
              .toList()),
      Text(text)
    ]);
  }
}
