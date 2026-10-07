import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_core/custom_lint_core.dart';

const _presentationSegment = '/presentation/';
const _forbiddenPackagePatterns = [
  'package:isar_community',
  'package:pulse_track/features/workout/infrastructure/',
  'package:pulse_track/features/heart_rate/infrastructure/',
  'package:pulse_track/features/settings/infrastructure/',
  'package:pulse_track/core/infrastructure/',
];

/// Prevents presentation layer from importing infrastructure internals.
class AvoidInfrastructureImportsInPresentation extends DartLintRule {
  /// Creates an [AvoidInfrastructureImportsInPresentation] rule.
  const AvoidInfrastructureImportsInPresentation() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_infrastructure_imports_in_presentation',
    problemMessage:
        'Presentation layer must not import infrastructure or database internals.',
    errorSeverity: DiagnosticSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    final path = resolver.path;
    if (!path.contains(_presentationSegment)) return;

    context.registry.addImportDirective((ImportDirective node) {
      final uri = node.uri.stringValue;
      if (uri == null) return;

      for (final pattern in _forbiddenPackagePatterns) {
        if (uri.startsWith(pattern)) {
          reporter.atOffset(
            diagnosticCode: code,
            offset: node.offset,
            length: node.length,
          );
          return;
        }
      }
    });
  }
}
