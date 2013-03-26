package org.genbasic.ext

import org.genbasic.context.Context
import org.genbasic.GResult

class TagExtension {
	def <T> addTag(String key, T value) {
		val GResult result = Context::get(typeof(GResult))
		result.tags.put(key, value)
		return value
	}
}