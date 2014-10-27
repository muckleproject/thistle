part of thistle;

/// The public interfaces for this package.
abstract class IGraph implements IVistableGraphElement {
  
  /// Returns a new IVertex implementation after adding it to the graph.
  /// 
  /// The optional [properties] parameter is used as the properties field of the 
  /// constructed IVertex. 
  /// BEWARE [properties] if supplied may NOT be copied but simply used. 
  IVertex addVertex([Map<String, Object> properties]);
  
  /// Removes an implementation of IVertex from the graph along with its associated
  /// incomming and outgoing IEdge's.
  void removeVertex(IVertex v);
  
  /// Returns a new IEdge implementation after connecting it to the [from] and [to]
  /// vertices.
  /// 
  /// The [label] must be supplied and the optional [properties] parameter is used 
  /// as the properties field of the constructed IEdge.
  /// BEWARE [properties] if supplied may NOT be copied but simply used. 
  IEdge addEdge(IVertex from, IVertex to, String label, [Map<String, Object> properties]);
  
  /// Removes an implementation of IEdge from the graph along with its association
  /// to the "from" and "to" vertices "outgoing" and "incomming" fields.
  void removeEdge(IEdge e);
  
  /// Returns an iterator for all the vertices in the graph.
  Iterable<IVertex> get vertices;
  
  /// Returns an iterator for all the edges in the graph.
  Iterable<IEdge> get edges; 
  
  /// Adds a [callback] function that will be called after a new IEdge is added
  /// to the graph.
  /// The returned [IEdgeCondition] can be used to make the callback conditional.
  IEdgeCondition onEdgeCreation(EdgeFunction callback);
  
  /// Removes the edge creation [callback] from the callback list.
  void removeOnEdgeCreation(EdgeFunction callback);
  
  /// Adds a [callback] function that will be called after an IEdge is removed
  /// from the graph.
  /// The returned [IEdgeCondition] can be used to make the callback conditional.
  IEdgeCondition onEdgeRemoval(EdgeFunction callback);
  
  /// Removes the edge removal [callback] from the callback list.
  void removeOnEdgeRemoval(EdgeFunction callback);

  /// Adds a [callback] function that will be called after a new IVertex is added
  /// to the graph.
  /// The returned [IVertexCondition] can be used to make the callback conditional.
  IVertexCondition onVertexCreation(VertexFunction callback);

  /// Removes the vertex creation [callback] from the callback list.
  void removeOnVertexCreation(VertexFunction callback);

  /// Adds a [callback] function that will be called after an IVertex is removed
  /// from the graph.
  /// The returned [IVertexCondition] can be used to make the callback conditional.
  IVertexCondition onVertexRemoval(VertexFunction callback);

  /// Removes the vertex removal [callback] from the callback list.
  void removeOnVertexRemoval(VertexFunction callback);
  
  /// Adds a [VertextPropertyChangeFunction] [callback] function that will be called 
  /// after a vertex property has been changed.
  IVertexPropertyCondition onVertexPropertyChange(VertexPropertyChangeFunction callback);

  /// Removes the vertex propery change [callback] from the callback list.
  void removeOnVertexPropertyChange(VertexPropertyChangeFunction callback);
  
  /// Adds a [EdgePropertyChangeFunction] [callback] function that will be called 
  /// after an edge property has been changed.
  IEdgePropertyCondition onEdgePropertyChange(EdgePropertyChangeFunction callback);

  /// Removes the edge propery change [callback] from the callback list.
  void removeOnEdgePropertyChange(EdgePropertyChangeFunction callback);
  
  /// Adds a [VertextPropertyChangeFunction] [callback] function that will be called 
  /// after a vertex property has been removed.
  IVertexPropertyCondition onVertexPropertyRemoved(VertexPropertyChangeFunction callback);

  /// Removes the vertex propery change [callback] from the callback list.
  void removeOnVertexPropertyRemoved(VertexPropertyChangeFunction callback);
  
  /// Adds an [EdgePropertyChangeFunction] [callback] function that will be called 
  /// after an edge property has been removed.
  IEdgePropertyCondition onEdgePropertyRemoved(EdgePropertyChangeFunction callback);

  /// Removes the edge propery change [callback] from the callback list.
  void removeOnEdgePropertyRemoved(EdgePropertyChangeFunction callback);

  /// Shutsdown the graph.
  void shutdown();
}

/// Function callback template for edge event listeners.
typedef dynamic EdgeFunction(IEdge e);

/// Function callback template for edge event listeners predicate.
typedef bool EdgeTest(IEdge e);

/// Function callback template for edge property change event listeners.
typedef dynamic EdgePropertyChangeFunction(IEdge e, String key, Object oldValue);

/// Function callback template for edge property change predicate.
typedef bool EdgePropertyChangeTest(IEdge e, String key, Object oldValue);

/// Function callback template for vertex event listeners.
typedef dynamic VertexFunction(IVertex v);

/// Function callback template for vertex event listeners predicate.
typedef bool VertexTest(IVertex v);

/// Function callback template for vertex property change event listeners.
typedef dynamic VertexPropertyChangeFunction(IVertex e, String key, Object oldValue);

/// Function callback template for vertex property change predicate.
typedef bool VertexPropertyChangeTest(IVertex e, String key, Object oldValue);

/// Allows chaining of condions for edge events.
abstract class IEdgeCondition {
  /// Add a conditional [test] to the edge graph mutation callback.
  void when(EdgeTest test);
}

/// Allows chaining of condions for vertex events.
abstract class IVertexCondition {
  /// Add a conditional [test] to the edge graph mutation callback.
  void when(VertexTest test);
}

/// Allows chaining of condions for edge property events.
abstract class IEdgePropertyCondition {
  /// Add a conditional [test] to the edge graph mutation callback.
  void when(EdgePropertyChangeTest test);
}

/// Allows chaining of condions for vertex property events.
abstract class IVertexPropertyCondition {
  /// Add a conditional [test] to the edge graph mutation callback.
  void when(VertexPropertyChangeTest test);
}

/// Allow the use of the visitor pattern to process a graph and its elements.
abstract class IVistableGraphElement {
  Object accept(IGraphVisitor v);  
}

/// If you are to be an IGraphVisitor then you need to implement these
/// methods to do with what you will.
abstract class IGraphVisitor {
  Object visitGraph(IGraph g);  
  Object visitVertex(IVertex v);  
  Object visitEdge(IEdge e);  
}

/// Base interface for all elements of a graph.
abstract class IElement implements IVistableGraphElement {
  /// Returns the properties collection for the element of the graph.
  Map<String, Object> get properties;
}

/// The interface to vertices in the graph.
abstract class IVertex implements IElement {
  /// Returns an iterator for all the edges that connect into this vertex.
  Iterable<IEdge> get incomming; 
  /// Returns an iterator for all the edges that connect from this vertex.
  Iterable<IEdge> get outgoing; 
}

/// The interface to the edges in the graph.
abstract class IEdge implements IElement {
  /// Returns the implementaion of that IVertex that this IEdge is outgoing from.
  IVertex get from;
  /// Returns the implementaion of that IVertex that this IEdge is incomming to.
  IVertex get to;
  /// Returns the label for this IEdge.
  String get label;
}