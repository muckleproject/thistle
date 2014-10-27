part of thistle;


class _MemoryGraph implements IGraph {
  
  List<IVertex> vertices = [];
  List<IEdge> edges = [];
  
  List<_ElementListenerHolder> _edgeCreationListeners = []; 
  List<_ElementListenerHolder> _edgeRemovalListeners = []; 
  List<_ElementListenerHolder> _vertexCreationListeners = []; 
  List<_ElementListenerHolder> _vertexRemovalListeners = [];
  
  List<_PropertyListenerHolder> _vertexPropertyChangeListeners = []; 
  List<_PropertyListenerHolder> _edgePropertyChangeListeners = []; 
  List<_PropertyListenerHolder> _vertexPropertyRemovedListeners = []; 
  List<_PropertyListenerHolder> _edgePropertyRemovedListeners = []; 
  
  IVertex addVertex([Map<String, Object> properties]) {
    _Vertex v = new _Vertex(_hasVertexListeners, _vertexPropertyChanged, _vertexPropertyRemoved, properties);
    
    vertices.add(v);
    for(_ElementListenerHolder holder in _vertexCreationListeners){
      holder.doCallback(v);
    }
    
    return v;
  }
  
  void removeVertex(IVertex v){
    if(v != null){
      
      vertices.remove(v);
      for(_ElementListenerHolder holder in _vertexRemovalListeners){
        holder.doCallback(v);
      }
      
      List<IEdge> toRemove = [];
      toRemove.addAll(v.outgoing);
      toRemove.addAll(v.incomming);
      for(IEdge e in toRemove){
        removeEdge(e); 
      }
    }
  }
  
  IEdge addEdge(IVertex from, IVertex to, String label, [Map<String, Object> properties]){
    _Edge e = new _Edge(_hasEdgeListeners, _edgePropertyChanged, _edgePropertyRemoved, from, to, label, properties);
    
   (from as _Vertex).outgoing.add(e);
   (to as _Vertex).incomming.add(e);
    
    edges.add(e);
    for(_ElementListenerHolder holder in _edgeCreationListeners){
      holder.doCallback(e);
    }
    
    return e; 
  }

  void removeEdge(IEdge e){
    if(e != null){
      
      edges.remove(e);
      for(_ElementListenerHolder holder in _edgeRemovalListeners){
        holder.doCallback(e);
      }
      
      (e.from as _Vertex).outgoing.remove(e);
      (e.to as _Vertex).incomming.remove(e);
    }
  }
  
  IEdgeCondition onEdgeCreation(EdgeFunction f){
    _EdgeElementListenerHolder eh = new _EdgeElementListenerHolder(f);
    _edgeCreationListeners.add(eh);
    return eh;
  }
  
  void removeOnEdgeCreation(EdgeFunction f){
    _edgeCreationListeners.removeWhere((eh) => eh.callbackMatches(f));  
  }
  
  IEdgeCondition onEdgeRemoval(EdgeFunction f){
    _EdgeElementListenerHolder eh = new _EdgeElementListenerHolder(f);
    _edgeRemovalListeners.add(eh); 
    return eh;
  }
  
  void removeOnEdgeRemoval(EdgeFunction f){
    _edgeRemovalListeners.removeWhere((eh) => eh.callbackMatches(f)); 
  }
  
  IVertexCondition onVertexCreation(VertexFunction f){
    _VertexElementListenerHolder eh = new _VertexElementListenerHolder(f);
    _vertexCreationListeners.add(eh); 
    return eh;
  }
  
  void removeOnVertexCreation(VertexFunction f){
    _vertexCreationListeners.removeWhere((eh) => eh.callbackMatches(f));   
 }
  
  IVertexCondition onVertexRemoval(VertexFunction f){
    _VertexElementListenerHolder eh = new _VertexElementListenerHolder(f);
    _vertexRemovalListeners.add(eh);
    return eh;
  }
  
  void removeOnVertexRemoval(VertexFunction f){
    _vertexRemovalListeners.removeWhere((eh) => eh.callbackMatches(f));   
  }
  
  IVertexPropertyCondition onVertexPropertyChange(VertexPropertyChangeFunction callback){
    _VertexPropertyListenerHolder ph = new _VertexPropertyListenerHolder(callback);
    _vertexPropertyChangeListeners.add(ph); 
    return ph;
  }

  void removeOnVertexPropertyChange(VertexPropertyChangeFunction f){
    _vertexPropertyChangeListeners.removeWhere((ch) => ch.callbackMatches(f));   
  }
  
  IEdgePropertyCondition onEdgePropertyChange(EdgePropertyChangeFunction callback){
    _EdgePropertyListenerHolder ph = new _EdgePropertyListenerHolder(callback);
    _edgePropertyChangeListeners.add(ph);
    return ph;
  }

