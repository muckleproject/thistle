thistle
=======

A graph database experiment with the Dart language and its ecosystem.

Getting started -
    
    import 'package:thistle/thistle.dart';
    
    main() {
       IGraph g = Thistle.newMemoryGraph();
    }

The [Thistle] graph world is defined by interfaces (classes whose names start with 
a capital I), there is currently one mechanism for creating a graph - the static 
method shown in the code above. This creates an "in memory" IGraph instance.

Adding a vertex - 

    ...
    
    IVertex v = g.addVertex();
    
    ...

The code shown above creates and adds a vertex to the graph, returning an implementation
of [IVertex]. This vertex has no properties and nothing connected to it and may be 
accessed in the future via the [IGraph.vertices] iterator.


Adding an edge - 

    ...
    
    IVertex from = g.addVertex();
    IVertex to = g.addVertex();
    IEdge e = g.addEdge(from, to, "some label");
    
    ...

The code shown above creates and adds an edge to the graph, returning an implementation
of [IEdge]. This edge has no properties but is directed from the "from" and to the "to" 
vertices. It may be accessed in the future via the [IGraph.edges] iterator.


Iterating over edges - 

    ...
    
    var knowsOver30  = g.edges.where((e) => e.label == "knows" && e.to.properties["age"] >= 30)
                       .map((e) => e.from.properties["name"]);
    
    ...

The code shown above iterates over all the edges in a graph selecting those labeled
with "knows" that end on a vertice where the "age" property is greater than 30 and then 
produces a list of the names of the origin of the "knows over 30" edge.

A little less verbose - 

    ...
    
    var knowsOver30  = g.edges.where((e) => e.label == "knows" && e.to.age >= 30)
                       .map((e) => e.from.name);
    
    ...

The iteration can be made a little less verbose by using a shorthand feature of the 
IVertex and IEdge implementations that attempts to map a dynamic property name
to an element in the [IElement.properties] field. Note there is a performance impact
when using this feature and your editor may complain a little about the dynamic 
properties.


Potentially somewhat faster - 

    Set<IEdge> knows = new Set();
    g.onEdgeCreation((e) {
      if(e.label == "knows"){
        knows.add(e);
      }
    });
    
    ...
    
    // construct the graph after adding the listener
///
    ...
    
    var knowsOver30 = knows.where((e) => e.to.age >= 30)
                     .map((e) => e.from.name);
    
    ...

The whole graph iteration can potentially be optimised if there are many edges 
in the graph by creating an "index" set of edges using an edge creation listener 
callback which can "index" on any property of the edge or combination of properties 
for all the elements reachable from the edge (in this case if its label is 
"knows"). Depending on the size of the graph iterating the "index" collection rather 
than the whole graph may be more efficient.

Potentially somewhat faster with chained conditional - 

    Set<IEdge> knows = new Set();
    g.onEdgeCreation((e) => knows.add(e))
      .when((e) => e.label == "knows");
      
    ...
    
    // construct the graph after adding the listener
///
    ...
    
    var knowsOver30 = knows.where((e) => e.to.age >= 30)
                     .map((e) => e.from.name);
    
    ...
    
Graph event listeners can have a chained conditional test that will be called
to determine if the event listener function should be called. Its a matter of
style/preference as to which conditional approach is best.

Potentially somewhat faster with utility collector - 

        EdgeCollector knows = new EdgeCollector("knows");
        knows.attachTo(g);
    ...
    
    // construct the graph after adding the listener
///
    ...
        var knowsOver30 = knows.collected.where((e) => e.to.age >= 30)
                         .map((e) => e.from.name);
    ...
    
There are some edge and vertice collection utility classes available.



Potentially somewhat faster again (in a slightly different programmatic style) - 

    Set<IVertex> people = new Set();
///
    collectPeople(IEdge e) => people.add(e.from);
    bool knowsDestinationIsOver30(IEdge e) => e.label == "knows" && e.to.age >= 30;
///
    g.onEdgeCreation(collectPeople).when(knowsDestinationIsOver30);
    
    ...
    
    // construct the graph after adding the listener
///
    ...
    
    for(IVertex v in people){
      print(v.name);
    }
    
    ...

The "index" is now a little more specific but potentially very fast.

When using "indices" remember the types of graph mutation event 
listeners that need to be used depend on the usage of the graph. 

If the graph is loaded and never mutates then the only the "onXXXXXCreation" 
listeners need to be added.

If the graph can mutate its edges and vertices then the "onXXXXRemoval"
listeners need to be added.

If the graph edge and vertice properties can mutate and they are used
in the collection of "indices" then the "onXXXXXPropertyChange" and 
"onXXXXXPropertyRemoved" listeners need to be added as well.


The story so far - 

We have a graph model that has no specific query language but utilises
the iteration features in Dart to process the graph. 

For performance considerations we can add one or more arbitrary "index" 
functions for edge and vertice graph mutation events as well as for
edge and vertice property mutation events.


Persistence ( again? ) -

How do we load a graph from some persistent storage somewhere? 
Thistle provides no direct mechanism to do this but it does provide the 
[GraphsonEncoder] and [GraphsonDecoder] classes to assist in the process.

So long as you can persist a [String] somewhere you can persist the state
of the graph, and as long as you can recover that [String] you can recreate
the graph.

To serialise a graph in GraphSON format -

     ...
     
     String gson = new GraphsonEncoder().encode(g);
     // persist the string somewhere
     ...
     
To deserialise a GraphSON format string to a graph -

     ...
     
     IGraph buildGraph(String gson){
       IGraph g = Thistle.newMemoryGraph();
       // add any edge/vertex listeners required
       
       new GraphsonDecoder().loadGraph(gson, g);
       
       return g;
     }
     
     ...
     
Thats it for now. Enjoy.

    \\\\////
     \\\///
     {''''}
    {######}
     {####}
       ||
       || 

