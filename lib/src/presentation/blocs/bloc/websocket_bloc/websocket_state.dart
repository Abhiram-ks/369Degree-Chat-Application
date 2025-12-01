part of 'websocket_bloc.dart';

class WebSocketState {
  final WebSocketConnectionStatus connectionStatus;
  final bool isConnected;
  final Map<int, bool> typingUsers;

  WebSocketState({
    this.connectionStatus = WebSocketConnectionStatus.disconnected,
    this.isConnected = false,
    Map<int, bool>? typingUsers,
  }) : typingUsers = typingUsers ?? {};

  bool isTypingForUser(int userId) {
    return typingUsers[userId] ?? false;
  }

  WebSocketState copyWith({
    WebSocketConnectionStatus? connectionStatus,
    bool? isConnected,
    Map<int, bool>? typingUsers,
  }) {
    return WebSocketState(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      isConnected: isConnected ?? this.isConnected,
      typingUsers: typingUsers ?? this.typingUsers,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WebSocketState &&
        other.connectionStatus == connectionStatus &&
        other.isConnected == isConnected &&
        other.typingUsers.length == typingUsers.length &&
        other.typingUsers.keys.every((key) => typingUsers[key] == other.typingUsers[key]);
  }

  @override
  int get hashCode {
    return connectionStatus.hashCode ^
        isConnected.hashCode ^
        typingUsers.hashCode;
  }
}

class WebSocketInitial extends WebSocketState {
  WebSocketInitial() : super();
}

