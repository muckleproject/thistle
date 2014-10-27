library thistle_test;

import 'package:unittest/unittest.dart';
import 'package:thistle/thistle.dart';

main() {
  
  test("in memory graph constructor", () {
    IGraph g = Thistle.newMemoryGraph();
    expect(g.vertices.length, 0);
    expect(g.edges.length, 0);
  });
  
}