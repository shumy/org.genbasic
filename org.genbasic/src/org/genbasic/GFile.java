package org.genbasic;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;

import org.genbasic.GEngine;

public class GFile {
	final GEngine engine;
	final File file;

	public GFile(GEngine engine, File file) {
		this.engine = engine;
		this.file = file;
	}
	
	public void write(String text) {
		try(OutputStreamWriter osw = new OutputStreamWriter(new FileOutputStream(file, true), engine.getEncoding())) {
			osw.write(text);
		} catch(IOException e) {
			throw new RuntimeException(e.getMessage());
		}
	}
}
