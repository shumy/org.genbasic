package org.mydb;

import java.util.List;

public interface XFinder<E extends XEntity, F extends XField> {
	F[] getLoadFields();
	
	E byId(Long id);
	List<E> byExample(E example);
}
