part of thistle;

/// Manages the collection of edges with a specific label
/// when a graph is mutating its edge contents.
class EdgeCollector {
  /// The collection of matching edges. 
  Set<IEdge> collected = new Set();
  
  String _label;
  EdgeFunction _addToSet, _removeFromSet;

  /// Construct and set the label value to match against.
  EdgeCollector(this._label){
    _addToSet = (e) => collected.add(e);  
    _removeFromSet = (e) => collected.remove(e);  
  }
  
  /// Returns true if the supplied edge label matches the one 
  /// supplied in the constructor.
  bool labelMatches(IEdge e){
    return e.label == _label;
  }
 
  /// Attaches this to edge creation and removal events in the graph [g].
  void attachTo(IGraph g){
    g.onEdgeCreation(_addToSet).when(labelMatches);
    g.onEdgeRemoval(_removeFromSet).when(labelMatches);
  }
  
  /// Removes this from edge creation and removal events in the graph [g].
  /// Clears any collected edges as they are invalid after this point in time.
  void detachFrom(IGraph g){
    g.removeOnEdgeCreation(_addToSet);
    g.removeOnEdgeRemoval(_removeFromSet);
    collected.clear();
  }
}

/// A base class for collecting vertices.
abstract class VertexCollector {
  /// The collection of matching vertices.
  Set<IVertex> collected = new Set();
  VertexFunction _addToSet, _removeFromSet;

  VertexCollector(){
    _addToSet = (v) => collected.add(v);  
    _removeFromSet = (v) => collected.remove(v);  
  }
  
  /// Implement this to supply the appropriate match condition. This
  /// method is used as the [IVertexCondition.when] clause to the 
  /// [IVertex.onVertexCreated] and [IVertex.onvertexRemoved] events.
  bool addRemoveCondition(IVertex v);
  
  /// Attaches this to vertice creation and removal events in the graph [g].
  void attachTo(IGraph g){
    g.onVertexCreation(_addToSet).when(addRemoveCondition);
    g.onVertexRemoval(_removeFromSet).when(addRemoveCondition);
  }
  
  /// Removes this from vertice creation and removal events in the graph [g].
  /// Clears any collected vertices as they are invalid after this point in time.
  void detachFrom(IGraph g){
    g.removeOnVertexCreation(_addToSet);
    g.removeOnVertexRemoval(_removeFromSet);
    collected.clear();
  }
}

/// Manages the collection of vertices with a particular property value.
class NamedParameterVertexCollector extends VertexCollector {
  String name;
  Object value;
  VertexPropertyChangeFunction _add, _remove;
  
  /// Collect vertices with a property [name] equal to the supplied [value].
  NamedParameterVertexCollector(this.name, this.value){
    _add = (v, k, o) => collected.add(v);
    _remove = (v, k, o) => collected.remove(v);
  }
  
  /// Returns true when the [name] property of [v] has the [value] supplied
  /// in the constructor.
  bool addRemoveCondition(IVertex v){
    return v.properties[name] == value;  
  }
  
  /// Returns true when the [key] matches the [name] and the new value of
  /// the [name] property of [v] has the [value] supplied in the constructor.
  /// This method is used as the when clause for a property update event
  /// to add [v] to [collected].
  bool propertyUpdateMatchCondition(IVertex v, String key, Object oldValue){
    return _keyMatchesName(key) && addRemoveCondition(v);  
  }

  /// Returns true when the [key] matches the [name] and the new value of
  /// the [name] property of [v] does NOT have the [value] supplied in the constructor.
  /// This method is used as the when clause for a property update event
  /// to remove [v] from [collected].
  bool propertyUpdateNoMatchCondition(IVertex v, String key, Object oldValue){
    return _keyMatchesName(key) && !addRemoveCondition(v);  
  }

  /// Returns true when the [key] matches the [name].
  /// This method is used as the when clause of a property removal event
  /// to remove the vertex [v] from [collected].
  bool propertyRemovedCondition(IVertex v, String key, Object oldValue){
    return _keyMatchesName(key);  
  }
  
  /// Returns true when the [key] matches the [name].
  bool _keyMatchesName(String key){
    return name == key;
  }

  /// Attaches this to all the mutation events required to support add/remove
  /// and property update/removal for vertices.
  void attachTo(IGraph g){
    super.attachTo(g);
    g.onVertexPropertyChange(_add).when(propertyUpdateMatchCondition);
    g.onVertexPropertyChange(_remove).when(propertyUpdateNoMatchCondition);
    g.onVertexPropertyRemoved(_remove).when(propertyRemovedCondition);
  }
  
  /// Removes this from all previously attached events.
  /// Clears any collected vertices as they are invalid after this point in time.
  void detachFrom(IGraph g){
    g.removeOnVertexPropertyChange(_add);
    g.removeOnVertexPropertyChange(_remove);
    g.removeOnVertexPropertyRemoved(_remove);
    super.detachFrom(g); 
  }

}
