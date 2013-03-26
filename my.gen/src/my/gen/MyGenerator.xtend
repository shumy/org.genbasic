package my.gen

import org.genbasic.GEngine

class MyGenerator {
	def static void main(String[] args) {
		val engine = new GEngine('gen-src', 'UTF-8')
		
		val javaGen = new JavaEntityGenerator(engine)
		javaGen.generate('model/My.ecore').forEach[
			println(it)
			//createFile
		]
	}
}