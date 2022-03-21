// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hiveDB.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 0;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      itemId: fields[0] as int,
      varId: fields[1] as int,
      varName: fields[2] as String,
      varMinItem: fields[3] as int,
      varMaxItem: fields[4] as int,
      varStock: fields[5] as int,
      varMrp: fields[6] as double,
      itemName: fields[7] as String,
      itemQty: fields[8] as int,
      itemPrice: fields[9] as double,
      membershipPrice: fields[10] as String,
      itemActualprice: fields[11] as double,
      itemImage: fields[12] as String,
      itemWeight: fields[13] as double,
      itemLoyalty: fields[14] as int,
      membershipId: fields[15] as int,
      mode: fields[16] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.itemId)
      ..writeByte(1)
      ..write(obj.varId)
      ..writeByte(2)
      ..write(obj.varName)
      ..writeByte(3)
      ..write(obj.varMinItem)
      ..writeByte(4)
      ..write(obj.varMaxItem)
      ..writeByte(5)
      ..write(obj.varStock)
      ..writeByte(6)
      ..write(obj.varMrp)
      ..writeByte(7)
      ..write(obj.itemName)
      ..writeByte(8)
      ..write(obj.itemQty)
      ..writeByte(9)
      ..write(obj.itemPrice)
      ..writeByte(10)
      ..write(obj.membershipPrice)
      ..writeByte(11)
      ..write(obj.itemActualprice)
      ..writeByte(12)
      ..write(obj.itemImage)
      ..writeByte(13)
      ..write(obj.itemWeight)
      ..writeByte(14)
      ..write(obj.itemLoyalty)
      ..writeByte(15)
      ..write(obj.membershipId)
      ..writeByte(16)
      ..write(obj.mode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
