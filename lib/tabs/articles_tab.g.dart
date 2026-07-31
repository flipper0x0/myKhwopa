// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'articles_tab.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoticeAdapter extends TypeAdapter<Notice> {
  @override
  final int typeId = 0;

  @override
  Notice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Notice(
      id: fields[0] as String,
      title: fields[1] as String,
      postDate: fields[4] as DateTime,
      fileUrl: fields[2] as String,
      hits: fields[3] as String,
      descriptionHtml: (fields[5] as String?) ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, Notice obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.fileUrl)
      ..writeByte(3)
      ..write(obj.hits)
      ..writeByte(4)
      ..write(obj.postDate)
      ..writeByte(5)
      ..write(obj.descriptionHtml);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoticeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NewsAdapter extends TypeAdapter<News> {
  @override
  final int typeId = 1;

  @override
  News read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return News(
      id: fields[0] as String,
      title: fields[1] as String,
      postDate: fields[5] as DateTime,
      imageUrl: fields[2] as String,
      descriptionHtml: fields[3] as String,
      hits: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, News obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.descriptionHtml)
      ..writeByte(4)
      ..write(obj.hits)
      ..writeByte(5)
      ..write(obj.postDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NewsletterAdapter extends TypeAdapter<Newsletter> {
  @override
  final int typeId = 2;

  @override
  Newsletter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Newsletter(
      id: fields[0] as String,
      title: fields[1] as String,
      postDate: fields[4] as DateTime,
      pdfUrl: fields[2] as String,
      coverImageUrl: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Newsletter obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.pdfUrl)
      ..writeByte(3)
      ..write(obj.coverImageUrl)
      ..writeByte(4)
      ..write(obj.postDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewsletterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EventAdapter extends TypeAdapter<Event> {
  @override
  final int typeId = 3;

  @override
  Event read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Event(
      id: fields[0] as String,
      title: fields[1] as String,
      postDate: fields[4] as DateTime,
      descriptionHtml: fields[2] as String,
      hits: fields[3] as String,
      imageUrl: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.descriptionHtml)
      ..writeByte(3)
      ..write(obj.hits)
      ..writeByte(4)
      ..write(obj.postDate)
      ..writeByte(5)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
