// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session_dto.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWorkoutSessionDtoCollection on Isar {
  IsarCollection<WorkoutSessionDto> get workoutSessionDtos => this.collection();
}

const WorkoutSessionDtoSchema = CollectionSchema(
  name: r'WorkoutSessionDto',
  id: -5795653538624969225,
  properties: {
    r'avgBpm': PropertySchema(id: 0, name: r'avgBpm', type: IsarType.long),
    r'bpmSamples': PropertySchema(
      id: 1,
      name: r'bpmSamples',
      type: IsarType.longList,
    ),
    r'deviceMacAddress': PropertySchema(
      id: 2,
      name: r'deviceMacAddress',
      type: IsarType.string,
    ),
    r'deviceName': PropertySchema(
      id: 3,
      name: r'deviceName',
      type: IsarType.string,
    ),
    r'endTime': PropertySchema(
      id: 4,
      name: r'endTime',
      type: IsarType.dateTime,
    ),
    r'maxBpm': PropertySchema(id: 5, name: r'maxBpm', type: IsarType.long),
    r'sensorLocationIndex': PropertySchema(
      id: 6,
      name: r'sensorLocationIndex',
      type: IsarType.long,
    ),
    r'startTime': PropertySchema(
      id: 7,
      name: r'startTime',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _workoutSessionDtoEstimateSize,
  serialize: _workoutSessionDtoSerialize,
  deserialize: _workoutSessionDtoDeserialize,
  deserializeProp: _workoutSessionDtoDeserializeProp,
  idName: r'id',
  indexes: {
    r'startTime': IndexSchema(
      id: -3870335341264752872,
      name: r'startTime',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'startTime',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'endTime': IndexSchema(
      id: 6854976694250177488,
      name: r'endTime',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'endTime',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _workoutSessionDtoGetId,
  getLinks: _workoutSessionDtoGetLinks,
  attach: _workoutSessionDtoAttach,
  version: '3.3.2',
);

int _workoutSessionDtoEstimateSize(
  WorkoutSessionDto object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.bpmSamples.length * 8;
  bytesCount += 3 + object.deviceMacAddress.length * 3;
  bytesCount += 3 + object.deviceName.length * 3;
  return bytesCount;
}

void _workoutSessionDtoSerialize(
  WorkoutSessionDto object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.avgBpm);
  writer.writeLongList(offsets[1], object.bpmSamples);
  writer.writeString(offsets[2], object.deviceMacAddress);
  writer.writeString(offsets[3], object.deviceName);
  writer.writeDateTime(offsets[4], object.endTime);
  writer.writeLong(offsets[5], object.maxBpm);
  writer.writeLong(offsets[6], object.sensorLocationIndex);
  writer.writeDateTime(offsets[7], object.startTime);
}

WorkoutSessionDto _workoutSessionDtoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WorkoutSessionDto();
  object.avgBpm = reader.readLong(offsets[0]);
  object.bpmSamples = reader.readLongList(offsets[1]) ?? [];
  object.deviceMacAddress = reader.readString(offsets[2]);
  object.deviceName = reader.readString(offsets[3]);
  object.endTime = reader.readDateTimeOrNull(offsets[4]);
  object.id = id;
  object.maxBpm = reader.readLong(offsets[5]);
  object.sensorLocationIndex = reader.readLong(offsets[6]);
  object.startTime = reader.readDateTime(offsets[7]);
  return object;
}

P _workoutSessionDtoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLongList(offset) ?? []) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _workoutSessionDtoGetId(WorkoutSessionDto object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _workoutSessionDtoGetLinks(
  WorkoutSessionDto object,
) {
  return [];
}

void _workoutSessionDtoAttach(
  IsarCollection<dynamic> col,
  Id id,
  WorkoutSessionDto object,
) {
  object.id = id;
}

extension WorkoutSessionDtoQueryWhereSort
    on QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QWhere> {
  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterWhere>
  anyStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'startTime'),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterWhere> anyEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'endTime'),
      );
    });
  }
}

