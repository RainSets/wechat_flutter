import 'dart:convert';

import 'package:dim_example/im/entity/chat_list_entity.dart';
import 'package:dim_example/im/entity/i_person_info_entity.dart';
import 'package:dim_example/im/entity/message_entity.dart';
import 'package:dim_example/im/entity/person_info_entity.dart';
import 'package:flutter/material.dart';
import 'package:dim_example/im/conversation_handle.dart';
import 'package:dim_example/im/info_handle.dart';
import 'package:dim_example/im/message_handle.dart';
import 'package:dim_example/tools/wechat_flutter.dart';

class ChatList {
  ChatList({
    @required this.avatar,
    @required this.name,
    @required this.identifier,
    @required this.content,
    @required this.time,
    @required this.type,
    @required this.msgType,
  });

  final String avatar;
  final String name;
  final int time;
  final String content;
  final String identifier;
  final dynamic type;
  final String msgType;
}

class ChatListData {
  chatListData() async {
    List<ChatList> chatList = new List<ChatList>();
    String avatar;
    String name;
    int time;
    String content;
    String identifier;
    dynamic type;
    String msgType;

    final str = await getConversationsListData();

    if (strNoEmpty(str) && str != '[]') {
      List<dynamic> data = json.decode(str);

      for (int i = 0; i < data.length; i++) {
        ChatListEntity model = ChatListEntity.fromJson(data[i]);
        type = model?.type ?? 'C2C';
        identifier = model?.peer ?? '';

        final profile = await getUsersProfile([model.peer]);
        List<dynamic> profileData = json.decode(profile);
        for (int i = 0; i < profileData.length; i++) {
          if (Platform.isIOS) {
            IPersonInfoEntity info = IPersonInfoEntity.fromJson(profileData[i]);

            if (strNoEmpty(info?.faceURL) && info?.faceURL != '[]') {
              avatar = info?.faceURL ?? defIcon;
            } else {
              avatar = defIcon;
            }
            name = strNoEmpty(info?.nickname)
                ? info?.nickname
                : identifier ?? '未知';
          }else {
            PersonInfoEntity info = PersonInfoEntity.fromJson(profileData[i]);
            if (strNoEmpty(info?.faceUrl) && info?.faceUrl != '[]') {
              avatar = info?.faceUrl ?? defIcon;
            } else {
              avatar = defIcon;
            }
            name =
            strNoEmpty(info?.nickName) ? info?.nickName : identifier ?? '未知';
          }
        }

        final message = await getDimMessages(model.peer, num: 1);
        List<dynamic> messageData = json.decode(message);
        MessageEntity messageModel = MessageEntity.fromJson(messageData[0]);
        content = messageModel.message.text;

        time = messageModel.time;
        msgType = messageModel.message.type;

        chatList.insert(
          0,
          new ChatList(
            type: type,
            identifier: identifier,
            avatar: avatar,
            name: name,
            time: time,
            content: content,
            msgType: msgType,
          ),
        );
      }
    }
    return chatList;
  }
}
