library examples_test;

import 'package:unittest/unittest.dart';
import 'package:thistle/thistle.dart';

var externaGraphson = '{'
    '"graph": {'
     '   "mode":"NORMAL",'
     '   "vertices": ['
     '       {'
     '           "name": "lop",'
     '           "lang": "java",'
     '           "_id": "3",'
     '           "_type": "vertex"'
     '       },'
     '       {'
     '           "name": "vadas",'
     '           "age": 27,'
     '           "_id": "2",'
     '           "_type": "vertex"'
     '       },'
     '       {'
     '           "name": "marko",'
     '           "age": 29,'
     '           "_id": "1",'
     '           "_type": "vertex"'
     '       },'
     '       {'
     '           "name": "peter",'
     '           "age": 35,'
     '           "_id": "6",'
     '           "_type": "vertex"'
     '       },'
     '       {'
     '           "name": "ripple",'
     '           "lang": "java",'
     '           "_id": "5",'
     '           "_type": "vertex"'
     '       },'
     '       {'
     '           "name": "josh",'
     '           "age": 32,'
     '           "_id": "4",'
     '           "_type": "vertex"'
     '       }'
     '   ],'
     '   "edges": ['
     '       {'
     '           "weight": 1,'
     '           "_id": "10",'
     '           "_type": "edge",'
     '           "_outV": "4",'
     '           "_inV": "5",'
     '           "_label": "created"'
     '       },'
     '       {'
     '           "weight": 0.5,'
     '           "_id": "7",'
     '           "_type": "edge",'
     '           "_outV": "1",'
     '           "_inV": "2",'
     '           "_label": "knows"'
     '       },'
     '       {'
     '           "weight": 0.4000000059604645,'
     '           "_id": "9",'
     '           "_type": "edge",'
     '           "_outV": "1",'
     '           "_inV": "3",'
     '           "_label": "created"'
     '       },'
     '       {'
     '           "weight": 1,'
     '           "_id": "8",'
     '           "_type": "edge",'
     '           "_outV": "1",'
     '           "_inV": "4",'
     '           "_label": "knows"'
     '       },'
     '       {'
     '           "weight": 0.4000000059604645,'
     '           "_id": "11",'
     '           "_type": "edge",'
     '           "_outV": "4",'
     '           "_inV": "3",'
     '           "_label": "created"'
     '       },'
     '       {'
     '           "weight": 0.20000000298023224,'
     '           "_id": "12",'
     '           "_type": "edge",'
     '           "_outV": "6",'
     '           "_inV": "3",'
     '           "_label": "created"'
     '       }'
     '   ]'
    '}'
'}';

abstract class EDGES {
  static final String KNOWS = "knows";
}


abstract class VertexCollector {
  Set<IVertex> collected = new Set();
  VertexFunction _addToSet, _removeFromSet;

  VertexCollector(){
    _addToSet = (v) => collected.add(v);  
    _removeFromSet = (v) => collected.remove(v);  
  }
  
  bool addRemoveCondition(IVertex v);
  
  void attachTo(IGraph g){
    g.onVertexCreation(_addToSet).when(addRemoveCondition);
    g.onVertexRemoval(_removeFromSet).when(addRemoveCondition);
  }
  
  void detachFrom(IGraph g){
    g.removeOnVertexCreation(_addToSet);
    g.removeOnVertexRemoval(_removeFromSet);
  }
}

class NamedParameterVertexCollector extends VertexCollector {
  String name;
  Object value;
  VertexPropertyChangeFunction _add, _remove;
  
  NamedParameterVertexCollector(this.name, this.value){
    _add = (v, k, o) => collected.add(v);
    _remove = (v, k, o) => collected.remove(v);
  }
  
  bool addRemoveCondition(IVertex v){
    return v.properties[name] == value;  
  }
  
  bool propertyUpdateCondition(IVertex v, String key, Object oldValue){
    return name == key && addRemoveCondition(v);  
  }

  bool propertyUpdateRemoveCondition(IVertex v, String key, Object oldValue){
    return name == key && !addRemoveCondition(v);  
  }

