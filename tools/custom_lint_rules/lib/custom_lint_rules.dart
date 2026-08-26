import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/avoid_infrastructure_imports_in_presentation.dart';

/// Creates the custom lint plugin.
PluginBase createPlugin() => _CustomLintRules();

/// Custom lint rules plugin.
class _CustomLintRules extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    AvoidInfrastructureImportsInPresentation(),
  ];
}