extension WorkoutSessionDtoQueryWhere
    on QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QWhereClause> {
  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterWhereClause>
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

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterWhereClause>
  idBetween(
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

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterWhereClause>
  startTimeEqualTo(DateTime startTime) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'startTime', value: [startTime]),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterWhereClause>
  startTimeNotEqualTo(DateTime startTime) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startTime',
                lower: [],
                upper: [startTime],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startTime',
                lower: [startTime],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startTime',
                lower: [startTime],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startTime',
                lower: [],
                upper: [startTime],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterWhereClause>
  startTimeGreaterThan(DateTime startTime, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'startTime',
          lower: [startTime],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterWhereClause>
  startTimeLessThan(DateTime startTime, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'startTime',
          lower: [],
          upper: [startTime],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterWhereClause>
  startTimeBetween(
    DateTime lowerStartTime,
    DateTime upperStartTime, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'startTime',
          lower: [lowerStartTime],
          includeLower: includeLower,
          upper: [upperStartTime],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterWhereClause>
  endTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'endTime', value: [null]),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterWhereClause>
  endTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'endTime',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterWhereClause>
  endTimeEqualTo(DateTime? endTime) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'endTime', value: [endTime]),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterWhereClause>
  endTimeNotEqualTo(DateTime? endTime) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'endTime',
                lower: [],
                upper: [endTime],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'endTime',
                lower: [endTime],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'endTime',
                lower: [endTime],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'endTime',
                lower: [],
                upper: [endTime],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterWhereClause>
  endTimeGreaterThan(DateTime? endTime, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'endTime',
          lower: [endTime],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterWhereClause>
  endTimeLessThan(DateTime? endTime, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'endTime',
          lower: [],
          upper: [endTime],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterWhereClause>
  endTimeBetween(
    DateTime? lowerEndTime,
    DateTime? upperEndTime, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'endTime',
          lower: [lowerEndTime],
          includeLower: includeLower,
          upper: [upperEndTime],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension WorkoutSessionDtoQueryFilter
    on QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QFilterCondition> {
  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  avgBpmEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'avgBpm', value: value),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  avgBpmGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'avgBpm',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  avgBpmLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'avgBpm',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  avgBpmBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'avgBpm',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  bpmSamplesElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'bpmSamples', value: value),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  bpmSamplesElementGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'bpmSamples',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  bpmSamplesElementLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'bpmSamples',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  bpmSamplesElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'bpmSamples',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  bpmSamplesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'bpmSamples', length, true, length, true);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  bpmSamplesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'bpmSamples', 0, true, 0, true);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  bpmSamplesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'bpmSamples', 0, false, 999999, true);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  bpmSamplesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'bpmSamples', 0, true, length, include);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  bpmSamplesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'bpmSamples', length, include, 999999, true);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  bpmSamplesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bpmSamples',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  deviceMacAddressEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'deviceMacAddress',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  deviceMacAddressGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'deviceMacAddress',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  deviceMacAddressLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'deviceMacAddress',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  deviceMacAddressBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deviceMacAddress',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  deviceMacAddressStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'deviceMacAddress',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  deviceMacAddressEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'deviceMacAddress',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  deviceMacAddressContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'deviceMacAddress',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  deviceMacAddressMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'deviceMacAddress',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  deviceMacAddressIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deviceMacAddress', value: ''),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  deviceMacAddressIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'deviceMacAddress', value: ''),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  deviceNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'deviceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  deviceNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'deviceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  deviceNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'deviceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  deviceNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deviceName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  deviceNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'deviceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  deviceNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'deviceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  deviceNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'deviceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  deviceNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'deviceName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  deviceNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deviceName', value: ''),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  deviceNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'deviceName', value: ''),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  endTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'endTime'),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  endTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'endTime'),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  endTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'endTime', value: value),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  endTimeGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'endTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  endTimeLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'endTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  endTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'endTime',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
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

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
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

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
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

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  maxBpmEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'maxBpm', value: value),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  maxBpmGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'maxBpm',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  maxBpmLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'maxBpm',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  maxBpmBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'maxBpm',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  sensorLocationIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sensorLocationIndex', value: value),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  sensorLocationIndexGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sensorLocationIndex',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  sensorLocationIndexLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sensorLocationIndex',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  sensorLocationIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sensorLocationIndex',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  startTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startTime', value: value),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  startTimeGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  startTimeLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterFilterCondition>
  startTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startTime',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension WorkoutSessionDtoQueryObject
    on QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QFilterCondition> {}

