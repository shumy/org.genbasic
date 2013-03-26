package org.mydb.jdbc;

import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

public class XResult implements Iterable<XRecord> {
	
	private final LinkedList<String> columns = new LinkedList<String>();
	private final LinkedList<XRecord> records = new LinkedList<XRecord>();
	
	XResult(final ResultSet set) {
		try {
			final ResultSetMetaData meta = set.getMetaData();
			int count = meta.getColumnCount();
			for(int i=1; i<=count; i++)
				columns.add(meta.getColumnName(i));
			
			long rIndex = 0;
			while(set.next()) {
				final Object[] values = new Object[count];
				for(int i=1; i<=count; i++)
					values[i-1] = set.getObject(i);

				final XRecord record = new XRecord(rIndex, values);
				records.add(record);
				rIndex++;
			}
			
		} catch (SQLException e) {
			throw new RuntimeException(e);
		}
	}
	
	public List<String> columns() {
		return columns;
	}
	
	public int size() {
		return records.size();
	}
	
	public XRecord getFirst() {
		return records.getFirst();
	}
	
	@Override
	public Iterator<XRecord> iterator() {
		return records.iterator();
	}
	
	@Override
	public String toString() {
		final StringBuilder sb = new StringBuilder("i [");
		int i = 0;
		for(final String name: columns) {
			sb.append(name); i++;
			if(i < columns.size()) sb.append(", ");
		}
		sb.append("]\n----------------------------------------------------------------------------------------------------------------------");
		for(final XRecord record: records) {
			sb.append("\n");
			sb.append(record);
		}
		
		return sb.toString();
	}
}

