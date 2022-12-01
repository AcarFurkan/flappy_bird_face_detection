part of 'game_board_cubit.dart';

@immutable
abstract class GameBoardState {}

class GameBoardInitial extends GameBoardState {}

class GameBoardCompleted extends GameBoardState {}
