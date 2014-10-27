library graphson_test;

import 'dart:convert';
import 'package:unittest/unittest.dart';

import 'package:thistle/thistle.dart';

var externaGraphson = {
    "graph": {
        "mode":"NORMAL",
        "vertices": [
            {
                "name": "lop",
                "lang": "java",
                "_id": "3",
                "_type": "vertex"
            },
            {
                "name": "vadas",
                "age": 27,
                "_id": "2",
                "_type": "vertex"
            },
            {
                "name": "marko",
                "age": 29,
                "_id": "1",
                "_type": "vertex"
            },
            {
                "name": "peter",
                "age": 35,
                "_id": "6",
                "_type": "vertex"
            },
            {
                "name": "ripple",
                "lang": "java",
                "_id": "5",
                "_type": "vertex"
            },
            {
                "name": "josh",
                "age": 32,
                "_id": "4",
                "_type": "vertex"
            }
        ],
        "edges": [
            {
                "weight": 1,
                "_id": "10",
                "_type": "edge",
                "_outV": "4",
                "_inV": "5",
                "_label": "created"
            },
            {
                "weight": 0.5,
                "_id": "7",
                "_type": "edge",
                "_outV": "1",
                "_inV": "2",
                "_label": "knows"
            },
            {
                "weight": 0.4000000059604645,
                "_id": "9",
                "_type": "edge",
                "_outV": "1",
                "_inV": "3",
                "_label": "created"
            },
            {
                "weight": 1,
                "_id": "8",
                "_type": "edge",
                "_outV": "1",
                "_inV": "4",
                "_label": "knows"
            },
            {
                "weight": 0.4000000059604645,
                "_id": "11",
                "_type": "edge",
                "_outV": "4",
                "_inV": "3",
                "_label": "created"
            },
            {
                "weight": 0.20000000298023224,
                "_id": "12",
                "_type": "edge",
                "_outV": "6",
                "_inV": "3",
                "_label": "created"
            }
        ]
    }
};


