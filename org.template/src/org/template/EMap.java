package org.template;

import java.util.HashMap;
import java.util.Iterator;

public class EMap implements Iterable<String> {
	final ENode parent;
	final HashMap<String, String> values = new HashMap<String, String>();
	
	EMap(ENode parent) {this.parent = parent;}
	
	public EMap set(String key, String value) {
		//TODO: fire listener...
		values.put(key, value);
		return this;
	}
	
	public EMap unset(String key) {
		//TODO: fire listener...
		values.remove(key);
		return this;
	}
	
	public String get(String key) {
		return values.get(key);
	}
	
	@Override
	public Iterator<String> iterator() {
		return values.keySet().iterator();
	}
}
