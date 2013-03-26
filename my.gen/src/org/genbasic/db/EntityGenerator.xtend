package org.genbasic.db

import org.genbasic.IGenerator
import org.genbasic.ext.UtilExtension
import org.genbasic.ext.ImportExtension

import java.util.List
import java.util.Set
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EAttribute
import org.mydb.XEntity
import org.mydb.XField
import org.mydb.XFinder
import org.mydb.XLoader
import org.genbasic.GEngine

class EntityGenerator implements IGenerator {
	extension val UtilExtension utilExt = new UtilExtension
	extension val ImportExtension importExt = new ImportExtension
	
	val GEngine engine
	new(GEngine engine) {this.engine = engine}
	
	def type(EAttribute eAttrib) {
		val splits = eAttrib.EType.instanceTypeName.split('\\.')
		var typeName = splits.get(splits.size-1)
		if(typeName == 'int') 
			typeName = 'Integer'
		else
			typeName = typeName.toFirstUpper
		return typeName
	}
	
	def type(EReference eRef) {
		val clazz = eRef.EType.name
		if(eRef.upperBound != 1) {
			if(eRef.ordered) {
				eRef.EContainingClass.addImport(typeof(List))
				return 'List<'+clazz+'>'
			} else {
				eRef.EContainingClass.addImport(typeof(Set))
				return 'Set<'+clazz+'>'
			}
		} else
			return clazz
	}
		
	override generate(String modelPath) {
		val gen = engine.generator(modelPath, 'java')
		
		val eResults = gen.filter[!interface].generate['''
			package «packages.sep('.')»;
			
			«addImport(typeof(XEntity))»
			«addImport(typeof(XField))»
			«addImport(typeof(XFinder))»
			«addImport(typeof(XLoader))»
			<IMPORTS>
			public interface E«name» extends XEntity«FOR st: ESuperTypes», «st.name»«addImport(st)»«ENDFOR» {
				class EField<T> extends XField {
					EField(Class<T> type, String name) {super(type, name);}
				}
				
				EField<Long> ID = new EField<Long>(Long.class, "id");
				«FOR a: EAllAttributes»
					EField<«a.type»> «addFieldName('F_' + a.name.toUpperCase)» = new EField<«a.type»>(«a.type».class, "«a.name»");«addImport(a.EType)»
				«ENDFOR»
				
				EField<?>[] FIELDS = new EField<?>[]{ID«FOR f: fieldNames», «f»«ENDFOR»};
				
				<T> T get(EField<T> field);
				<T> E«name» set(EField<T> field, T value);
				
				/*----------get/set----------*/
				«FOR a: EAttributes SEPARATOR '\n'»
					«a.type» get«a.name.toFirstUpper»();
					«IF a.changeable»
						void set«a.name.toFirstUpper»(«a.type» «a.name»);
					«ENDIF»
				«ENDFOR»
				
				//------------------------------------------------------------------------------------------------------------
				XLoader<E«name», EField<?>, IFinder> $ = new «name»Impl.Loader();
				
				interface IFinder extends XFinder<E«name», EField<?>>{
					//TODO: find operators
				}
			}
		''']
		
		eResults.forEach[
			fileName = 'E' + item.name
			replace('<IMPORTS>', item.imports)
		]
		
		val iResults = gen.filter[interface].generate['''
			package «packages.sep('.')»;
			
			<IMPORTS>
			public interface «name» «IF !ESuperTypes.empty»extends «FOR st: ESuperTypes SEPARATOR ', '»«st.name»«addImport(st)»«ENDFOR» «ENDIF»{
				«FOR a: EAttributes SEPARATOR '\n'»«addImport(a.EType)»
					«a.type» get«a.name.toFirstUpper»();
					«IF a.changeable»
						void set«a.name.toFirstUpper»(«a.type» «a.name»);
					«ENDIF»
				«ENDFOR»
			}
		''']
		
		iResults.forEach[
			replace('<IMPORTS>', item.imports)
		]
		
		eResults.addAll(iResults)
		return eResults
	}
}