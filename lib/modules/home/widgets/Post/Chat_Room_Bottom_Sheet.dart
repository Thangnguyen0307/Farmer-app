// import 'package:farmrole/modules/home/screens/chat/Chat_Bottom_Sheet_Screen.dart';
// import 'package:flutter/material.dart';

// class ChatRoomBottomSheet extends StatelessWidget {
//   final String roomId;
//   const ChatRoomBottomSheet({super.key, required this.roomId});

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.8,
//       minChildSize: 0.3,
//       maxChildSize: 0.95,
//       builder: (context, scrollController) {
//         return ClipRRect(
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//           child: Material(
//             color: Colors.white,
//             child: Column(
//               children: [
//                 Container(
//                   width: 40,
//                   height: 4,
//                   margin: const EdgeInsets.symmetric(vertical: 10),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[400],
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//                 Expanded(
//                   child: ChatBottomSheetScreen(
//                     roomId: roomId,
//                     isInBottomSheet: true,
//                     scrollController: scrollController,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
