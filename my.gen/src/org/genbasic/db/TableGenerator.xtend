package org.genbasic.db

import java.util.HashMap

import org.genbasic.IGenerator
import org.genbasic.util.RefTable
import org.genbasic.ext.UtilExtension

import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EcoreFactory
import org.genbasic.GEngine
import org.genbasic.GResult
import org.genbasic.ext.TagExtension

class TableGenerator implements IGenerator {
	extension val UtilExtension utilExt = new UtilExtension
	extension val TagExtension tagExt = new TagExtension
	
	var uKey = 0
	
	val invRefs = new RefTable<EClass, EReference>
	val sqlTypes = new HashMap<String, String>
	
	val GEngine engine
	val String owner
	
	@Property var String schema
	@Property var String linkPackage
	
	new(GEngine engine, String owner) {
		this.engine = engine
		this.owner = owner
		
		sqlTypes.put('EString', 'character varying')
		sqlTypes.put('EDate', 'timestamp with time zone')
		sqlTypes.put('EInt', 'integer')
		sqlTypes.put('ELong', 'bigint')
		sqlTypes.put('EFloat', 'real')
		sqlTypes.put('EDouble', 'double precision')
	}
	
	def tableName(EClass eClass) {
		(eClass.packagesWithoutNamespace.sep('_') + '_' + eClass.name).toLowerCase
	}
	
	def type(EAttribute eAttrib) {
		return sqlTypes.get(eAttrib.EType.name)
	}
	
	def unique(EClass eClass) '''
		«FOR an: eClass.EAnnotations»
			«IF an.source == 'unique'»
				CONSTRAINT u_«eClass.tableName»_«uKey = uKey + 1» UNIQUE («FOR ref: an.references SEPARATOR ', '»«IF ref instanceof EAttribute»f_«(ref as EAttribute).name»«ELSE»«IF ref instanceof EReference»r_«(ref as EAttribute).name»«ENDIF»«ENDIF»«ENDFOR»),
			«ENDIF»
		«ENDFOR»
	'''
	
	def invRefs(EClass eClass) '''
		«FOR ir: invRefs.getRefs(eClass)»
			ir_«ir.name» bigint NOT NULL,
		«ENDFOR»
	'''
	
	def void processInvRef(EClass eClass, EReference eRef) {
		if(eRef.EOpposite == null || eRef.EOpposite.upperBound != 1 && !invRefs.getRefs(eRef.EType as EClass).contains(eRef.EOpposite)) {
			//one-to-many without inv-ref || many-to-many
			invRefs.addRef(eClass, eRef)
		}
	}
	
	def _validSchema() '''«IF schema != null»«schema».«ENDIF»'''
		
	override generate(String modelPath) {
		uKey = 0
		
		val gen = engine.generator(modelPath, 'sql')
		val results = gen.filter[!interface].generate['''
			CREATE TABLE «addTag('tableName', _validSchema + tableName)» (
				id serial NOT NULL,
				«FOR a: EAllAttributes»
					f_«a.name» «a.type»«IF a.required» NOT NULL«ENDIF»,
				«ENDFOR»
				«FOR r: EAllReferences»
					«IF r.upperBound == 1»
						r_«r.name» bigint«IF r.required» NOT NULL«ENDIF»,
					«ELSE»
						«processInvRef(r)»
					«ENDIF»
				«ENDFOR»
				
				«FOR r: EAllReferences»
					«IF r.upperBound == 1»
						CONSTRAINT fk_«tableName»_«r.name» FOREIGN KEY (r_«r.name») REFERENCES «_validSchema»«(r.EType as EClass).tableName» (id),
					«ENDIF»
				«ENDFOR»
				«FOR st: ESuperTypes»
					«st.unique»
				«ENDFOR»
				«unique»
				CONSTRAINT pk_«tableName» PRIMARY KEY (id)
			);
			ALTER TABLE «_validSchema»«tableName» OWNER TO «owner»;
			
		''']
		
		//process link tables----------------------------------------------------------------------------------------------------
		for(eClass: invRefs.keys) {
			for(eRef: invRefs.getRefs(eClass)) {
				val linkClass = EcoreFactory::eINSTANCE.createEClass
				linkClass.name = eClass.name + eRef.EType.name
				linkClass.abstract = true;
				
				val ref1 = eClass.name.toLowerCase
				val ref2 = eRef.EType.name.toLowerCase
				
				val linkName = '''«IF linkPackage != null»«linkPackage»_«ENDIF»«linkClass.name.toLowerCase»'''
				val linkResult = new GResult(gen, linkClass)
				linkResult.text = '''
					CREATE TABLE «_validSchema»«linkName» (
						r_«ref1» bigint NOT NULL,
						r_«ref2» bigint NOT NULL,
						
						CONSTRAINT fk_«linkName»_«ref1» FOREIGN KEY (r_«ref1») REFERENCES «_validSchema»«eClass.tableName» (id),
						CONSTRAINT fk_«linkName»_«ref2» FOREIGN KEY (r_«ref2») REFERENCES «_validSchema»«(eRef.EType as EClass).tableName» (id),
						CONSTRAINT pk_«linkName» PRIMARY KEY (r_«ref1», r_«ref2»)
					);
					ALTER TABLE «_validSchema»«linkName» OWNER TO «owner»;
					
				'''
				
				results.add(linkResult)
			}
		}
		
		return results
	}	
}