  bool propertyRemovedCondition(IVertex v, String key, Object oldValue){
    return name == key;  
  }

  void attachTo(IGraph g){
    super.attachTo(g);
    g.onVertexPropertyChange(_add).when(propertyUpdateCondition);
    g.onVertexPropertyChange(_remove).when(propertyUpdateRemoveCondition);
    g.onVertexPropertyRemoved(_remove).when(propertyRemovedCondition);
  }
  
  void detachFrom(IGraph g){
    g.removeOnVertexPropertyChange(_add);
    g.removeOnVertexPropertyChange(_remove);
    g.removeOnVertexPropertyRemoved(_remove);
    super.detachFrom(g); 
  }

}


class KnowsAnOver30Selector {
  
  Set<IVertex> knowsSomeoneOver30 = new Set();

  bool isKnowsEdge(IEdge e) => e.label == EDGES.KNOWS;
  bool knowsOver30(IEdge e) => isKnowsEdge(e) && e.to.age >= 30;
  bool isAgeKey(IElement e, String key, Object oldValue) => key == "age";
  
  void attachTo(IGraph g){
    g.onEdgeCreation((e) => knowsSomeoneOver30.add(e.from)).when(knowsOver30 );
    g.onEdgeRemoval((e) => knowsSomeoneOver30.remove(e.from)).when(knowsOver30 );
    g.onVertexPropertyChange((v,k,o) {
      // find "knows" edges and update people set appropriately.
      if(v.age < 30){
        for(IEdge e in v.incomming.where(isKnowsEdge)){
          knowsSomeoneOver30.remove(e.from);
        }
      }
      else {
        for(IEdge e in v.incomming.where(isKnowsEdge)){
          knowsSomeoneOver30.add(e.from);
        }
      }
    }).when(isAgeKey);
    
    
    g.onVertexPropertyRemoved((v,k,o) {
      for(IEdge e in v.incomming.where(isKnowsEdge)){
        knowsSomeoneOver30.remove(e.from);
      }
    }).when(isAgeKey); 

  }

}

