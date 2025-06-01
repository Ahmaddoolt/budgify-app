// lib/data/services/local_database_services.dart/category_adaptarr.dart
import 'package:budgify/domain/models/category.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final int typeId = 1; // Unique type ID for this model.

  @override
  Category read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();

    // --- FIX HERE ---
    final descString = reader.readString(); // Read the description string once
    final description = descString.isEmpty ? null : descString; // Assign based on emptiness
    // --- END FIX ---

    final iconKey = reader.readString();
    final colorValue = reader.readInt();
    final isNew = reader.readBool();
    final typeIndex = reader.readInt();

    debugPrint('Reading Category: id=$id, name=$name, iconKey=$iconKey, color=$colorValue, typeIndex=$typeIndex'); // Added name for context

    // Ensure CategoryType enum has enough values for the index
    if (typeIndex < 0 || typeIndex >= CategoryType.values.length) {
       debugPrint('Error: Invalid CategoryType index $typeIndex for category id $id');
       // Handle error appropriately - maybe return a default or throw?
       // For now, let's throw to make the error obvious during debugging
       throw HiveError('Invalid CategoryType index $typeIndex read for category $id');
    }


    return Category(
      id: id,
      name: name,
      description: description,
      iconKey: iconKey,
      color: Color(colorValue),
      isNew: isNew,
      type: CategoryType.values[typeIndex],
    );
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.description ?? ''); // Write empty string if null
    writer.writeString(obj.iconKey);
    writer.writeInt(obj.color.value); // Use value directly
    writer.writeBool(obj.isNew);
    writer.writeInt(obj.type.index);

    debugPrint('Writing Category: id=${obj.id}, name=${obj.name}, iconKey=${obj.iconKey}, color=${obj.color.value}, typeIndex=${obj.type.index}'); // Added name for context
  }
}