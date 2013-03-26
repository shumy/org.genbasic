package org.genbasic.context;

public class Context {
	private static final ThreadLocal<ContextData> contextData = new ThreadLocal<ContextData>() {
		@Override
		protected ContextData initialValue() {return new ContextData();}
	};
	
	public static ContextData getData() {return contextData.get();}
	public static void setData(ContextData data) {contextData.set(data);}
	
	
	public static <T> T get(Class<T> clazz) {
		return contextData.get().get(clazz);
	}
	
	public static <C, T extends C> void set(Class<C> clazz, T value) {
		contextData.get().set(clazz, value);
	}
	
}
