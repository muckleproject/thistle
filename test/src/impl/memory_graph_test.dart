library memory_graph_test;

import 'package:unittest/unittest.dart';
import 'package:thistle/thistle.dart';


main() {
  
  IGraph g;
  setUp((){
    g = Thistle.newMemoryGraph();
  });
  
  test("empty", () {
    expect(g.vertices.isEmpty, true);
    expect(g.edges.isEmpty, true);
  });
  
  test("addVertex no properties", () {
    IVertex v = g.addVertex();
    expect(v.properties.length, 0);
    expect(v.incomming.isEmpty, true);
    expect(v.outgoing.isEmpty, true);
    expect(g.vertices.length, 1);
    expect(g.edges.isEmpty, true);
    expect(v.toString(), "({} in[0] out[0])");
  });
  
  test("vertex properties", () {
    IVertex v = g.addVertex();
    expect(null, v.properties["abc"]);
    
    v.properties["abc"] = 22;
    expect(22, v.properties["abc"]);
    expect(22, v.abc);
    
    v.abc ="fred";
    expect("fred", v.properties["abc"]);
    expect(v.toString(), "({abc: fred} in[0] out[0])");
  });
  
  test("removeVertex vertex present but not connected", () {
    IVertex v = g.addVertex();
    expect(g.vertices.length, 1);
    expect(g.edges.isEmpty, true);
    
    g.removeVertex(v);
    expect(g.vertices.length, 0);
    expect(g.edges.isEmpty, true);
  });
  
  test("removeVertex vertex null", () {
    g.removeVertex(null);
    expect(g.vertices.length, 0);
    expect(g.edges.isEmpty, true);
  });
  
  test("removeVertex vertex present and connected", () {
    IVertex from = g.addVertex();
    IVertex to = g.addVertex();
    IEdge e = g.addEdge(from, to, "L");
    
    g.removeVertex(from);
    expect(g.vertices.length, 1);
    expect(g.edges.isEmpty, true);
    expect(to.incomming.isEmpty, true);
    expect(from.outgoing.isEmpty, true);
  });
  
  test("addVertex with properties", () {
    IVertex v = g.addVertex({"p1" : 1, "p2": "v2"});
    expect(v.properties.length, 2);
    expect(v.properties['p1'], 1);
    expect(v.properties['p2'], "v2");
  });
  
  test("addVertex multiple times", () {
    g.addVertex();
    g.addVertex();
    expect(g.vertices.length, 2);
    expect(g.edges.isEmpty, true);
  });
  
  test("addEdge ", () {
    IVertex from = g.addVertex();
    IVertex to = g.addVertex();
    IEdge e = g.addEdge(from, to, "L");
    
    expect(g.edges.length , 1);
    expect(from.outgoing.first, e);
    expect(to.incomming.first, e);
    
    expect(e.from, from);
    expect(e.to, to);
    expect(e.properties.isEmpty, true);
    expect(e.label, "L");
    expect(e.toString(), from.toString() + "-- L {} -->" + to.toString());
  });
  
  
  test("edge properties ", () {
    IVertex from = g.addVertex();
    IVertex to = g.addVertex();
    IEdge e = g.addEdge(from, to, "L");
    
    expect(null, e.properties["abc"]);
    
    e.properties["abc"] = 22;
    expect(22, e.properties["abc"]);
    expect(22, e.abc);
    
    e.abc ="fred";
    expect("fred", e.properties["abc"]);
  });
  
   test("removeEdge ", () {
     IVertex from = g.addVertex();
     IVertex to = g.addVertex();
     IEdge e = g.addEdge(from, to, "L");
     g.removeEdge(e);
     
     expect(g.edges.length , 0);
     expect(from.outgoing.isEmpty, true);
     expect(to.incomming.isEmpty, true);
   });
   
    test("removeEdge null ", () {
      g.removeEdge(null);
      expect(g.edges.length , 0);
    });
    
  test("addEdge with properties", () {
    IVertex from = g.addVertex();
    IVertex to = g.addVertex();
    IEdge e = g.addEdge(from, to, "l", {"p1":99});
    
    expect(g.edges.length , 1);
    expect(from.outgoing.first, e);
    expect(to.incomming.first, e);
    
    expect(e.from, from);
    expect(e.to, to);
    expect(e.properties["p1"], 99);
  });
  
  test("add remove vertex creation listeners no test", () {
    int count = 0;
    VertexFunction f = (IVertex v) {count++;};
    g.onVertexCreation(f);
    
    g.addVertex();
    expect(count , 1);
    
    g.removeOnVertexCreation(f);
    g.addVertex();
    expect(count , 1);
  });
  
  test("add remove vertex creation listeners positive test", () {
    int count = 0;
    VertexFunction f = (IVertex v) {count++;};
    VertexTest t = (IVertex v) => v.properties["name"] == 1;
    g.onVertexCreation(f).when(t);
    
    g.addVertex({"name": 1});
    expect(count , 1);
    
    g.removeOnVertexCreation(f);
    g.addVertex();
    expect(count , 1);
  });
  
  test("add remove vertex creation listeners negative test", () {
    int count = 0;
    VertexFunction f = (IVertex v) {count++;};
    VertexTest t = (IVertex v) => v.properties["name"] == 2;
    g.onVertexCreation(f).when(t);
    
    g.addVertex({"name": 1});
    expect(count , 0);
    
    g.removeOnVertexCreation(f);
    g.addVertex();
    expect(count , 0);
  });
  
  test("add remove edge creation listeners", () {
    IVertex from = g.addVertex();
    IVertex to = g.addVertex();
    
    int count = 0;
    EdgeFunction f = (IEdge e){count++;};
    g.onEdgeCreation(f);
    
    IEdge e = g.addEdge(from, to, "");
    expect(count , 1);
    
    g.removeOnEdgeCreation(f);
    g.removeEdge(e);
    
    g.addEdge(from, to, "");
    expect(count , 1);
  });
  
  test("add remove edge creation listeners with true test supplied", () {
    IVertex from = g.addVertex();
    IVertex to = g.addVertex();
    
    int count = 0;
    EdgeFunction f = (IEdge e){count++;};
    EdgeTest t = (IEdge e ) => e.label == "L";
    g.onEdgeCreation(f).when(t);
    
    IEdge e = g.addEdge(from, to, "L");
    expect(count , 1);
    
    g.removeOnEdgeCreation(f);
    g.removeEdge(e);
    
    g.addEdge(from, to, "");
    expect(count , 1);
  });
  
  test("add remove edge creation listeners with false test supplied", () {
    IVertex from = g.addVertex();
    IVertex to = g.addVertex();
    
    int count = 0;
    EdgeFunction f = (IEdge e){count++;};
    EdgeTest t = (IEdge e ) => e.label == "L";
    g.onEdgeCreation(f).when(t);
    
    IEdge e = g.addEdge(from, to, "");
    expect(count , 0);
    
    g.removeOnEdgeCreation(f);
    g.removeEdge(e);
    
    g.addEdge(from, to, "");
    expect(count , 0);
  });
  
  
  test("add remove vertex removal listeners", () {
    int count = 0;
    VertexFunction f = (IVertex v) {count++;};
    g.onVertexRemoval(f);
    
    IVertex v = g.addVertex();
    expect(count , 0);
    g.removeVertex(v);
    expect(count , 1);
    
    g.removeOnVertexRemoval(f);
    v = g.addVertex();    
    g.removeVertex(v);

    expect(count , 1);
  });
  
  test("add remove edge removal listeners no test", () {
    IVertex from = g.addVertex();
    IVertex to = g.addVertex();
    
    int count = 0;
    EdgeFunction f = (IEdge e){count++;};
    g.onEdgeRemoval(f);
    
    IEdge e = g.addEdge(from, to, "");
    expect(count , 0);
    g.removeEdge(e);
    expect(count , 1);
    
    g.removeOnEdgeRemoval(f);
    g.removeEdge(e);
    
    e = g.addEdge(from, to, "");
    g.removeEdge(e);
    expect(count , 1);
  });
  
  test("add remove edge removal listeners with positive test", () {
    IVertex from = g.addVertex();
    IVertex to = g.addVertex();
    
    int count = 0;
    EdgeFunction f = (IEdge e){count++;};
    EdgeTest t = (IEdge e) => true;
    g.onEdgeRemoval(f).when(t);
    
    IEdge e = g.addEdge(from, to, "");
    expect(count , 0);
    g.removeEdge(e);
    expect(count , 1);
    
    g.removeOnEdgeRemoval(f);
    g.removeEdge(e);
    
    e = g.addEdge(from, to, "");
    g.removeEdge(e);
    expect(count , 1);
  });
  
  test("add remove edge removal listeners with negative test", () {
    IVertex from = g.addVertex();
    IVertex to = g.addVertex();
    
    int count = 0;
    EdgeFunction f = (IEdge e){count++;};
    EdgeTest t = (IEdge e) => false;
    g.onEdgeRemoval(f).when(t);
    
    IEdge e = g.addEdge(from, to, "");
    expect(count , 0);
    g.removeEdge(e);
    expect(count , 0);
    
    g.removeOnEdgeRemoval(f);
    g.removeEdge(e);
    
    e = g.addEdge(from, to, "");
    g.removeEdge(e);
    expect(count , 0);
  });
  
  
  test("vertex property changed", () {
    IVertex v = g.addVertex();
    
    int count = 0;
    VertexPropertyChangeFunction f = (v, k, o) => count++;
    g.onVertexPropertyChange(f);

    v.properties["a"] = 1;
    expect(count, 1);
    
    v.a = 2;
    expect(count, 2);
    v.a = 2;
    expect(count, 2);
    
    g.removeOnVertexPropertyChange(f);
    
    v.a = 3;
    expect(count, 2);
  });
  
  test("vertex property change with condition ", () {
    int count = 0;
    VertexPropertyChangeFunction f = (v, k, o) => count++;
    VertexPropertyChangeTest t = (v, k, o) => k == "a";
    g.onVertexPropertyChange(f).when(t);

    IVertex v = g.addVertex();
    expect(count, 0);
    
    v.a = 2;
    expect(count, 1);
    
    v.b = 99;
    expect(count, 1);
    
    g.removeOnVertexPropertyChange(f);
    
    v.a = 3;
    expect(count, 1);
  });
  
  test("vertex property change with constructed properties ", () {
    int count = 0;
    VertexPropertyChangeFunction f = (v, k, o) => count++;
    g.onVertexPropertyChange(f);

    IVertex v = g.addVertex({"a":1, "b":2});
    expect(count, 0);
    
    v.a = 2;
    expect(count, 1);
    
    g.removeOnVertexPropertyChange(f);
    
    v.a = 3;
    expect(count, 1);
  });
  
  test("edge property changed", () {
    IVertex from = g.addVertex();
    IVertex to = g.addVertex();
    
    int count = 0;
    String key;
    Object old;
    EdgePropertyChangeFunction f = (e, k, o) {
      key = k;
      old = o;
      count++;
    };
    g.onEdgePropertyChange(f);

    IEdge e = g.addEdge(from, to, "");
    e.properties["a"] = 1;
    expect(count, 1);
    expect("a", key);
    expect(null, old);
    
    e.a = 2;
    expect(count, 2);
    
    g.removeOnEdgePropertyChange(f);
    
    e.a = 3;
    expect(count, 2);
  });
  
  test("edge property changed with condition", () {
    IVertex from = g.addVertex();
    IVertex to = g.addVertex();
    
    int count = 0;
    EdgePropertyChangeFunction f = (e, k, o) => count++;
    EdgePropertyChangeTest t = (v, k, o) => k == "a";

    g.onEdgePropertyChange(f).when(t);

    IEdge e = g.addEdge(from, to, "");
    e.properties["a"] = 1;
    expect(count, 1);
    
    e.a = 2;
    expect(count, 2);
    
    e.b = 22;
    expect(count, 2);
    
    g.removeOnEdgePropertyChange(f);
    
    e.a = 3;
    expect(count, 2);
  });
  
  test("edge property removed", () {
    IVertex from = g.addVertex();
    IVertex to = g.addVertex();
    
    int count = 0;
    String key;
    Object old;
    EdgePropertyChangeFunction f = (e, k, o) {
      key = k;
      old = o;
      count++;
    };
    g.onEdgePropertyRemoved(f);

    IEdge e = g.addEdge(from, to, "", {"a":1, "b":2});
    e.properties.remove("a");
    
    expect(count, 1);
    expect("a", key);
    expect(1, old);
    
    e.properties.remove("a");
    expect(count, 1);
    
    g.removeOnEdgePropertyRemoved(f);
    
    e.properties.remove("b");
    expect(count, 1);
  });
  
  test("edge property removed with condition", () {
    IVertex from = g.addVertex();
    IVertex to = g.addVertex();
    
    int count = 0;
    EdgePropertyChangeFunction f = (e, k, o) => count++;
    EdgePropertyChangeTest t = (v, k, o) => k == "a";
    g.onEdgePropertyRemoved(f).when(t);

    IEdge e = g.addEdge(from, to, "", {"a":1, "b":2});
    
    e.properties.remove("a");
    expect(count, 1);
    
    e.properties.remove("a");
    expect(count, 1);
    
    e.properties.remove("b");
    expect(count, 1);
    
    g.removeOnEdgePropertyRemoved(f);
    
    e.properties["a"] = 22;
    e.properties.remove("a");
    expect(count, 1);
  });
  
  test("vertex property removed", () {
    IVertex v = g.addVertex({"a":1, "b":2});
    
    int count = 0;
    VertexPropertyChangeFunction f = (v, k, o) => count++;
    g.onVertexPropertyRemoved(f);

    v.properties.remove("a");
    expect(count, 1);
    v.properties.remove("a");
    expect(count, 1);
    
    g.removeOnVertexPropertyRemoved(f);
    
    v.properties.remove("b");
    expect(count, 1);
  });
  
  
  test("vertex property removed with condition", () {
    IVertex v = g.addVertex({"a":1, "b":2});
    
    int count = 0;
    VertexPropertyChangeFunction f = (v, k, o) => count++;
    VertexPropertyChangeTest t = (v, k, o) => k == "a";
    g.onVertexPropertyRemoved(f).when(t);

    v.properties.remove("a");
    expect(count, 1);
    v.properties.remove("a");
    expect(count, 1);
    
    v.properties.remove("b");
    expect(count, 1);
    
    g.removeOnVertexPropertyRemoved(f);
    
    v.properties["a"] = 22;
    v.properties.remove("a");
    expect(count, 1);
  });
  
  test("shutdown", () {
    g.shutdown();
  });
  
}