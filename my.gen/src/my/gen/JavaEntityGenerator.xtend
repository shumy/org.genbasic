package my.gen

import org.genbasic.IGenerator
import org.genbasic.ext.UtilExtension
import org.genbasic.ext.ImportExtension

import java.util.List
import java.util.Set
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EAttribute
import org.genbasic.GEngine

class JavaEntityGenerator implements IGenerator {
	extension val UtilExtension utilExt = new UtilExtension
	extension val ImportExtension importExt = new ImportExtension
	
	val GEngine engine
	
	new(GEngine engine) {this.engine = engine}
		
	def type(EAttribute eAttrib) {
		val splits = eAttrib.EType.instanceTypeName.split('\\.')
		splits.get(splits.size-1)
	}
	
	def type(EReference eRef) {
		val clazz = eRef.EType.name
		if(eRef.upperBound == 1) {
			if(eRef.ordered) {
				eRef.EContainingClass.addImport(typeof(List))
				return 'List<'+clazz+'>'
			} else {
				eRef.EContainingClass.addImport(typeof(Set))
				return 'Set<'+clazz+'>'
			}
		} else {
			//TODO: ref in help table	
		}
	}
	
	def inheritance(EClass eClass) '''
		«IF !eClass.ESuperTypes.empty»implements «FOR c: eClass.ESuperTypes SEPARATOR ', '»«c.name»«eClass.addImport(c)»«ENDFOR» «ENDIF»'''
	
	def ref(EClass eClass, EReference eRef) '''
		«eRef.type» «eRef.name»;«eClass.addImport(eRef.EType)»
	'''
	
	def field(EClass eClass, EAttribute eAttrib) '''
		«eAttrib.type» «eAttrib.name»;«eClass.addImport(eAttrib.EType)»
	'''
	
	def fieldGet(EAttribute eAttrib, boolean isInterface, boolean isOverride) '''
		«IF isOverride»@Override «ENDIF»«IF !isInterface»public «ENDIF»«eAttrib.type» get«eAttrib.name.toFirstUpper»()«IF isInterface»;«ELSE» {return this.«eAttrib.name»;}«ENDIF»
	'''
	
	def fieldSet(EAttribute eAttrib, boolean isInterface, boolean isOverride) '''
		«IF isOverride»@Override «ENDIF»«IF !isInterface»public «ENDIF»void set«eAttrib.name.toFirstUpper»(«eAttrib.type» «eAttrib.name»)«IF isInterface»;«ELSE» {this.«eAttrib.name» = «eAttrib.name»;}«ENDIF»
	'''
	
	def allFields(EClass eClass) '''
		«FOR a: eClass.EAttributes»
			«eClass.field(a)»
		«ENDFOR»
	'''
	
	def allRefs(EClass eClass) '''
		«FOR r: eClass.EReferences»
			«eClass.ref(r)»
		«ENDFOR»
	'''
	
	def allAccessors(EClass eClass, boolean isInterface, boolean isOverride) '''
		«FOR a: eClass.EAttributes SEPARATOR '\n'»
			«fieldGet(a, isInterface, isOverride)»
			«IF a.changeable»
				«fieldSet(a, isInterface, isOverride)»
			«ENDIF»
		«ENDFOR»
	'''
	
	override generate(String modelPath) {
		val gen = engine.generator(modelPath, 'java')
		val results = gen.generate['''
			package «packages.sep('.')»;
			
			<IMPORTS>
			public «IF interface»interface«ELSE»class«ENDIF» «name» «inheritance»{
				«IF !interface»
					«FOR st: ESuperTypes»
						«st.allFields»
					«ENDFOR»
					
					«allFields»
					
					/*----------references----------*/
					«FOR st: ESuperTypes»
						«st.allRefs»
					«ENDFOR»
					«allRefs»
				«ENDIF»
			
				/*----------get/set----------*/
				«IF interface»
					«allAccessors(true, false)»
				«ELSE»
					«FOR st: ESuperTypes»
						«st.allAccessors(false, true)»
					«ENDFOR»
					
					«allAccessors(false, false)»
				«ENDIF»
			}
		''']
		
		results.forEach[replace('<IMPORTS>', item.imports)]
		return results
	}
}