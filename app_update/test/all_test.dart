import 'package:flutter_test/flutter_test.dart';

import 'linker/update_linker_test.dart' as linker;
import 'parser/parser_test.dart' as parser;
import 'resolver/update_rule_resolver/update_rule_resolver_test.dart'
    as resolver;
import 'searcher/update_searcher/update_searcher_test.dart' as searcher;

void main() {
  group('Parser', parser.main);

  group('Resolver', resolver.main);

  group('Linker', linker.main);

  group('Searcher', searcher.main);
}
