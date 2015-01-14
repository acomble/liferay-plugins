package com.liferay.calendar.util;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.util.InfrastructureUtil;

public class SurveyUtil {
	
	protected static Log	_log	= LogFactoryUtil.getLog(SurveyUtil.class);
	
	public static boolean hasAnsweredAllQuestions(final int surveyId, final String userScreenName) {
		// Declare the JDBC objects.
		Connection con = null;
		Statement stmt = null;
		ResultSet rs = null;
		boolean allAnswered = true;
		int iterator = 0;
		
		try {
			// Establish the connection.
			con = InfrastructureUtil.getDataSource().getConnection();

			// Create and execute an SQL statement that returns some data.
			String SQL = "SELECT count(id) from user_choices where usrChoiceQuestion_fk in (select id from survey_questions where survey_fk = " + surveyId + ")  and authctoken = '" + userScreenName + "' group by usrChoiceQuestion_fk";
			stmt = con.createStatement();
			rs = stmt.executeQuery(SQL);

			// Iterate through the data in the result set and display it.
			while (rs.next()) {
				iterator++;
				final int count = rs.getInt(1);
				if (count < 1) {
					allAnswered = false;
					break;
				}
			}

			final int nbQuestionsBySurvey = getNbQuestionsBySurvey(surveyId);
			
			if (iterator == 0 || iterator < nbQuestionsBySurvey) {
				allAnswered = false;
			}
		}

		// Handle any errors that may have occurred.
		catch (Exception e) {
			_log.error(e.getMessage(), e);
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
		
		return allAnswered;
	}
	
	private static int getNbQuestionsBySurvey(final int surveyId) {
		// Declare the JDBC objects.
		Connection con = null;
		Statement stmt = null;
		ResultSet rs = null;
		int iterator = 0;

		try {
			// Establish the connection.
			con = InfrastructureUtil.getDataSource().getConnection();

			// Create and execute an SQL statement that returns some data.
			String SQL = "SELECT count(id) from survey_questions where survey_fk = " + surveyId;
			stmt = con.createStatement();
			rs = stmt.executeQuery(SQL);

			// Iterate through the data in the result set and display it.
			while (rs.next()) {
				iterator = rs.getInt(1);
			}

		}

		// Handle any errors that may have occurred.
		catch (Exception e) {
			_log.error(e.getMessage(), e);
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
		
		return iterator;
	}


	public static List<Survey> getSurveys() {

		// Declare the JDBC objects.
		Connection con = null;
		Statement stmt = null;
		ResultSet rs = null;

		final List<Survey> surveys = new ArrayList<Survey>();

		try {
			// Establish the connection.
			con = InfrastructureUtil.getDataSource().getConnection();

			// Create and execute an SQL statement that returns some data.
			String SQL = "SELECT id, name, description, status FROM surveys WHERE base = 0 ORDER BY name";
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
