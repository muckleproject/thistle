part of thistle;


typedef dynamic _ElementFunction(IElement e);
typedef dynamic _PropertyChangeFunction(IElement e, String key, Object oldValue);
typedef bool _BooleanFunction();

class _ElementListenerHolder {
  static final _ElementFunction RUN_ALWAYS = (e) => true;

  _ElementFunction callback;
  _ElementFunction test;
  
  _ElementListenerHolder(this.callback){
    this.test = RUN_ALWAYS;
  }
  
  void doCallback(IElement e){
    if(test(e)){
      callback(e);
    }
  }
  
  bool callbackMatches(_ElementFunction f){
    return callback == f;
  }
}

class _EdgeElementListenerHolder extends _ElementListenerHolder implements IEdgeCondition {
  _EdgeElementListenerHolder(callback) : super(callback);
 
  void when(EdgeTest test){
    this.test = test;
  }
}

class _VertexElementListenerHolder extends _ElementListenerHolder implements IVertexCondition {
  _VertexElementListenerHolder(callback) : super(callback);
 
  void when(VertexTest test){
    this.test = test;
  }
}

class _PropertyListenerHolder {
  
  static final _PropertyChangeFunction RUN_ALWAYS = (e, k, o) => true;
  
  _PropertyChangeFunction callback;
  _PropertyChangeFunction test;
  
  _PropertyListenerHolder(this.callback){
    this.test = RUN_ALWAYS;
  }
  
  void doCallback(IElement e, String key, Object oldValue){
    if(test(e, key, oldValue)){
      callback(e, key, oldValue);
    }
  }
  
  bool callbackMatches(_PropertyChangeFunction f){
    return callback == f;
  }
}

class _EdgePropertyListenerHolder extends _PropertyListenerHolder implements IEdgePropertyCondition {
  _EdgePropertyListenerHolder(callback) : super(callback);

  void when(EdgePropertyChangeTest test){
    this.test = test;
  }
}

class _VertexPropertyListenerHolder extends _PropertyListenerHolder implements IVertexPropertyCondition {
  _VertexPropertyListenerHolder(callback) : super(callback);

  void when(VertexPropertyChangeTest test){
    this.test = test;
  }
}
