package org.mydb.jdbc;

public class SQLFactory {

	public static String insert(final String dbTableName, final String ...dbFieldNames) {
		final StringBuilder sb = new StringBuilder("INSERT INTO ");
		sb.append(dbTableName); 
		sb.append("(");
		
		int i1 = 1;
		for(final String field: dbFieldNames) {
			sb.append(field);
			if(i1<dbFieldNames.length) sb.append(", ");
			i1++;
		}
		
		sb.append(") VALUES(?");	//the ID field is always present, so lenght is always >=1
		for(int i2=0; i2<dbFieldNames.length-1; i2++)
			sb.append(", ?");
		sb.append(")");
		
		return sb.toString();
	}
	
	public static String update(final String dbTableName, final String ...dbFieldNames) {
		final StringBuilder sb = new StringBuilder("UPDATE ");
		sb.append(dbTableName);
		
		int i = 1;
		for(final String field: dbFieldNames) {
			sb.append(" SET ");
			sb.append(field);
			sb.append("=?");

			if(i<dbFieldNames.length) sb.append(",");
			i++;
		}
		sb.append(" WHERE id=?");
		
		return sb.toString();
	}
	
	public static String delete() {
		return null;
	}
	
}