main() {
  
  GraphsonEncoder enc;
  GraphsonDecoder dec;
  IGraph g;
  
  setUp((){
    g = Thistle.newMemoryGraph();
    enc = new GraphsonEncoder();
    dec = new GraphsonDecoder();
  });
  
  Object toObject(String s){
    return new JsonDecoder().convert(s);
  }
  
  group("encode()" , () {
    test("null", () {
      var json = enc.encode(null);
      expect(json, 'null');
    });
    
    test("empty", () {
      var json = enc.encode(g);
      expect(json, '{\n'
        ' "graph": {\n'
        '  "mode": "NORMAL",\n'
        '  "vertices": [],\n'
        '  "edges": []\n'
        ' }\n'
        '}');
    });
    
    test("single vertice no properties", () {
      g.addVertex();
      var jsonObject = toObject(enc.encode(g));
      
      List verticeArray = jsonObject["graph"]["vertices"];
      expect(verticeArray.length, 1);
      
      var v = verticeArray[0];
      expect(v["_id"], "0");
      expect(v["_type"], "vertex");
    });
    
    test("multiple vertices", () {
      g.addVertex();
      g.addVertex();
      g.addVertex();
      var jsonObject = toObject(enc.encode(g));
      
      List verticeArray = jsonObject["graph"]["vertices"];
      expect(verticeArray.length, 3);
      expect(verticeArray[0]["_id"], "0");
      expect(verticeArray[1]["_id"], "1");
      expect(verticeArray[2]["_id"], "2");
    });
    
    test("single vertice with properties", () {
      g.addVertex({"p1": 1});
      var jsonObject = toObject(enc.encode(g));
      var v = jsonObject["graph"]["vertices"][0];
      expect(v["_id"], "0");
      expect(v["_type"], "vertex");
      expect(v["p1"], 1);
    });
    
    test("single edge no properties", () {
      var from = g.addVertex({"name": "from"});
      var to = g.addVertex({"name" : "to"});
      g.addEdge(from, to, "L");
      
      var jsonObject = toObject(enc.encode(g));
      List edgesArray = jsonObject["graph"]["edges"];
      expect(edgesArray.length, 1);
      
      var e = edgesArray[0];
      expect(e["_type"], "edge");
      expect(e["_label"], "L");
      expect(e["_outV"], "0");
      expect(e["_inV"], "1");
    });
    
    test("multiple edges no properties", () {
      var from = g.addVertex({"name": "from"});
      var to = g.addVertex({"name" : "to"});
      g.addEdge(from, to, "L1");
      g.addEdge(from, to, "L2");
      g.addEdge(from, to, "L3");
      
      var jsonObject = toObject(enc.encode(g));
      List edgesArray = jsonObject["graph"]["edges"];
      expect(edgesArray.length, 3);
      expect(edgesArray[0]["_label"], "L1");
      expect(edgesArray[1]["_label"], "L2");
      expect(edgesArray[2]["_label"], "L3");
    });
    
    test("single edge with properties", () {
      var from = g.addVertex({"name": "from"});
      var to = g.addVertex({"name" : "to"});
      g.addEdge(from, to, "L");
      
      var jsonObject = toObject(enc.encode(g));
      var e = jsonObject["graph"]["edges"][0];
      expect(e["_type"], "edge");
      expect(e["_label"], "L");
      expect(e["_outV"], "0");
      expect(e["_inV"], "1");
    });
  });
  
  test("encode decode single edge multi vertices with properties", () {
    var from = g.addVertex({"name": "from"});
    var to = g.addVertex({"name" : "to"});
    g.addEdge(from, to, "L");
    
    IGraph loaded = Thistle.newMemoryGraph();
    dec.loadGraph(enc.encode(g), loaded);
    
    expect(loaded.vertices.length, 2);
    expect(loaded.edges.length, 1);
    
    IEdge e = loaded.edges.first;
    expect("from", e.from.properties["name"]);
    expect("to", e.to.properties["name"]);
  });

  group("decode()", () {
    test("empty", () {
      String empty = '{\n'
        ' "graph": {\n'
        '  "mode": "NORMAL",\n'
        '  "vertices": [],\n'
        '  "edges": []\n'
        ' }\n'
        '}';
      
      dec.loadGraph(empty, g);
      
      expect(g.vertices.length, 0);
      expect(g.edges.length, 0);
    });
  
    test("single vertice", () {
      String empty = '{\n'
        ' "graph": {\n'
        '  "mode": "NORMAL",\n'
        '  "vertices": [{"_type" : "vertex", "_id" : "0"}],\n'
        '  "edges": []\n'
        ' }\n'
        '}';
      
      dec.loadGraph(empty, g);
      
      expect(g.vertices.length, 1);
      expect(g.vertices.first.properties.isEmpty, true);
      expect(g.vertices.first.outgoing.isEmpty, true);
      expect(g.vertices.first.incomming.isEmpty, true);
      expect(g.edges.length, 0);
    });
  
    test("single edge multiple vertices", () {
      String empty = '{\n'
        ' "graph": {\n'
        '  "mode": "NORMAL",\n'
        '  "vertices": [{"_type":"vertex", "_id":"0","name":"from"},{"_type":"vertex", "_id" : "1"}],\n'
        '  "edges": [{"_type":"edge", "_id":"2","_label":"L","_inV":"1","_outV":"0"}]\n'
        ' }\n'
        '}';
      
      dec.loadGraph(empty, g);
      
      expect(g.vertices.length, 2);
      expect(g.edges.length, 1);
      expect(g.edges.first.from.properties["name"], "from");
      expect(g.vertices.first.outgoing.first.label, "L");
    });
    
    test("multiple edge multiple vertices", () {
      String empty = '{\n'
        ' "graph": {\n'
        '  "mode": "NORMAL",\n'
        '  "vertices": [{"_type":"vertex", "_id":"0","name":"from"},{"_type":"vertex", "_id" : "1"}],\n'
        '  "edges": [{"_type":"edge", "_id":"2","_label":"L1","_inV":"1","_outV":"0"}, {"_type":"edge", "_id":"3","_label":"L2","_inV":"1","_outV":"0"}]\n'
        ' }\n'
        '}';
      
      dec.loadGraph(empty, g);
      
      expect(g.vertices.length, 2);
      expect(g.edges.length, 2);
      expect(g.edges.first.from.properties["name"], "from");
      expect(g.vertices.first.outgoing.first.label, "L1");
    });
    
    test("external graphson string", () {
      dec.loadGraph(new JsonEncoder().convert(externaGraphson), g);
     
      expect(g.vertices, hasLength(6));
      expect(g.edges, hasLength(6));
      expect(g.edges.first.label, "created");
      expect(g.vertices.first.name, "lop");
      expect(g.vertices.first.lang, "java");
      expect(g.vertices.first.incomming, hasLength(3));
      expect(g.vertices.first.incomming.first.label, "created");
    });
    
  });
  
  
}

