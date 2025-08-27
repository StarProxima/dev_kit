import 'fetcher/fetcher_test.dart' as fetcher;
import 'linker/linker_test.dart' as linker;
import 'parser/parser_test.dart' as parser;
import 'resolver/resolver_test.dart' as resolver;
import 'searcher/update_searcher/update_searcher_test.dart' as searcher;
import 'shared/shared_test.dart' as shared;

void main() {
  parser.main();
  fetcher.main();
  linker.main();
  searcher.main();
  resolver.main();
  shared.main();
}