main() {
  
  IGraph g;
  GraphsonDecoder dec;
  
  setUp((){
    g = Thistle.newMemoryGraph();
    dec = new GraphsonDecoder();
  });
  
  void loadGraph(){
    dec.loadGraph(externaGraphson, g);  
  }
  
  test("Iterate over all adges.", () {
    loadGraph();
    
    var knowsOver30  = g.edges.where((e) => e.label == "knows" && e.to.properties["age"] >= 30)
                       .map((e) => e.from.properties["name"]);
    
    expect(knowsOver30.length, 1);
    expect(knowsOver30.first, "marko");
  });
  
  test("A little less verbose.", () {
    loadGraph();
    
    var knowsOver30  = g.edges.where((e) => e.label == "knows" && e.to.age >= 30)
                        .map((e) => e.from.name);
    
    expect(knowsOver30.length, 1);
    expect(knowsOver30.first, "marko");
  });
  
  test("Potentially somewhat faster.", () {
    
    Set<IEdge> knows = new Set();
    g.onEdgeCreation((e) {
      if(e.label == "knows"){
        knows.add(e);
      }
    });
    
    loadGraph();
   
    var knowsOver30 = knows.where((e) => e.to.age >= 30)
                     .map((e) => e.from.name);
   
    expect(knowsOver30.length, 1);
    expect(knowsOver30.first, "marko");
  });
  
  test("Potentially somewhat faster with utility collector.", () {
    EdgeCollector knows = new EdgeCollector("knows");
    knows.attachTo(g);
    
    loadGraph();
   
    var knowsOver30 = knows.collected.where((e) => e.to.age >= 30)
                     .map((e) => e.from.name);
   
    expect(knowsOver30.length, 1);
    expect(knowsOver30.first, "marko");
  });
  
  test("Potentially somewhat faster with inline test.", () {
    
    Set<IEdge> knows = new Set();
    g.onEdgeCreation((e) => knows.add(e))
       .when((e) => e.label == "knows");
    
    loadGraph();
   
    var knowsOver30 = knows.where((e) => e.to.age >= 30)
                     .map((e) => e.from.name);
   
    expect(knowsOver30.length, 1);
    expect(knowsOver30.first, "marko");
  });
  
  test("Potentially somewhat faster again", () {
    
    Set<IVertex> people = new Set();
    g.onEdgeCreation((e) => people.add(e.from))
        .when((e) => e.label == "knows" && e.to.age >= 30);
    
    loadGraph();
   
    expect(people.length, 1);
    expect(people.first.name, "marko");
  });
  
  
  test("Predicate functions", () {

    Set<IVertex> people = new Set();

    collectPeople(IEdge e) => people.add(e.from);
    bool knowsDestinationIsOver30(IEdge e) => e.label == "knows" && e.to.age >= 30;
    
    g.onEdgeCreation(collectPeople).when(knowsDestinationIsOver30);
    
    loadGraph();
   
    expect(people.length, 1);
    expect(people.first.name, "marko");
  });
  
  test("Property changed", () {

    bool isKnowsEdge(IEdge e) => e.label == "knows";
    bool knowsOver30(IEdge e) => isKnowsEdge(e) && e.to.age >= 30;

    Set<IVertex> people = new Set();
    g.onEdgeCreation((e) => people.add(e.from))
       .when(knowsOver30 );
    
    loadGraph();
   
    expect(people.length, 1);
    expect(people.first.name, "marko");
    
    g.onVertexPropertyChange((v,k,o) {
      // find "knows" edges and update people set appropriately.
      if(v.age < 30){
        for(IEdge e in v.incomming.where(isKnowsEdge)){
          people.remove(e.from);
        }
      }
      else {
        for(IEdge e in v.incomming.where(isKnowsEdge)){
          people.add(e.from);
        }
      }
    }).when((v, k, o) => k == "age");
    
    // make everyone young;
    for(IVertex v in g.vertices.where((v) => v.age != null)){
      v.age = 20;
    }
    
    expect(people.length, 0);
    
    
    //make everyone old;
    for(IVertex v in g.vertices.where((v) => v.age != null)){
      v.age = 90;
    }
    
    expect(people.length, 1);
    expect(people.first.name, "marko");
  });
  
  
  test("With Selector class", () {
    KnowsAnOver30Selector sel = new KnowsAnOver30Selector();
    sel.attachTo(g);
    
    loadGraph();
   
    expect(sel.knowsSomeoneOver30.length, 1);
    expect(sel.knowsSomeoneOver30.first.name, "marko");
  
    // make everyone young;
    for(IVertex v in g.vertices.where((v) => v.age != null)){
      v.age = 20;
    }
    expect(sel.knowsSomeoneOver30.length, 0);
    
    //make everyone old;
    for(IVertex v in g.vertices.where((v) => v.age != null)){
      v.age = 90;
    }
    expect(sel.knowsSomeoneOver30.length, 1);
    expect(sel.knowsSomeoneOver30.first.name, "marko");
    
    // add a new knows relationship
    IVertex fred = g.addVertex({"name": "fred", "age":22});
    IVertex bob = g.addVertex({"name": "bob", "age":122});
    IEdge fredKnowsBob = g.addEdge(fred, bob, EDGES.KNOWS);
 
    expect(sel.knowsSomeoneOver30.length, 2);

    // remove age property
    bob.properties.remove("age");
    expect(sel.knowsSomeoneOver30.length, 1);
    expect(sel.knowsSomeoneOver30.first.name, "marko");
    
    // add age property
    bob.age = 99;
    expect(sel.knowsSomeoneOver30.length, 2);
    expect(sel.knowsSomeoneOver30.first.name, "marko");
    
    // remove edge
    g.removeEdge(fredKnowsBob);
    expect(sel.knowsSomeoneOver30.length, 1);
    expect(sel.knowsSomeoneOver30.first.name, "marko");
    
  });
  
}