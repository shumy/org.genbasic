package org.genbasic

import java.util.LinkedList
import java.util.List
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.genbasic.context.Context

class GGenerator {
	var (EClass)=>boolean filterFunc
	
	@Property val GEngine engine
	
	@Property val EObject eRoot
	@Property val String fileExtension
	
	@Property var String prefixPackage
	
	new(GEngine engine, EObject eRoot, String fileExtension) {
		_engine = engine
		_eRoot = eRoot
		_fileExtension = fileExtension
	}
	
	def filter((EClass)=>boolean filterFunc) {
		this.filterFunc = filterFunc
		return this
	}
	
	def List<GResult> generate((EClass)=>CharSequence genFunc) {
		val results = new LinkedList<GResult>
		process(_eRoot, results, genFunc)
		return results
	}
	
	def process(EObject eRoot, List<GResult> results, (EClass)=>CharSequence genFunc) {
		if(eRoot instanceof EClass) {
			val eClass = eRoot as EClass
			if(filterFunc == null || filterFunc.apply(eClass)) {
				val GResult item = new GResult(this, eClass)
				Context::set(typeof(GResult), item)
				
				item.text = genFunc.apply(eClass).toString
				results.add(item)
			}
		} else {
			for(eNext: eRoot.eContents)
				process(eNext, results, genFunc);
		}
			
	}
}