package org.genbasic.context;

import java.util.HashMap;
import java.util.Map;

public class ContextData {
	private final Map<Class<?>, Object> values = new HashMap<Class<?>, Object>();
	
	@SuppressWarnings("unchecked")
	public <T> T get(Class<T> clazz) {
		return (T) values.get(clazz);
	}
	
	public <C, T extends C> void set(Class<C> clazz, T value) {
		values.put(clazz, value);
	}
}
