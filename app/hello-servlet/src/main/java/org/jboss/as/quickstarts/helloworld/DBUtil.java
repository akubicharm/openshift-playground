package org.jboss.as.quickstarts.helloworld;


import java.util.Properties;

import java.sql.DriverManager;
import java.sql.Connection;
import java.sql.SQLException;

public class DBUtil {
	
	private String dbHost;
	private String dbPort;
	private String dbName;
	private String dbUser;
	private String dbPassword;
	
	private static DBUtil me;
	
	
	private DBUtil() {
		getEnvVal();
	}
	

	
	private void getEnvVal() {
		dbHost = System.getenv("DB_HOST");
		dbPort = System.getenv("DB_PORT");
		dbName = System.getenv("DB_NAME");
		dbUser = System.getenv("DB_USER");
		dbPassword = System.getenv("DB_PASSWORD");
	}
	
	
	public static DBUtil getInstance() {
		if (me == null) {
			me = new DBUtil();
		}
		return me;
	}
	
	public Connection getConnection() throws SQLException {
		Connection conn = null;

		StringBuilder sb = new StringBuilder();
		sb.append("jdbc:mysql://").append(dbHost).append(":").append(dbPort).append("/").append(dbName);
		Properties props = new Properties();
		props.put("user", dbUser);
		props.put("password", dbPassword);
		
		conn = DriverManager.getConnection(sb.toString(), props);
		
		return conn;
	}

}
