// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings_dto.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserSettingsDtoCollection on Isar {
  IsarCollection<UserSettingsDto> get userSettingsDtos => this.collection();
}

const UserSettingsDtoSchema = CollectionSchema(
  name: r'UserSettingsDto',
  id: -1895679404152038888,
  properties: {
    r'defaultChartZoomed': PropertySchema(
      id: 0,
      name: r'defaultChartZoomed',
      type: IsarType.bool,
    ),
    r'defaultMaxHr': PropertySchema(
      id: 1,
      name: r'defaultMaxHr',
      type: IsarType.long,
    ),
    r'energyUnit': PropertySchema(
      id: 2,
      name: r'energyUnit',
      type: IsarType.byte,
      enumMap: _UserSettingsDtoenergyUnitEnumValueMap,
    ),
    r'isAnalyticsEnabled': PropertySchema(
      id: 3,
      name: r'isAnalyticsEnabled',
      type: IsarType.bool,
    ),
    r'isBiometricLockEnabled': PropertySchema(
      id: 4,
      name: r'isBiometricLockEnabled',
      type: IsarType.bool,
    ),
    r'isCrashReportingEnabled': PropertySchema(
      id: 5,
      name: r'isCrashReportingEnabled',
      type: IsarType.bool,
    ),
    r'isOnboardingCompleted': PropertySchema(
      id: 6,
      name: r'isOnboardingCompleted',
      type: IsarType.bool,
    ),
    r'themeMode': PropertySchema(
      id: 7,
      name: r'themeMode',
      type: IsarType.byte,
      enumMap: _UserSettingsDtothemeModeEnumValueMap,
    ),
  },

  estimateSize: _userSettingsDtoEstimateSize,
  serialize: _userSettingsDtoSerialize,
  deserialize: _userSettingsDtoDeserialize,
  deserializeProp: _userSettingsDtoDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _userSettingsDtoGetId,
  getLinks: _userSettingsDtoGetLinks,
  attach: _userSettingsDtoAttach,
  version: '3.3.2',
);

int _userSettingsDtoEstimateSize(
  UserSettingsDto object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _userSettingsDtoSerialize(
  UserSettingsDto object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.defaultChartZoomed);
  writer.writeLong(offsets[1], object.defaultMaxHr);
  writer.writeByte(offsets[2], object.energyUnit.index);
  writer.writeBool(offsets[3], object.isAnalyticsEnabled);
  writer.writeBool(offsets[4], object.isBiometricLockEnabled);
  writer.writeBool(offsets[5], object.isCrashReportingEnabled);
  writer.writeBool(offsets[6], object.isOnboardingCompleted);
  writer.writeByte(offsets[7], object.themeMode.index);
}

UserSettingsDto _userSettingsDtoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserSettingsDto();
  object.defaultChartZoomed = reader.readBool(offsets[0]);
  object.defaultMaxHr = reader.readLong(offsets[1]);
  object.energyUnit =
      _UserSettingsDtoenergyUnitValueEnumMap[reader.readByteOrNull(
        offsets[2],
      )] ??
      EnergyUnit.kcal;
  object.id = id;
  object.isAnalyticsEnabled = reader.readBool(offsets[3]);
  object.isBiometricLockEnabled = reader.readBool(offsets[4]);
  object.isCrashReportingEnabled = reader.readBool(offsets[5]);
  object.isOnboardingCompleted = reader.readBool(offsets[6]);
  object.themeMode =
      _UserSettingsDtothemeModeValueEnumMap[reader.readByteOrNull(
        offsets[7],
      )] ??
      AppThemeMode.system;
  return object;
}

P _userSettingsDtoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (_UserSettingsDtoenergyUnitValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              EnergyUnit.kcal)
          as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (_UserSettingsDtothemeModeValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              AppThemeMode.system)
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _UserSettingsDtoenergyUnitEnumValueMap = {'kcal': 0, 'kj': 1};
const _UserSettingsDtoenergyUnitValueEnumMap = {
  0: EnergyUnit.kcal,
  1: EnergyUnit.kj,
};
const _UserSettingsDtothemeModeEnumValueMap = {
  'system': 0,
  'light': 1,
  'dark': 2,
};
const _UserSettingsDtothemeModeValueEnumMap = {
  0: AppThemeMode.system,
  1: AppThemeMode.light,
  2: AppThemeMode.dark,
};

