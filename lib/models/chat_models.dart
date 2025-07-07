class Friend {
  final String name;
  final bool isOnline;
  Friend(this.name, this.isOnline);
}

class Message {
  final String sender;
  final String text;
  final DateTime time;
  Message(this.sender, this.text, this.time);
}

class Conversation {
  final Friend friend;
  final List<Message> messages;
  Conversation(this.friend, this.messages);
}
