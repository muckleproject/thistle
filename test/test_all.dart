import 'thistle_test.dart' as thistle_test;
import 'examples.dart' as examples_test;
import 'src/graphson_test.dart' as graphson_test;
import 'src/impl/memory_graph_test.dart' as memory_graph_test;
import 'src/utils_test.dart' as utils_test;

void main(){
  thistle_test.main();
  examples_test.main();
  graphson_test.main();
  memory_graph_test.main();
  utils_test.main();
}