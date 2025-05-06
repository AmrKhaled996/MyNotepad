import 'package:hive/hive.dart';

part "notes.g.dart";

@HiveType(typeId: 0)
class Notes {
  @HiveField(0)
  int? id;

  static int idGene = 0;
  
  @HiveField(1)
  late final String title;
  @HiveField(2)
  late final String content;
  @HiveField(3)
  final String tag;

  Notes({
    int? id,
    required this.title,
    required this.content,
    required this.tag,
  }): id = id ?? idGene++;
}
