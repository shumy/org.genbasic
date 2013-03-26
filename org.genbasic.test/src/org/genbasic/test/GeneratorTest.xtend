package org.genbasic.test

import org.genbasic.db.EntityGenerator
import org.genbasic.db.TableGenerator
import org.genbasic.GEngine
import org.genbasic.db.EntityImplGenerator
import org.genbasic.GResult
import java.util.List

class GeneratorTest {
	static val engine = new GEngine('gen-src', 'UTF-8')
	
	def static void main(String[] args) {
		genEntities
		
		genEntitiesImpl(genTables)
	}
	
	def static genEntities() {
		val entityGen = new EntityGenerator(engine)
		
		val entityResults = entityGen.generate('model/Entity.ecore')
		entityResults.forEach[createFile.write(text)]
	}
	
	def static genTables() {
		val tableGen = new TableGenerator(engine, 'postgres')
		tableGen.linkPackage = 'link'
				
		val tableResults = tableGen.generate('model/Entity.ecore')
		val file = engine.createFile('db.sql')
		tableResults.forEach[file.write(text)]
		return tableResults
	}
	
	def static genEntitiesImpl(List<GResult> tableResults) {
		val entityImplGen = new EntityImplGenerator(engine, 'impl', tableResults)
		
		val entityResults = entityImplGen.generate('model/Entity.ecore')
		entityResults.forEach[createFile.write(text)]
	}
}