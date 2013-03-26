package org.genbasic.util;

import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;

public class RefTable<K, V> {
	private HashMap<K, Set<V>> table = new HashMap<K, Set<V>>();
	
	public void addRef(K key, V value) {
		Set<V> list = table.get(key);
		if(list == null) {
			list = new HashSet<V>();
			table.put(key, list);
		}
		
		list.add(value);
	}
	
	public Set<K> getKeys() {
		return table.keySet();
	}
	
	public Set<V> getRefs(K key) {
		final Set<V> list = table.get(key);
		if(list == null)
			return Collections.emptySet();
		return list;
	}
}
