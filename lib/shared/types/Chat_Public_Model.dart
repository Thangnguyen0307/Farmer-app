// class ChatPublicRoomModel {
//   final String id;
//   final String roomId;
//   final String ownerId;
//   final String roomName;
//   final String? roomAvatar;
//   bool hasJoin;
//   String mode;

//   ChatPublicRoomModel({
//     required this.id,
//     required this.roomId,
//     required this.ownerId,
//     required this.roomName,
//     this.roomAvatar,
//     this.hasJoin = false,
//     this.mode = 'public',
//   });

//   factory ChatPublicRoomModel.fromJson(Map<String, dynamic> json) {
//     return ChatPublicRoomModel(
//       id: json['_id'],
//       roomId: json['roomId'],
//       ownerId: json['ownerId'],
//       roomName: json['roomName'],
//       roomAvatar: json['roomAvatar'],
//       hasJoin: false,
//       mode: 'public',
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'roomId': roomId,
//       'ownerId': ownerId,
//       'roomName': roomName,
//       'roomAvatar': roomAvatar,
//       'hasJoin': hasJoin ? 1 : 0,
//       'mode': mode,
//     };
//   }
// }
