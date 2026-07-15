// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_hr_measurement.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetHrWorkoutSessionCollection on Isar {
  IsarCollection<HrWorkoutSession> get hrWorkoutSessions => this.collection();
}

const HrWorkoutSessionSchema = CollectionSchema(
  name: r'HrWorkoutSession',
  id: 6235731540371855739,
  properties: {
    r'endTime': PropertySchema(
      id: 0,
      name: r'endTime',
      type: IsarType.dateTime,
    ),
    r'samples': PropertySchema(
      id: 1,
      name: r'samples',
      type: IsarType.objectList,

      target: r'IsarHrSample',
    ),
    r'startTime': PropertySchema(
      id: 2,
      name: r'startTime',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _hrWorkoutSessionEstimateSize,
  serialize: _hrWorkoutSessionSerialize,
  deserialize: _hrWorkoutSessionDeserialize,
  deserializeProp: _hrWorkoutSessionDeserializeProp,
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
  },
  links: {},
  embeddedSchemas: {r'IsarHrSample': IsarHrSampleSchema},

  getId: _hrWorkoutSessionGetId,
  getLinks: _hrWorkoutSessionGetLinks,
  attach: _hrWorkoutSessionAttach,
  version: '3.3.2',
);

int _hrWorkoutSessionEstimateSize(
  HrWorkoutSession object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.samples.length * 3;
  {
    final offsets = allOffsets[IsarHrSample]!;
    for (var i = 0; i < object.samples.length; i++) {
      final value = object.samples[i];
      bytesCount += IsarHrSampleSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _hrWorkoutSessionSerialize(
  HrWorkoutSession object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.endTime);
  writer.writeObjectList<IsarHrSample>(
    offsets[1],
    allOffsets,
    IsarHrSampleSchema.serialize,
    object.samples,
  );
  writer.writeDateTime(offsets[2], object.startTime);
}

HrWorkoutSession _hrWorkoutSessionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = HrWorkoutSession();
  object.endTime = reader.readDateTime(offsets[0]);
  object.id = id;
  object.samples =
      reader.readObjectList<IsarHrSample>(
        offsets[1],
        IsarHrSampleSchema.deserialize,
        allOffsets,
        IsarHrSample(),
      ) ??
      [];
  object.startTime = reader.readDateTime(offsets[2]);
  return object;
}

P _hrWorkoutSessionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readObjectList<IsarHrSample>(
                offset,
                IsarHrSampleSchema.deserialize,
                allOffsets,
                IsarHrSample(),
              ) ??
              [])
          as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _hrWorkoutSessionGetId(HrWorkoutSession object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _hrWorkoutSessionGetLinks(HrWorkoutSession object) {
  return [];
}

void _hrWorkoutSessionAttach(
  IsarCollection<dynamic> col,
  Id id,
  HrWorkoutSession object,
) {
  object.id = id;
}

extension HrWorkoutSessionQueryWhereSort
    on QueryBuilder<HrWorkoutSession, HrWorkoutSession, QWhere> {
  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterWhere> anyStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'startTime'),
      );
    });
  }
}

extension HrWorkoutSessionQueryWhere
    on QueryBuilder<HrWorkoutSession, HrWorkoutSession, QWhereClause> {
  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterWhereClause>
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

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterWhereClause> idBetween(
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

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterWhereClause>
  startTimeEqualTo(DateTime startTime) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'startTime', value: [startTime]),
      );
    });
  }

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterWhereClause>
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

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterWhereClause>
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

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterWhereClause>
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

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterWhereClause>
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
}

extension HrWorkoutSessionQueryFilter
    on QueryBuilder<HrWorkoutSession, HrWorkoutSession, QFilterCondition> {
  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterFilterCondition>
  endTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'endTime', value: value),
      );
    });
  }

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterFilterCondition>
  endTimeGreaterThan(DateTime value, {bool include = false}) {
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

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterFilterCondition>
  endTimeLessThan(DateTime value, {bool include = false}) {
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

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterFilterCondition>
  endTimeBetween(
    DateTime lower,
    DateTime upper, {
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

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterFilterCondition>
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

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterFilterCondition>
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

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterFilterCondition>
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

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterFilterCondition>
  samplesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'samples', length, true, length, true);
    });
  }

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterFilterCondition>
  samplesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'samples', 0, true, 0, true);
    });
  }

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterFilterCondition>
  samplesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'samples', 0, false, 999999, true);
    });
  }

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterFilterCondition>
  samplesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'samples', 0, true, length, include);
    });
  }

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterFilterCondition>
  samplesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'samples', length, include, 999999, true);
    });
  }

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterFilterCondition>
  samplesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'samples',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterFilterCondition>
  startTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startTime', value: value),
      );
    });
  }

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterFilterCondition>
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

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterFilterCondition>
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

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterFilterCondition>
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

extension HrWorkoutSessionQueryObject
    on QueryBuilder<HrWorkoutSession, HrWorkoutSession, QFilterCondition> {
  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterFilterCondition>
  samplesElement(FilterQuery<IsarHrSample> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'samples');
    });
  }
}

extension HrWorkoutSessionQueryLinks
    on QueryBuilder<HrWorkoutSession, HrWorkoutSession, QFilterCondition> {}

