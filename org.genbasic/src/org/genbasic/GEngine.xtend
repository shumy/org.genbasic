package org.genbasic

import org.genbasic.GFile
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.xmi.impl.EcoreResourceFactoryImpl
import org.eclipse.emf.ecore.resource.ResourceSet
import java.io.File
import java.io.IOException

class GEngine {
	val ResourceSet rsSet
	
	@Property val String genPath
	@Property val String encoding
	
	new(String genPath, String encoding) {
		_genPath = genPath
		_encoding = encoding
		
		val reg = Resource$Factory$Registry::INSTANCE
		val map = reg.extensionToFactoryMap
		map.put('ecore', new EcoreResourceFactoryImpl)
		
		rsSet = new ResourceSetImpl
	}
	
	def GGenerator generator(String model, String fileExtension) {
		val rs = rsSet.getResource(URI::createURI(model), true)
		new GGenerator(this, rs.contents.get(0), fileExtension)
	}
	
	def createFile(String path) {
		val fullPath = _genPath + '/' + path
		println('''CREATE-FILE: «fullPath»''')
		try {
			val file = new File(fullPath)
			file.parentFile.mkdirs
			
			if(file.exists)
				file.delete
			
			file.createNewFile
			return new GFile(this, file)
		} catch(IOException e) {
			throw new RuntimeException(e.message)
		}
	}
}