package org.genbasic

import java.util.List;

interface IGenerator {
	def List<GResult> generate(String modelPath)
}