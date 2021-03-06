import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum Position { goalkeeper, defense, midfield, forward }

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

  @override
  String toString() {
    return playersPerPosition[Position.defense].toString() +
        '-' +
        playersPerPosition[Position.midfield].toString() +
        '-' +
        playersPerPosition[Position.forward].toString();
  }
}

class Player {
  final String name;
  final List<Position> positions;

  Player(this.name, this.positions);
}

class LineUpModel extends ChangeNotifier {
  final players = UnmodifiableListView([
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
  ]);

  final _selectedPlayers = Map<Position, List<Player>>();
  var _formation;

  LineUpModel(this._formation) {
    for (var position in _formation.playersPerPosition.keys) {
      _selectedPlayers[position] = List<Player>.filled(
          _formation.playersPerPosition[position], null,
          growable: true);
    }

    // debug
    //_selectedPlayers[Position.midfield][3] = players[10];
  }

  Formation get formation => _formation;
  set formation(Formation value) {
    _formation = value;
    updateSelectedPlayers();
    notifyListeners();
  }

  void updateSelectedPlayers() {
    for (var position in _formation.playersPerPosition.keys) {
      var newPlayers = List<Player>.filled(
          _formation.playersPerPosition[position], null,
          growable: true);
      for (int i = 0;
          i < newPlayers.length && i < _selectedPlayers[position].length;
          i++) {
        newPlayers[i] = _selectedPlayers[position][i];
      }

      _selectedPlayers[position].clear();
      _selectedPlayers[position].addAll(newPlayers);
    }
  }

  UnmodifiableMapView<Position, UnmodifiableListView<Player>>
      get selectedPlayers => UnmodifiableMapView(_selectedPlayers
          .map((key, value) => MapEntry(key, UnmodifiableListView(value))));

  void onPlayerSelected(Position position, int number, Player player) {
    _selectedPlayers.forEach((position, players) {
      for (var i = 0; i < players.length; i++) {
        if (players[i] == player) {
          players[i] = null;
        }
      }
    });
    _selectedPlayers[position][number] = player;
    notifyListeners();
  }
}

void main() {
  runApp(AmaffApp());
}

class AmaffApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final formations = [
      Formation(4, 3, 3),
      Formation(3, 4, 3),
      Formation(3, 5, 2),
      Formation(4, 5, 1)
    ];

    return MaterialApp(
        title: 'AMAFF',
        debugShowCheckedModeBanner: false,
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
        home: ChangeNotifierProvider(
          create: (context) => LineUpModel(formations.first),
          child: Scaffold(
              appBar: AppBar(title: Text('AMAFF'), actions: [
                Consumer<LineUpModel>(builder: (context, lineUp, child) {
                  return DropdownButton<Formation>(
                    icon: Icon(Icons.dialpad, color: Colors.white),
                    iconSize: 32,
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                    value: lineUp.formation,
                    items: formations
                        .map((f) => DropdownMenuItem(
                            value: f,
                            child: Text(f.toString(),
                                style: TextStyle(color: Colors.black))))
                        .toList(),
                    onChanged: (f) => lineUp.formation = f,
                  );
                })
              ]),
              body: LineUp()),
        ));
  }
}

class LineUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LineUpModel>(builder: (context, lineUp, child) {
      return Column(
          children: lineUp.selectedPlayers.keys
              .map((position) => PositionPlayerSelections(position))
              .toList());
    });
  }
}

class PositionPlayerSelections extends StatelessWidget {
  final Position _position;

  PositionPlayerSelections(this._position);

  @override
  Widget build(BuildContext context) {
    return Consumer<LineUpModel>(builder: (context, lineUp, child) {
      final children =
          List<Expanded>.filled(lineUp.selectedPlayers[_position].length, null);
      for (var i = 0; i < children.length; i++)
        children[i] = Expanded(
          flex: 1,
          child: PlayerSelection(_position, i),
        );

      return Row(
          children: children, crossAxisAlignment: CrossAxisAlignment.start);
    });
  }
}

class PlayerSelection extends StatelessWidget {
  final Position _position;
  final int _number;

  PlayerSelection(this._position, this._number);

  @override
  Widget build(BuildContext context) {
    return Consumer<LineUpModel>(builder: (context, lineUp, child) {
      final selectedPlayer = lineUp.selectedPlayers[_position][_number];
      final text = selectedPlayer?.name ??
          _position.toString()[9].toUpperCase() +
              _position.toString().substring(10);

      return Column(children: [
        PopupMenuButton<Player>(
            onSelected: (Player player) =>
                lineUp.onPlayerSelected(_position, _number, player),
            icon: Icon(
              Icons.circle,
              color: selectedPlayer != null
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).disabledColor,
            ),
            itemBuilder: (BuildContext context) => lineUp.players
                .where((player) => player.positions.contains(_position))
                .map((player) => PopupMenuItem<Player>(
                    value: player, child: Text(player.name)))
                .toList()),
        Text(
          text,
          textAlign: TextAlign.center,
        )
      ]);
    });
  }
}
