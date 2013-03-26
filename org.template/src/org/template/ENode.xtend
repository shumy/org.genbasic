package org.template;

class ENode{
	ENode parent
	
	@Property val String id = ""
	@Property val String name
	
	@Property val attributes = new EMap(this)
	@Property val childs = new EList(this)
	
	new(String name) {
		_name = name
	}

	def render() '''
		<«name»«IF id != ''» id="«id»"«ENDIF» «FOR key: attributes SEPARATOR ' '»«key»="«attributes.get(key)»"«ENDFOR»>«IF childs.empty»</«name»>«ELSE»
			«FOR child: childs»«child.render»«ENDFOR»
		</«name»>«ENDIF»
	'''
}
