import 'package:signalr_netcore/signalr_client.dart';
import 'dart:async';

/// SignalR Service for real-time match updates
class SignalRService {
  static const String hubUrl = 'http://192.168.1.2:8080/matchHub';
  
  HubConnection? _hubConnection;
  bool _isConnected = false;

  /// Stream controllers for match updates
  final _scoreUpdateController = StreamController<ScoreUpdate>.broadcast();
  final _statusUpdateController = StreamController<StatusUpdate>.broadcast();

  Stream<ScoreUpdate> get scoreUpdates => _scoreUpdateController.stream;
  Stream<StatusUpdate> get statusUpdates => _statusUpdateController.stream;

  bool get isConnected => _isConnected;

  /// Initialize SignalR connection
  Future<void> connect() async {
    if (_hubConnection != null && _isConnected) {
      print('SignalR: Already connected');
      return;
    }

    try {
      // Configure hub connection
      _hubConnection = HubConnectionBuilder()
          .withUrl(hubUrl)
          .withAutomaticReconnect()
          .build();

      // Listen for ScoreUpdated events
      _hubConnection!.on('ScoreUpdated', (arguments) => _handleScoreUpdate(arguments));

      // Listen for MatchStatusUpdated events
      _hubConnection!.on('MatchStatusUpdated', (arguments) => _handleStatusUpdate(arguments));

      // Connection state handlers
      _hubConnection!.onclose(({error}) {
        print('SignalR: Connection closed: $error');
        _isConnected = false;
      });

      _hubConnection!.onreconnecting(({error}) {
        print('SignalR: Reconnecting... $error');
        _isConnected = false;
      });

      _hubConnection!.onreconnected(({connectionId}) {
        print('SignalR: Reconnected with ID: $connectionId');
        _isConnected = true;
      });

      // Start connection
      await _hubConnection!.start();
      _isConnected = true;
      print('SignalR: Connected successfully');
    } catch (e) {
      print('SignalR: Connection error: $e');
      _isConnected = false;
      rethrow;
    }
  }

  /// Join a match group to receive updates for specific match
  Future<void> joinMatchGroup(String matchId) async {
    if (!_isConnected || _hubConnection == null) {
      print('SignalR: Not connected, connecting...');
      await connect();
    }

    try {
      await _hubConnection!.invoke('JoinMatchGroup', args: [matchId]);
      print('SignalR: Joined match group $matchId');
    } catch (e) {
      print('SignalR: Error joining match group: $e');
      rethrow;
    }
  }

  /// Leave a match group
  Future<void> leaveMatchGroup(String matchId) async {
    if (!_isConnected || _hubConnection == null) {
      return;
    }

    try {
      await _hubConnection!.invoke('LeaveMatchGroup', args: [matchId]);
      print('SignalR: Left match group $matchId');
    } catch (e) {
      print('SignalR: Error leaving match group: $e');
    }
  }

  /// Handle score update from SignalR
  void _handleScoreUpdate(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final data = arguments[0] as Map<String, dynamic>;
      final update = ScoreUpdate(
        matchId: data['matchId'].toString(),
        teamA: data['teamA'] as String,
        teamB: data['teamB'] as String,
        scoreA: data['scoreA'] as int,
        scoreB: data['scoreB'] as int,
        timestamp: DateTime.parse(data['timestamp'] as String),
      );

      _scoreUpdateController.add(update);
      print('SignalR: Score update received for match ${update.matchId}');
    } catch (e) {
      print('SignalR: Error parsing score update: $e');
    }
  }

  /// Handle match status update from SignalR
  void _handleStatusUpdate(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final data = arguments[0] as Map<String, dynamic>;
      final update = StatusUpdate(
        matchId: data['matchId'].toString(),
        status: data['status'] as String,
        timestamp: DateTime.parse(data['timestamp'] as String),
      );

      _statusUpdateController.add(update);
      print('SignalR: Status update received for match ${update.matchId}');
    } catch (e) {
      print('SignalR: Error parsing status update: $e');
    }
  }

  /// Disconnect from SignalR
  Future<void> disconnect() async {
    try {
      await _hubConnection?.stop();
      _isConnected = false;
      print('SignalR: Disconnected');
    } catch (e) {
      print('SignalR: Error disconnecting: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _scoreUpdateController.close();
    _statusUpdateController.close();
  }
}

/// Score update model from SignalR
class ScoreUpdate {
  final String matchId;
  final String teamA;
  final String teamB;
  final int scoreA;
  final int scoreB;
  final DateTime timestamp;

  ScoreUpdate({
    required this.matchId,
    required this.teamA,
    required this.teamB,
    required this.scoreA,
    required this.scoreB,
    required this.timestamp,
  });
}

/// Match status update model from SignalR
class StatusUpdate {
  final String matchId;
  final String status;
  final DateTime timestamp;

  StatusUpdate({
    required this.matchId,
    required this.status,
    required this.timestamp,
  });
}
