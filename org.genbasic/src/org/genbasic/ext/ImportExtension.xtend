package org.genbasic.ext

import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.genbasic.util.RefTable

class ImportExtension {
	extension val UtilExtension utilExt = new UtilExtension
	
	val imports = new RefTable<EClass, String>
	
	def imports(EClass eClass) '''
		«FOR type: imports.getRefs(eClass)»
			import «type»;
		«ENDFOR»
	'''
	
	def void addImport(EClass eClass, String type) {
		imports.addRef(eClass, type)
	}
	
	def void addImport(EClass eClass, Class type) {
		imports.addRef(eClass, type.name)
	}
	
	def void addImport(EClass eClass, EClassifier eType) {
		if(eType instanceof EClass) {
			if(!eClass.EPackage.equals(eType.EPackage)) {
				val eClassType = eType as EClass
				addImport(eClass, eClassType.packages.sep('.') + '.' + eClassType.name)
			}
		} else {
			if(!eType.instanceClass.primitive)
				addImport(eClass, eType.instanceClass)
		}
	}
}