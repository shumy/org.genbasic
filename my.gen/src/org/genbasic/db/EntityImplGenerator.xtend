package org.genbasic.db

import org.genbasic.IGenerator
import org.genbasic.ext.UtilExtension
import org.genbasic.ext.ImportExtension

import java.util.List
import java.util.Set
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EAttribute
import org.mydb.XLoader
import org.genbasic.GEngine
import java.util.HashMap
import org.mydb.jdbc.XConnection
import org.mydb.jdbc.XResult
import org.genbasic.context.Context
import org.genbasic.GResult
import org.eclipse.emf.ecore.EClass

class EntityImplGenerator implements IGenerator {
	extension val UtilExtension utilExt = new UtilExtension
	extension val ImportExtension importExt = new ImportExtension
	
	val GEngine engine
	val String implPackage
	
	val tables = new HashMap<EClass, String>
	
	new(GEngine engine, String implPackage, List<GResult> tableResults) {
		this.engine = engine
		this.implPackage = implPackage
		
		for(r: tableResults)
			tables.put(r.item, r.tags.get('tableName') as String)
			
	}
	
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
		gen.prefixPackage = implPackage
		
		val results = gen.filter[!interface].generate['''
			package «packages.sep('.')»;
			
			«addImport(typeof(List))»
			«addImport(typeof(HashMap))»
			«addImport(typeof(Context))»
			«addImport(typeof(XConnection))»
			«addImport(typeof(XResult))»
			«addImport(typeof(XLoader))»
			<IMPORTS>
			@SuppressWarnings({"rawtypes", "unchecked"})
			public class «name»Impl implements E«name» {
				Long id;
			
				final HashMap<EField, Object> values = new HashMap<EField, Object>();
			
				@Override 
				public <T> T get(EField<T> field) {return (T)values.get(field);}
			
				@Override 
				public <T> E«name» set(EField<T> field, T value) {
					values.put(field, value); 
					return this;
				}

				/*----------get/set----------*/
				@Override
				public Long getId() {return id;}
				
				«FOR a: EAllAttributes SEPARATOR '\n'»«addImport(a.EType)»
					@Override 
					public «a.type» get«a.name.toFirstUpper»() {return get(«addFieldName('F_' + a.name.toUpperCase)»);}
					«IF a.changeable»
						@Override 
						public void set«a.name.toFirstUpper»(«a.type» «a.name») {set(«'F_' + a.name.toUpperCase», «a.name»);}
					«ENDIF»
				«ENDFOR»

				//------------------------------------------------------------------------------------------------------------
				public static class Loader implements XLoader<E«name», EField<?>, IFinder> {
					static final IFinder defaultFinder = new Finder(ID«FOR f: fieldNames», «f»«ENDFOR»);
				
					@Override 
					public E«name» create() {return new «name»Impl();}
				
					@Override 
					public IFinder find() {return defaultFinder;}
				
					@Override 
					public IFinder find(EField<?> ...loadFields) {return new Finder(loadFields);}
				}
			
				public static class Finder implements IFinder {
					final String idQuery, exampleQuery;
					
					final EField<?>[] loadFields;
				
					Finder(EField<?> ...loadFields) {
						this.loadFields = loadFields;
						idQuery = "SELECT * FROM «tables.get(it)» WHERE id = ?";
					}
				
					@Override 
					public EField<?>[] getLoadFields() {return loadFields;}
				
					@Override
					public E«name» byId(Long id) {
						final XConnection con = Context.get(XConnection.class);
						final XResult result = con.select(idQuery, id);
						return null;
					}
				
					@Override
					public List<E«name»> byExample(E«name» example) {
						//TODO: sql query !
						return null;
					}
				}
			}
		''']
		
		results.forEach[
			fileName = item.name + 'Impl'
			replace('<IMPORTS>', item.imports)
		]
		return results
	}
}