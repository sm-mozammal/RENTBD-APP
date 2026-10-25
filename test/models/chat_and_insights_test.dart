import 'package:flutter_test/flutter_test.dart';
import 'package:rentbd_app/features/communication_ledger/data/models/call_token_model.dart';
import 'package:rentbd_app/features/communication_ledger/data/models/chat_message_model.dart';
import 'package:rentbd_app/features/communication_ledger/data/models/chat_room_model.dart';
import 'package:rentbd_app/features/location/data/models/area_insight_model.dart';

void main() {
  group('Chat, Agora Calling & Insights DRF JSON Serialization', () {
    test('should parse DRF chat room & message correctly', () {
      final roomJson = {
        'id': 'room-uuid-01',
        'property_id': '4b7e8d02-15d9-4cf5-992a-fa13de5518b2',
        'property_title': 'Modern 3-BHK Flat in Bashundhara R/A Block D',
        'recipient_id': 'a90f3411-9fa2-47e1-884c-3e61c304859a',
        'recipient_name': 'Kamal Hossain',
        'last_message': 'Assalamu Alaikum',
        'unread_count': 2,
      };

      final roomModel = ChatRoomModel.fromJson(roomJson);
      expect(roomModel.id, 'room-uuid-01');
      expect(roomModel.recipientName, 'Kamal Hossain');
      expect(roomModel.unreadCount, 2);

      final msgJson = {
        'id': 'msg-uuid-99',
        'sender_id': 'c1f73620-8bfa-48b2-b43e-f1cf6c2323a1',
        'sender_name': 'Rahim Ahmed',
        'message': 'Hello, is the flat available for viewing tomorrow afternoon?',
        'created_at': '2026-10-21T00:00:00Z',
      };

      final msgModel = ChatMessageModel.fromJson(msgJson, currentUserId: 'c1f73620-8bfa-48b2-b43e-f1cf6c2323a1');
      expect(msgModel.id, 'msg-uuid-99');
      expect(msgModel.message, 'Hello, is the flat available for viewing tomorrow afternoon?');
      expect(msgModel.isMe, true);
    });

    test('should parse DRF Agora masked VoIP call token response correctly', () {
      final callJson = {
        'session_id': 'call-session-uuid',
        'channel_name': 'rentbd_room_e30f9a',
        'rtc_token': '006abec41f4871...agora_token',
        'caller_role': 'tenant',
        'masked_display_name': 'Verified Tenant',
        'expires_in_seconds': 3600,
      };

      final callModel = CallTokenModel.fromJson(callJson);
      expect(callModel.sessionId, 'call-session-uuid');
      expect(callModel.channelName, 'rentbd_room_e30f9a');
      expect(callModel.rtcToken, '006abec41f4871...agora_token');
      expect(callModel.maskedDisplayName, 'Verified Tenant');
      expect(callModel.expiresInSeconds, 3600);
    });

    test('should parse DRF Crowdsourced Area Insights JSON correctly', () {
      final insightJson = {
        'area': 'mirpur_10',
        'waterlogging_summary': 'low',
        'gas_pressure_avg': 4.2,
        'water_quality_summary': 'drinkable_filtered',
        'safety_rating_avg': 4.5,
        'total_reviews': 38,
        'resident_reviews': [
          {
            'reviewer_name': 'Tariqul Islam',
            'waterlogging_risk': 'low',
            'gas_pressure_rating': 4,
            'safety_rating': 5,
            'review_text': 'Road 14 has zero waterlogging even during monsoon rains.',
          }
        ],
      };

      final insightModel = AreaInsightModel.fromJson(insightJson);
      expect(insightModel.area, 'mirpur_10');
      expect(insightModel.waterloggingSummary, 'low');
      expect(insightModel.gasPressureAvg, 4.2);
      expect(insightModel.safetyRatingAvg, 4.5);
      expect(insightModel.residentReviews.length, 1);
      expect(insightModel.residentReviews.first.reviewerName, 'Tariqul Islam');
    });
  });
}
