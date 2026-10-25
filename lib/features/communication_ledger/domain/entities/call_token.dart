import 'package:equatable/equatable.dart';

class CallToken extends Equatable {
  const CallToken({
    required this.sessionId,
    required this.channelName,
    required this.rtcToken,
    required this.callerRole,
    required this.maskedDisplayName,
    this.expiresInSeconds = 3600,
  });

  final String sessionId;
  final String channelName;
  final String rtcToken;
  final String callerRole;
  final String maskedDisplayName;
  final int expiresInSeconds;

  @override
  List<Object?> get props => [
        sessionId,
        channelName,
        rtcToken,
        callerRole,
        maskedDisplayName,
        expiresInSeconds,
      ];
}
