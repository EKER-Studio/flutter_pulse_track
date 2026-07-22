import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/avoid_infrastructure_imports_in_presentation.dart';

PluginBase createPlugin() => _CustomLintRules();

class _CustomLintRules extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    AvoidInfrastructureImportsInPresentation(),
  ];
}
