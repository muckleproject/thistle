part of thistle;

abstract class _MapObserver<K, V> {
  void removed(K key, V oldValue);
  void updated(K key, V oldValue);
  bool get isActive;
}

class _ObservableMap<K, V> extends Object with MapMixin<K, V> {
  Map<K, V> _map = new Map<K, V>();
  _MapObserver<K, V> observer;
  
  _ObservableMap(this.observer);
  
  void addSilently(Map<K, V> other){
    _map.addAll(other);
  }
  
  void clear(){
    _map.clear();
  }
  
  V remove(K key){
    V v;
    if(observer.isActive){
      if(_map.containsKey(key)){
        v = _map.remove(key); 
        observer.removed(key, v);
      }
    }
    else {
      v = _map.remove(key); 
    }
    return v;
  }
  
  Iterable<K> get keys => _map.keys;
  
  void operator []=(K key, V value){
    if(observer.isActive){
      V oldValue = _map[key];
      _map[key] = value;
      if(oldValue != value){
        observer.updated(key, oldValue);
      }
    }
    else {
      _map[key] = value;
    }
  }
  
  V operator [](Object key){
    return _map[key];
  }
}
