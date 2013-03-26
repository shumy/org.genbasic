package org.template.test

import org.template.ENode

class Test {
	def static void main(String[] args) {
		val row1 = new ENode('div')
		row1.attributes.set('class', 'span4')
		
		val row2 = new ENode('div')
		row2.attributes.set('class', 'span4 offset2')
		
		val table = new ENode('div')
		table.attributes.set('class', 'row-fluid')
		table.childs.add(row1)
		table.childs.add(row2)
		
		//TODO: extensions !!
		
		println(table.render)
	}	
}