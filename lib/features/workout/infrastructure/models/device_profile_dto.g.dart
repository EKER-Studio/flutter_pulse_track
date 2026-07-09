// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_profile_dto.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDeviceProfileDtoCollection on Isar {
  IsarCollection<DeviceProfileDto> get deviceProfileDtos => this.collection();
}

const DeviceProfileDtoSchema = CollectionSchema(
  name: r'DeviceProfileDto',
  id: -4917432165112796266,
  properties: {
    r'lastConnectedAt': PropertySchema(
      id: 0,
      name: r'lastConnectedAt',
      type: IsarType.dateTime,
    ),
    r'lastSensorLocationIndex': PropertySchema(
      id: 1,
      name: r'lastSensorLocationIndex',
      type: IsarType.long,
    ),
    r'macAddress': PropertySchema(
      id: 2,
      name: r'macAddress',
      type: IsarType.string,
    ),
    r'name': PropertySchema(id: 3, name: r'name', type: IsarType.string),
  },

  estimateSize: _deviceProfileDtoEstimateSize,
  serialize: _deviceProfileDtoSerialize,
  deserialize: _deviceProfileDtoDeserialize,
  deserializeProp: _deviceProfileDtoDeserializeProp,
  idName: r'id',
  indexes: {
    r'macAddress': IndexSchema(
      id: 3845434121710544094,
      name: r'macAddress',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'macAddress',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _deviceProfileDtoGetId,
  getLinks: _deviceProfileDtoGetLinks,
  attach: _deviceProfileDtoAttach,
  version: '3.3.2',
);

int _deviceProfileDtoEstimateSize(
  DeviceProfileDto object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.macAddress.length * 3;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _deviceProfileDtoSerialize(
  DeviceProfileDto object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.lastConnectedAt);
  writer.writeLong(offsets[1], object.lastSensorLocationIndex);
  writer.writeString(offsets[2], object.macAddress);
  writer.writeString(offsets[3], object.name);
}

DeviceProfileDto _deviceProfileDtoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DeviceProfileDto();
  object.id = id;
  object.lastConnectedAt = reader.readDateTime(offsets[0]);
  object.lastSensorLocationIndex = reader.readLong(offsets[1]);
  object.macAddress = reader.readString(offsets[2]);
  object.name = reader.readString(offsets[3]);
  return object;
}

P _deviceProfileDtoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _deviceProfileDtoGetId(DeviceProfileDto object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _deviceProfileDtoGetLinks(DeviceProfileDto object) {
  return [];
}

void _deviceProfileDtoAttach(
  IsarCollection<dynamic> col,
  Id id,
  DeviceProfileDto object,
) {
  object.id = id;
}

extension DeviceProfileDtoByIndex on IsarCollection<DeviceProfileDto> {
  Future<DeviceProfileDto?> getByMacAddress(String macAddress) {
    return getByIndex(r'macAddress', [macAddress]);
  }

  DeviceProfileDto? getByMacAddressSync(String macAddress) {
    return getByIndexSync(r'macAddress', [macAddress]);
  }

  Future<bool> deleteByMacAddress(String macAddress) {
    return deleteByIndex(r'macAddress', [macAddress]);
  }

  bool deleteByMacAddressSync(String macAddress) {
    return deleteByIndexSync(r'macAddress', [macAddress]);
  }

  Future<List<DeviceProfileDto?>> getAllByMacAddress(
    List<String> macAddressValues,
  ) {
    final values = macAddressValues.map((e) => [e]).toList();
    return getAllByIndex(r'macAddress', values);
  }

  List<DeviceProfileDto?> getAllByMacAddressSync(
    List<String> macAddressValues,
  ) {
    final values = macAddressValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'macAddress', values);
  }

  Future<int> deleteAllByMacAddress(List<String> macAddressValues) {
    final values = macAddressValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'macAddress', values);
  }

  int deleteAllByMacAddressSync(List<String> macAddressValues) {
    final values = macAddressValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'macAddress', values);
  }

  Future<Id> putByMacAddress(DeviceProfileDto object) {
    return putByIndex(r'macAddress', object);
  }

  Id putByMacAddressSync(DeviceProfileDto object, {bool saveLinks = true}) {
    return putByIndexSync(r'macAddress', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByMacAddress(List<DeviceProfileDto> objects) {
    return putAllByIndex(r'macAddress', objects);
  }

  List<Id> putAllByMacAddressSync(
    List<DeviceProfileDto> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'macAddress', objects, saveLinks: saveLinks);
  }
}

