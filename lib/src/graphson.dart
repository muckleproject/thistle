part of thistle;

const _TYPE_LABEL = "_type";
const _ID_LABEL = "_id";
const _IN_V_LABEL = "_inV";
const _OUT_V_LABEL = "_outV";
const _LABEL_LABEL = "_label";

/// The Graphson formated json encoder for IGraph implementations.
class GraphsonEncoder implements IGraphVisitor {
  
  Map<IVertex, String> _verticeIDMap = {};
  int _id = 0;
  
  /// Returns the json string for the IGraph [g] in Graphson format.
  /// 
  /// Not an optimal implementation for large graphs. I'm sure there
  /// will be a way to do chunked output.
  String encode(IGraph g){
     return new JsonEncoder.withIndent(" ", 
         (o) => (o as IVistableGraphElement).accept(this)).convert(g);
  }
  
  Object visitGraph(IGraph g){
    return {"graph":{ "mode" : "NORMAL", "vertices": g.vertices, "edges": g.edges}};  
  }
  
  Object visitVertex(IVertex v){
    var node = {_TYPE_LABEL : "vertex"};
    node[_ID_LABEL] = _id.toString();
    _verticeIDMap[v] = _id.toString();
    _id++;
    for(String key in v.properties.keys){
      node[key] = v.properties[key];  
    }
    return node;
  }
  
  Object visitEdge(IEdge e){
    var node = {_TYPE_LABEL : "edge"};
    node[_ID_LABEL] = _id.toString();
    node[_OUT_V_LABEL] = _verticeIDMap[e.from];
    node[_IN_V_LABEL] = _verticeIDMap[e.to];
    node[_LABEL_LABEL] = e.label;
    for(String key in e.properties.keys){
      node[key] = e.properties[key];  
    }
    return node;
  }
  
}

/// The Graphson formated json decoder for IGraph implementations.
class GraphsonDecoder  {
  
  Function _decodeState;
  Map<Object, Object> _currentProperties = {};
  Map<String, IVertex> _IDVerticeMap = {};
  String _currentID;
  IVertex _from;
  IVertex _to;
  String _label;
  
  /// Loads the json [encoded] Graphson formatted string into the supplied IGraph [g].
  /// NOTE- only supports "NORMAL" mode encoding style.
  /// 
  /// Again not an optimal solution for large graphs, some form of chunked imput
  /// would be required.
  IGraph loadGraph(String encoded, IGraph g){
    _decodeState = _graphState;
    
    new JsonDecoder((p1, p2) {
      _decodeState = _decodeState(p1, p2, g);
      return null;
    }).convert(encoded);
    
    return g;
  }
  
  Function _graphState(p1, p2, IGraph g){
    return _vertexState;
  }
  
  Function _vertexState(p1, p2, IGraph g){
    Function nextState = _vertexState;
    if(p2 is List){
      nextState = _edgeState;  
    }
    else {
      if(p2 is Map){
        IVertex v = g.addVertex(_currentProperties);
        _currentProperties = {};
        _IDVerticeMap[_currentID] = v;
      }
      else {
        if(p1 == _ID_LABEL){
          _currentID = p2;
        }
        else if(p1 != _TYPE_LABEL){
          _currentProperties[p1] = p2;
        }
      }
      
    }
    return nextState;
  }
  
  Function _edgeState(p1, p2, IGraph g){
    Function nextState = _edgeState;
    if(p2 is List){
      nextState = _endState;  
    }
    else {
      if(p2 is Map){
        g.addEdge(_from, _to, _label, _currentProperties);
        _currentProperties = {};
      }
      else {
        if(p1 == _IN_V_LABEL){
          _to = _IDVerticeMap[p2];
        }
        else if(p1 == _OUT_V_LABEL){
          _from = _IDVerticeMap[p2];
        }
        else if(p1 == _LABEL_LABEL){
          _label = p2;  
        }
        else if(p1 != _TYPE_LABEL && p1 != _ID_LABEL){
          _currentProperties[p1] = p2;
        }
      }
      
    }
    return nextState;
  }
  
  Function _endState(p1, p2, IGraph g){
    return _endState;
  }

}