extension WorkoutSessionDtoQueryLinks
    on QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QFilterCondition> {}

extension WorkoutSessionDtoQuerySortBy
    on QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QSortBy> {
  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  sortByAvgBpm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgBpm', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  sortByAvgBpmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgBpm', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  sortByDeviceMacAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceMacAddress', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  sortByDeviceMacAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceMacAddress', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  sortByDeviceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceName', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  sortByDeviceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceName', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  sortByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  sortByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  sortByMaxBpm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxBpm', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  sortByMaxBpmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxBpm', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  sortBySensorLocationIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sensorLocationIndex', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  sortBySensorLocationIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sensorLocationIndex', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  sortByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  sortByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }
}

extension WorkoutSessionDtoQuerySortThenBy
    on QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QSortThenBy> {
  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  thenByAvgBpm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgBpm', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  thenByAvgBpmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgBpm', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  thenByDeviceMacAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceMacAddress', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  thenByDeviceMacAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceMacAddress', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  thenByDeviceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceName', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  thenByDeviceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceName', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  thenByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  thenByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  thenByMaxBpm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxBpm', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  thenByMaxBpmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxBpm', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  thenBySensorLocationIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sensorLocationIndex', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  thenBySensorLocationIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sensorLocationIndex', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  thenByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QAfterSortBy>
  thenByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }
}

extension WorkoutSessionDtoQueryWhereDistinct
    on QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QDistinct> {
  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QDistinct>
  distinctByAvgBpm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avgBpm');
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QDistinct>
  distinctByBpmSamples() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bpmSamples');
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QDistinct>
  distinctByDeviceMacAddress({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'deviceMacAddress',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QDistinct>
  distinctByDeviceName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QDistinct>
  distinctByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endTime');
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QDistinct>
  distinctByMaxBpm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxBpm');
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QDistinct>
  distinctBySensorLocationIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sensorLocationIndex');
    });
  }

  QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QDistinct>
  distinctByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startTime');
    });
  }
}

extension WorkoutSessionDtoQueryProperty
    on QueryBuilder<WorkoutSessionDto, WorkoutSessionDto, QQueryProperty> {
  QueryBuilder<WorkoutSessionDto, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WorkoutSessionDto, int, QQueryOperations> avgBpmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avgBpm');
    });
  }

  QueryBuilder<WorkoutSessionDto, List<int>, QQueryOperations>
  bpmSamplesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bpmSamples');
    });
  }

  QueryBuilder<WorkoutSessionDto, String, QQueryOperations>
  deviceMacAddressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceMacAddress');
    });
  }

  QueryBuilder<WorkoutSessionDto, String, QQueryOperations>
  deviceNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceName');
    });
  }

  QueryBuilder<WorkoutSessionDto, DateTime?, QQueryOperations>
  endTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endTime');
    });
  }

  QueryBuilder<WorkoutSessionDto, int, QQueryOperations> maxBpmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxBpm');
    });
  }

  QueryBuilder<WorkoutSessionDto, int, QQueryOperations>
  sensorLocationIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sensorLocationIndex');
    });
  }

  QueryBuilder<WorkoutSessionDto, DateTime, QQueryOperations>
  startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startTime');
    });
  }
}