Id _userSettingsDtoGetId(UserSettingsDto object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userSettingsDtoGetLinks(UserSettingsDto object) {
  return [];
}

void _userSettingsDtoAttach(
  IsarCollection<dynamic> col,
  Id id,
  UserSettingsDto object,
) {
  object.id = id;
}

extension UserSettingsDtoQueryWhereSort
    on QueryBuilder<UserSettingsDto, UserSettingsDto, QWhere> {
  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserSettingsDtoQueryWhere
    on QueryBuilder<UserSettingsDto, UserSettingsDto, QWhereClause> {
  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterWhereClause>
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

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterWhereClause> idBetween(
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
}

extension UserSettingsDtoQueryFilter
    on QueryBuilder<UserSettingsDto, UserSettingsDto, QFilterCondition> {
  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterFilterCondition>
  defaultChartZoomedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'defaultChartZoomed', value: value),
      );
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterFilterCondition>
  defaultMaxHrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'defaultMaxHr', value: value),
      );
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterFilterCondition>
  defaultMaxHrGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'defaultMaxHr',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterFilterCondition>
  defaultMaxHrLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'defaultMaxHr',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterFilterCondition>
  defaultMaxHrBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'defaultMaxHr',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterFilterCondition>
  energyUnitEqualTo(EnergyUnit value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'energyUnit', value: value),
      );
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterFilterCondition>
  energyUnitGreaterThan(EnergyUnit value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'energyUnit',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterFilterCondition>
  energyUnitLessThan(EnergyUnit value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'energyUnit',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterFilterCondition>
  energyUnitBetween(
    EnergyUnit lower,
    EnergyUnit upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'energyUnit',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterFilterCondition>
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

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterFilterCondition>
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

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterFilterCondition>
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

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterFilterCondition>
  isAnalyticsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isAnalyticsEnabled', value: value),
      );
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterFilterCondition>
  isBiometricLockEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'isBiometricLockEnabled',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterFilterCondition>
  isCrashReportingEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'isCrashReportingEnabled',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterFilterCondition>
  isOnboardingCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'isOnboardingCompleted',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterFilterCondition>
  themeModeEqualTo(AppThemeMode value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'themeMode', value: value),
      );
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterFilterCondition>
  themeModeGreaterThan(AppThemeMode value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'themeMode',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterFilterCondition>
  themeModeLessThan(AppThemeMode value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'themeMode',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterFilterCondition>
  themeModeBetween(
    AppThemeMode lower,
    AppThemeMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'themeMode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension UserSettingsDtoQueryObject
    on QueryBuilder<UserSettingsDto, UserSettingsDto, QFilterCondition> {}

extension UserSettingsDtoQueryLinks
    on QueryBuilder<UserSettingsDto, UserSettingsDto, QFilterCondition> {}

extension UserSettingsDtoQuerySortBy
    on QueryBuilder<UserSettingsDto, UserSettingsDto, QSortBy> {
  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  sortByDefaultChartZoomed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultChartZoomed', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  sortByDefaultChartZoomedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultChartZoomed', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  sortByDefaultMaxHr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultMaxHr', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  sortByDefaultMaxHrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultMaxHr', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  sortByEnergyUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'energyUnit', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  sortByEnergyUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'energyUnit', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  sortByIsAnalyticsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAnalyticsEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  sortByIsAnalyticsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAnalyticsEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  sortByIsBiometricLockEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBiometricLockEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  sortByIsBiometricLockEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBiometricLockEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  sortByIsCrashReportingEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCrashReportingEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  sortByIsCrashReportingEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCrashReportingEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  sortByIsOnboardingCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOnboardingCompleted', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  sortByIsOnboardingCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOnboardingCompleted', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  sortByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  sortByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }
}

extension UserSettingsDtoQuerySortThenBy
    on QueryBuilder<UserSettingsDto, UserSettingsDto, QSortThenBy> {
  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  thenByDefaultChartZoomed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultChartZoomed', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  thenByDefaultChartZoomedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultChartZoomed', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  thenByDefaultMaxHr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultMaxHr', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  thenByDefaultMaxHrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultMaxHr', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  thenByEnergyUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'energyUnit', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  thenByEnergyUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'energyUnit', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  thenByIsAnalyticsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAnalyticsEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  thenByIsAnalyticsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAnalyticsEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  thenByIsBiometricLockEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBiometricLockEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  thenByIsBiometricLockEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBiometricLockEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  thenByIsCrashReportingEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCrashReportingEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  thenByIsCrashReportingEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCrashReportingEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  thenByIsOnboardingCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOnboardingCompleted', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  thenByIsOnboardingCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOnboardingCompleted', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  thenByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QAfterSortBy>
  thenByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }
}

extension UserSettingsDtoQueryWhereDistinct
    on QueryBuilder<UserSettingsDto, UserSettingsDto, QDistinct> {
  QueryBuilder<UserSettingsDto, UserSettingsDto, QDistinct>
  distinctByDefaultChartZoomed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaultChartZoomed');
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QDistinct>
  distinctByDefaultMaxHr() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaultMaxHr');
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QDistinct>
  distinctByEnergyUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'energyUnit');
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QDistinct>
  distinctByIsAnalyticsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isAnalyticsEnabled');
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QDistinct>
  distinctByIsBiometricLockEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isBiometricLockEnabled');
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QDistinct>
  distinctByIsCrashReportingEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCrashReportingEnabled');
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QDistinct>
  distinctByIsOnboardingCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isOnboardingCompleted');
    });
  }

  QueryBuilder<UserSettingsDto, UserSettingsDto, QDistinct>
  distinctByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'themeMode');
    });
  }
}

extension UserSettingsDtoQueryProperty
    on QueryBuilder<UserSettingsDto, UserSettingsDto, QQueryProperty> {
  QueryBuilder<UserSettingsDto, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserSettingsDto, bool, QQueryOperations>
  defaultChartZoomedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultChartZoomed');
    });
  }

  QueryBuilder<UserSettingsDto, int, QQueryOperations> defaultMaxHrProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultMaxHr');
    });
  }

  QueryBuilder<UserSettingsDto, EnergyUnit, QQueryOperations>
  energyUnitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'energyUnit');
    });
  }

  QueryBuilder<UserSettingsDto, bool, QQueryOperations>
  isAnalyticsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isAnalyticsEnabled');
    });
  }

  QueryBuilder<UserSettingsDto, bool, QQueryOperations>
  isBiometricLockEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isBiometricLockEnabled');
    });
  }

  QueryBuilder<UserSettingsDto, bool, QQueryOperations>
  isCrashReportingEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCrashReportingEnabled');
    });
  }

  QueryBuilder<UserSettingsDto, bool, QQueryOperations>
  isOnboardingCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isOnboardingCompleted');
    });
  }

  QueryBuilder<UserSettingsDto, AppThemeMode, QQueryOperations>
  themeModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'themeMode');
    });
  }
}
