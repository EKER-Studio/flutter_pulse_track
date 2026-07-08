// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_detail_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TodoDetail)
final todoDetailProvider = TodoDetailFamily._();

final class TodoDetailProvider
    extends $AsyncNotifierProvider<TodoDetail, Todo?> {
  TodoDetailProvider._({
    required TodoDetailFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'todoDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$todoDetailHash();

  @override
  String toString() {
    return r'todoDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TodoDetail create() => TodoDetail();

  @override
  bool operator ==(Object other) {
    return other is TodoDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$todoDetailHash() => r'd3ee66b8f7637714f0dc5767c76ee05928293fd4';

final class TodoDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          TodoDetail,
          AsyncValue<Todo?>,
          Todo?,
          FutureOr<Todo?>,
          int
        > {
  TodoDetailFamily._()
    : super(
        retry: null,
        name: r'todoDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TodoDetailProvider call(int id) =>
      TodoDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'todoDetailProvider';
}

abstract class _$TodoDetail extends $AsyncNotifier<Todo?> {
  late final _$args = ref.$arg as int;
  int get id => _$args;

  FutureOr<Todo?> build(int id);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Todo?>, Todo?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Todo?>, Todo?>,
              AsyncValue<Todo?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
