package com.liferay.calendar.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class SurveyUtil {

	public static List<Survey> getSurveys() {

		// Create a variable for the connection string.
		String connectionUrl = "jdbc:sqlserver://slwtcb1:1433;" + "databaseName=administrateur;user=liferay;password=Y2j*Pa0R";

		// Declare the JDBC objects.
		Connection con = null;
		Statement stmt = null;
		ResultSet rs = null;

		final List<Survey> surveys = new ArrayList<Survey>();

		try {
			// Establish the connection.
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
			con = DriverManager.getConnection(connectionUrl);

			// Create and execute an SQL statement that returns some data.
			String SQL = "SELECT id, name, description, status FROM surveys WHERE base = 0";
			stmt = con.createStatement();
			rs = stmt.executeQuery(SQL);

			// Iterate through the data in the result set and display it.
			while (rs.next()) {
				// rs.getString(1) = id
				// rs.getString(2) = name
				// rs.getString(3) = description
				final Survey survey = new Survey(rs.getLong(1), rs.getString(2), rs.getString(3));
				surveys.add(survey);
			}
		}

		// Handle any errors that may have occurred.
		catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (rs != null) {
				try {
					rs.close();
				} catch (Exception e) {
				}
			}
			if (stmt != null) {
				try {
					stmt.close();
				} catch (Exception e) {
				}
			}
			if (con != null) {
				try {
					con.close();
				} catch (Exception e) {
				}
			}
		}
		return surveys;
	}
}
