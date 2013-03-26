package org.template;

import java.util.Iterator;
import java.util.LinkedHashSet;

public class EList implements Iterable<ENode> {
	final ENode parent;
	final LinkedHashSet<ENode> elements = new LinkedHashSet <ENode>();

	EList(ENode parent) {this.parent = parent;}
	
	public EList add(ENode node) {
		//TODO: fire listener...
		elements.add(node);
		return this;
	}
	
	public EList remove(ENode node) {
		//TODO: fire listener...
		elements.remove(node);
		return this;
	}
	
	@Override
	public Iterator<ENode> iterator() {
		return elements.iterator();
	}
	
}