extension DeviceProfileDtoQueryWhereSort
    on QueryBuilder<DeviceProfileDto, DeviceProfileDto, QWhere> {
  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DeviceProfileDtoQueryWhere
    on QueryBuilder<DeviceProfileDto, DeviceProfileDto, QWhereClause> {
  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterWhereClause>
  macAddressEqualTo(String macAddress) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'macAddress', value: [macAddress]),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterWhereClause>
  macAddressNotEqualTo(String macAddress) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'macAddress',
                lower: [],
                upper: [macAddress],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'macAddress',
                lower: [macAddress],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'macAddress',
                lower: [macAddress],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'macAddress',
                lower: [],
                upper: [macAddress],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension DeviceProfileDtoQueryFilter
    on QueryBuilder<DeviceProfileDto, DeviceProfileDto, QFilterCondition> {
  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  lastConnectedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastConnectedAt', value: value),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  lastConnectedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastConnectedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  lastConnectedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastConnectedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  lastConnectedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastConnectedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  lastSensorLocationIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lastSensorLocationIndex',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  lastSensorLocationIndexGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastSensorLocationIndex',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  lastSensorLocationIndexLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastSensorLocationIndex',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  lastSensorLocationIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastSensorLocationIndex',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  macAddressEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'macAddress',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  macAddressGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'macAddress',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  macAddressLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'macAddress',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  macAddressBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'macAddress',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  macAddressStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'macAddress',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  macAddressEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'macAddress',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  macAddressContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'macAddress',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  macAddressMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'macAddress',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  macAddressIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'macAddress', value: ''),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  macAddressIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'macAddress', value: ''),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  nameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  nameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  nameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }
}

extension DeviceProfileDtoQueryObject
    on QueryBuilder<DeviceProfileDto, DeviceProfileDto, QFilterCondition> {}

extension DeviceProfileDtoQueryLinks
    on QueryBuilder<DeviceProfileDto, DeviceProfileDto, QFilterCondition> {}

extension DeviceProfileDtoQuerySortBy
    on QueryBuilder<DeviceProfileDto, DeviceProfileDto, QSortBy> {
  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterSortBy>
  sortByLastConnectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastConnectedAt', Sort.asc);
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterSortBy>
  sortByLastConnectedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastConnectedAt', Sort.desc);
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterSortBy>
  sortByLastSensorLocationIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSensorLocationIndex', Sort.asc);
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterSortBy>
  sortByLastSensorLocationIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSensorLocationIndex', Sort.desc);
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterSortBy>
  sortByMacAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'macAddress', Sort.asc);
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterSortBy>
  sortByMacAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'macAddress', Sort.desc);
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterSortBy>
  sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension DeviceProfileDtoQuerySortThenBy
    on QueryBuilder<DeviceProfileDto, DeviceProfileDto, QSortThenBy> {
  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterSortBy>
  thenByLastConnectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastConnectedAt', Sort.asc);
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterSortBy>
  thenByLastConnectedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastConnectedAt', Sort.desc);
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterSortBy>
  thenByLastSensorLocationIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSensorLocationIndex', Sort.asc);
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterSortBy>
  thenByLastSensorLocationIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSensorLocationIndex', Sort.desc);
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterSortBy>
  thenByMacAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'macAddress', Sort.asc);
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterSortBy>
  thenByMacAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'macAddress', Sort.desc);
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QAfterSortBy>
  thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension DeviceProfileDtoQueryWhereDistinct
    on QueryBuilder<DeviceProfileDto, DeviceProfileDto, QDistinct> {
  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QDistinct>
  distinctByLastConnectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastConnectedAt');
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QDistinct>
  distinctByLastSensorLocationIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSensorLocationIndex');
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QDistinct>
  distinctByMacAddress({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'macAddress', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DeviceProfileDto, DeviceProfileDto, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }
}

extension DeviceProfileDtoQueryProperty
    on QueryBuilder<DeviceProfileDto, DeviceProfileDto, QQueryProperty> {
  QueryBuilder<DeviceProfileDto, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DeviceProfileDto, DateTime, QQueryOperations>
  lastConnectedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastConnectedAt');
    });
  }

  QueryBuilder<DeviceProfileDto, int, QQueryOperations>
  lastSensorLocationIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSensorLocationIndex');
    });
  }

  QueryBuilder<DeviceProfileDto, String, QQueryOperations>
  macAddressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'macAddress');
    });
  }

  QueryBuilder<DeviceProfileDto, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }
}