  void removeOnEdgePropertyChange(EdgePropertyChangeFunction f){
    _edgePropertyChangeListeners.removeWhere((ch) => ch.callbackMatches(f));   
  }
  
  IVertexPropertyCondition onVertexPropertyRemoved(VertexPropertyChangeFunction callback){
    _VertexPropertyListenerHolder ph = new _VertexPropertyListenerHolder(callback);
    _vertexPropertyRemovedListeners.add(ph);
    return ph;
  }

  void removeOnVertexPropertyRemoved(VertexPropertyChangeFunction f){
    _vertexPropertyRemovedListeners.removeWhere((ch) => ch.callbackMatches(f));   
  }
  
  IEdgePropertyCondition onEdgePropertyRemoved(EdgePropertyChangeFunction callback){
    _EdgePropertyListenerHolder ph = new _EdgePropertyListenerHolder(callback);
    _edgePropertyRemovedListeners.add(ph);
    return ph;
  }

  void removeOnEdgePropertyRemoved(EdgePropertyChangeFunction f){
    _edgePropertyRemovedListeners.removeWhere((ch) => ch.callbackMatches(f));   
  }
  
  void _vertexPropertyChanged(IVertex v, String key, Object oldValue){
    for(_PropertyListenerHolder  lh in _vertexPropertyChangeListeners){
      lh.doCallback(v, key, oldValue);
    }
  }
  
  void _edgePropertyChanged(IEdge e, String key, Object oldValue){
    for(_PropertyListenerHolder  lh in _edgePropertyChangeListeners){
      lh.doCallback(e, key, oldValue);
    }
  }
  
  void _vertexPropertyRemoved(IVertex v, String key, Object oldValue){
    for(_PropertyListenerHolder  lh in _vertexPropertyRemovedListeners){
      lh.doCallback(v, key, oldValue);
    }
  }
  
  void _edgePropertyRemoved(IEdge e, String key, Object oldValue){
    for(_PropertyListenerHolder  lh in _edgePropertyRemovedListeners){
      lh.doCallback(e, key, oldValue);
    }
  }
  
  bool _hasEdgeListeners(){
    return _edgePropertyChangeListeners.isNotEmpty || _edgePropertyRemovedListeners.isNotEmpty;
  }
  
  bool _hasVertexListeners(){
    return _vertexPropertyChangeListeners.isNotEmpty || _vertexPropertyRemovedListeners.isNotEmpty;
  }
  
  Object accept(IGraphVisitor v){
    return v.visitGraph(this);
  }
  
  void shutdown(){}

}

abstract class _Element implements IElement, _MapObserver<String, Object> {
  
  _ObservableMap<String, Object> properties;
  _PropertyChangeFunction _updatedListener;
  _PropertyChangeFunction _removedListener;
  _BooleanFunction _hasActiveListeners;
  
  _Element(this._hasActiveListeners, this._updatedListener, this._removedListener, Map<String, Object> props){
    properties = new _ObservableMap(this);
    if(props != null){
      properties.addSilently(props);
    }
  }
  
  noSuchMethod(Invocation invocation){
    if(invocation.isGetter){
      return properties[MirrorSystem.getName(invocation.memberName)];
    }
    else if(invocation.isSetter){
      String name = MirrorSystem.getName(invocation.memberName);
      properties[name.substring(0, name.length-1)] = invocation.positionalArguments[0];
    }
  }
  
  //--  _MapObserver interface
  bool get isActive => _hasActiveListeners();

  void removed(String key, Object oldValue){
    _removedListener(this, key, oldValue);
  }
  
  void updated(String key, Object oldValue){
    _updatedListener(this, key, oldValue);
  }

}

class _Vertex extends _Element implements IVertex  {
  
  List<IEdge> incomming = [];
  List<IEdge> outgoing = [];
  
  _Vertex(hasActiveListeners, updatedListener, removedListener, properties) : super(hasActiveListeners, updatedListener, removedListener, properties);
  
  Object accept(IGraphVisitor v){
    return v.visitVertex(this);
  }
  
  String toString(){
    String inCount = incomming.length.toString();
    String outCount = outgoing.length.toString();
    return "($properties in[$inCount] out[$outCount])";
  }

}

class _Edge extends _Element implements IEdge {
  
  IVertex from, to;
  String label;
  
  _Edge(hasActiveListeners, updatedListener, removedListener, this.from, this.to, this.label, properties) : super(hasActiveListeners, updatedListener, removedListener, properties);
  
  Object accept(IGraphVisitor v){
    return v.visitEdge(this);
  }
  
  String toString(){
    return "$from-- $label $properties -->$to";
  }

}
