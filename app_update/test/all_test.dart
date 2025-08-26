import 'linker/linker_test.dart' as linker;
import 'parser/parser_test.dart' as parser;
import 'resolver/resolver_test.dart' as resolver;
import 'searcher/update_searcher/update_searcher_test.dart' as searcher;
import 'shared/version_test.dart' as version;

void main() {
  parser.main();
  resolver.main();
  linker.main();
  searcher.main();
  version.main();
}
