package org.genbasic.ext

import java.util.LinkedList
import java.util.List
import org.eclipse.emf.ecore.EClass
import org.genbasic.util.RefTable

class UtilExtension {
	val fieldNames = new RefTable<EClass, String>
	
	def addFieldName(EClass eClass, String name) {
		fieldNames.addRef(eClass, name)
		return name
	}
	
	def fieldNames(EClass eClass) {
		fieldNames.getRefs(eClass)
	}
	
	def sep(List<String> seq, String separator) '''
		«FOR p: seq SEPARATOR separator»«p»«ENDFOR»'''
	
	def packagesWithoutNamespace(EClass eClass) {
		val packList = new LinkedList<String>
		
		var pack = eClass.EPackage
		while(pack != null) {
			packList.addFirst(pack.name)
			pack = pack.ESuperPackage
		}
		
		return packList
	}
	
	def packages(EClass eClass) {
		val packList = eClass.packagesWithoutNamespace
		
		val pack = eClass.EPackage
		val split = pack.nsPrefix.split('\\.')
		for(String p: split)
			packList.addFirst(p)

		return packList
	}
}