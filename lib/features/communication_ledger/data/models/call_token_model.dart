import '../../domain/entities/call_token.dart';

class CallTokenModel {
  const CallTokenModel({
    required this.sessionId,
    required this.channelName,
    required this.rtcToken,
    required this.callerRole,
    required this.maskedDisplayName,
    this.expiresInSeconds = 3600,
  });

  factory CallTokenModel.fromJson(Map<String, dynamic> json) {
    return CallTokenModel(
      sessionId: json['session_id'] as String? ?? '',
      channelName: json['channel_name'] as String? ?? '',
      rtcToken: json['rtc_token'] as String? ?? '',
      callerRole: json['caller_role'] as String? ?? 'caller',
      maskedDisplayName:
          json['masked_display_name'] as String? ?? 'Verified User',
      expiresInSeconds: json['expires_in_seconds'] as int? ?? 3600,
    );
  }

  final String sessionId;
  final String channelName;
  final String rtcToken;
  final String callerRole;
  final String maskedDisplayName;
  final int expiresInSeconds;

  CallToken toEntity() => CallToken(
        sessionId: sessionId,
        channelName: channelName,
        rtcToken: rtcToken,
        callerRole: callerRole,
        maskedDisplayName: maskedDisplayName,
        expiresInSeconds: expiresInSeconds,
      );
}