extension HrWorkoutSessionQuerySortBy
    on QueryBuilder<HrWorkoutSession, HrWorkoutSession, QSortBy> {
  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterSortBy>
  sortByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterSortBy>
  sortByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterSortBy>
  sortByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterSortBy>
  sortByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }
}

extension HrWorkoutSessionQuerySortThenBy
    on QueryBuilder<HrWorkoutSession, HrWorkoutSession, QSortThenBy> {
  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterSortBy>
  thenByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterSortBy>
  thenByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterSortBy>
  thenByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QAfterSortBy>
  thenByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }
}

extension HrWorkoutSessionQueryWhereDistinct
    on QueryBuilder<HrWorkoutSession, HrWorkoutSession, QDistinct> {
  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QDistinct>
  distinctByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endTime');
    });
  }

  QueryBuilder<HrWorkoutSession, HrWorkoutSession, QDistinct>
  distinctByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startTime');
    });
  }
}

extension HrWorkoutSessionQueryProperty
    on QueryBuilder<HrWorkoutSession, HrWorkoutSession, QQueryProperty> {
  QueryBuilder<HrWorkoutSession, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<HrWorkoutSession, DateTime, QQueryOperations> endTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endTime');
    });
  }

  QueryBuilder<HrWorkoutSession, List<IsarHrSample>, QQueryOperations>
  samplesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'samples');
    });
  }

  QueryBuilder<HrWorkoutSession, DateTime, QQueryOperations>
  startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startTime');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const IsarHrSampleSchema = Schema(
  name: r'IsarHrSample',
  id: -8067309304292183760,
  properties: {
    r'bpm': PropertySchema(id: 0, name: r'bpm', type: IsarType.long),
    r'rrIntervals': PropertySchema(
      id: 1,
      name: r'rrIntervals',
      type: IsarType.doubleList,
    ),
    r'timestamp': PropertySchema(
      id: 2,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _isarHrSampleEstimateSize,
  serialize: _isarHrSampleSerialize,
  deserialize: _isarHrSampleDeserialize,
  deserializeProp: _isarHrSampleDeserializeProp,
);

int _isarHrSampleEstimateSize(
  IsarHrSample object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.rrIntervals.length * 8;
  return bytesCount;
}

void _isarHrSampleSerialize(
  IsarHrSample object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.bpm);
  writer.writeDoubleList(offsets[1], object.rrIntervals);
  writer.writeDateTime(offsets[2], object.timestamp);
}

IsarHrSample _isarHrSampleDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarHrSample();
  object.bpm = reader.readLong(offsets[0]);
  object.rrIntervals = reader.readDoubleList(offsets[1]) ?? [];
  object.timestamp = reader.readDateTime(offsets[2]);
  return object;
}

P _isarHrSampleDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDoubleList(offset) ?? []) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension IsarHrSampleQueryFilter
    on QueryBuilder<IsarHrSample, IsarHrSample, QFilterCondition> {
  QueryBuilder<IsarHrSample, IsarHrSample, QAfterFilterCondition> bpmEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'bpm', value: value),
      );
    });
  }

  QueryBuilder<IsarHrSample, IsarHrSample, QAfterFilterCondition>
  bpmGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'bpm',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarHrSample, IsarHrSample, QAfterFilterCondition> bpmLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'bpm',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarHrSample, IsarHrSample, QAfterFilterCondition> bpmBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'bpm',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IsarHrSample, IsarHrSample, QAfterFilterCondition>
  rrIntervalsElementEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'rrIntervals',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarHrSample, IsarHrSample, QAfterFilterCondition>
  rrIntervalsElementGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rrIntervals',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarHrSample, IsarHrSample, QAfterFilterCondition>
  rrIntervalsElementLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rrIntervals',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarHrSample, IsarHrSample, QAfterFilterCondition>
  rrIntervalsElementBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rrIntervals',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarHrSample, IsarHrSample, QAfterFilterCondition>
  rrIntervalsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'rrIntervals', length, true, length, true);
    });
  }

  QueryBuilder<IsarHrSample, IsarHrSample, QAfterFilterCondition>
  rrIntervalsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'rrIntervals', 0, true, 0, true);
    });
  }

  QueryBuilder<IsarHrSample, IsarHrSample, QAfterFilterCondition>
  rrIntervalsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'rrIntervals', 0, false, 999999, true);
    });
  }

  QueryBuilder<IsarHrSample, IsarHrSample, QAfterFilterCondition>
  rrIntervalsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'rrIntervals', 0, true, length, include);
    });
  }

  QueryBuilder<IsarHrSample, IsarHrSample, QAfterFilterCondition>
  rrIntervalsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'rrIntervals', length, include, 999999, true);
    });
  }

  QueryBuilder<IsarHrSample, IsarHrSample, QAfterFilterCondition>
  rrIntervalsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'rrIntervals',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarHrSample, IsarHrSample, QAfterFilterCondition>
  timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timestamp', value: value),
      );
    });
  }

  QueryBuilder<IsarHrSample, IsarHrSample, QAfterFilterCondition>
  timestampGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarHrSample, IsarHrSample, QAfterFilterCondition>
  timestampLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarHrSample, IsarHrSample, QAfterFilterCondition>
  timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timestamp',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension IsarHrSampleQueryObject
    on QueryBuilder<IsarHrSample, IsarHrSample, QFilterCondition> {}
