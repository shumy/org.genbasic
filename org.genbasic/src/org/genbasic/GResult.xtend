package org.genbasic

import org.eclipse.emf.ecore.EClass
import org.genbasic.ext.UtilExtension
import java.util.Map
import java.util.HashMap

class GResult {
	extension val UtilExtension utilExt = new UtilExtension
	
	@Property val GGenerator generator
	
	@Property val EClass item
	@Property var String text
	@Property var String fileName
	
	@Property val Map<String, Object> tags = new HashMap
	
	new(GGenerator generator, EClass item) {
		_generator = generator
		_item = item
		
		println('''GENERATION-OF: «item.eClass.name»(«item.name»)''')
	}
	
	def replace(String regex, CharSequence replacement) {
		text = text.replace(regex, replacement)
	}
	
	def createFile(){
		val path = '''«item.packages.sep('/')»/«IF fileName != null»«fileName»«ELSE»«item.name»«ENDIF».«generator.fileExtension»'''.toString
		generator.engine.createFile(path)
	}
	
	override toString() '''
		GResult(«item.name»)
		«text»
	'''
}