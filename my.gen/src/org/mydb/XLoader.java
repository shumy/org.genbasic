package org.mydb;

@SuppressWarnings("unchecked")
public interface XLoader<E extends XEntity, F extends XField, Fi extends XFinder<E, F>> {
	E create();
	
	Fi find();
	Fi find(F ...loadFields);
}
