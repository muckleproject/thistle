library utils_test;

import 'package:unittest/unittest.dart';
import 'package:thistle/thistle.dart';

main(){
  
  IGraph g;
  
  setUp(() {
    g = Thistle.newMemoryGraph(); 
  });
  
  group("NamedParameterVertexCollector ", () {
    
    var name = "a name";
    var value = " some value";
    NamedParameterVertexCollector vc;
    
    setUp(() {
      vc = new NamedParameterVertexCollector(name, value);
      vc.attachTo(g);
    });
    
    test("add vertex no matching parameter", () {
      g.addVertex();
      expect(vc.collected.length, 0);
    });
    
    test("add vertex with matching parameter", () {
      IVertex v = g.addVertex({name:value});
      expect(vc.collected.length, 1);
      expect(vc.collected.first, v);
    });
    
    test("add vertex with matching parameter name different value", () {
      IVertex v = g.addVertex({name: 2});
      expect(vc.collected.length, 0);
    });
    
    test("add remove vertex with matching param", () {
      IVertex v = g.addVertex({name:value});
      expect(vc.collected.length, 1);
      
      g.removeVertex(v);
      expect(vc.collected.length, 0);
    });
    
    test("add remove vertex no matching param", () {
      IVertex v = g.addVertex({});
      expect(vc.collected.length, 0);
      
      g.removeVertex(v);
      expect(vc.collected.length, 0);
    });
    
    test("remove vertex property ", () {
      IVertex v = g.addVertex({name:value});
      expect(vc.collected.length, 1);
      
      v.properties.remove(name);
      expect(vc.collected.length, 0);
    });
    
    test("change vertex property value ", () {
      IVertex v = g.addVertex({name:value});
      expect(vc.collected.length, 1);
      
      v.properties[name] = 99;
      expect(vc.collected.length, 0);
    });
    
    test("detachFrom", () {
      IVertex v = g.addVertex({name:value});
      expect(vc.collected.length, 1);
      expect(vc.collected.first, v);
      
      vc.detachFrom(g);
      expect(vc.collected.length, 0);
      
      g.addVertex({name:value});
      expect(vc.collected.length, 0);
    });

  });
  
  group("EdgeCollector", (){
    IVertex from, to;
    EdgeCollector ec;
    String label;
    
    setUp((){
      from = g.addVertex();
      to = g.addVertex();
      label = "a label";
      
      ec = new EdgeCollector(label);
      ec.attachTo(g);
    });
    
    test("add different label", (){
      g.addEdge(from, to, "");
      expect(ec.collected.length, 0);
    });
    
    test("add with label", (){
      IEdge e = g.addEdge(from, to, label);
      
      expect(ec.collected.length, 1);
      expect(ec.collected.first, e);
    });
    
    test("add remove label", (){
      IEdge e = g.addEdge(from, to, label);
      expect(ec.collected.length, 1);
      
      g.removeEdge(e);
      expect(ec.collected.length, 0);
    });
    
    test("detachFrom", (){
      IEdge e = g.addEdge(from, to, label);
      expect(ec.collected.length, 1);
      
      ec.detachFrom(g);
      expect(ec.collected.length, 0);
      
      g.removeEdge(e);
      expect(ec.collected.length, 0);
    });
    
    
  });

}