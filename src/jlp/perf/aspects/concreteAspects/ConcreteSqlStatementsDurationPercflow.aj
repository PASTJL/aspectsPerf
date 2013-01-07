/*Copyright 2012 Jean-Louis PASTUREL 
*
*   Licensed under the Apache License, Version 2.0 (the "License");
*  you may not use this file except in compliance with the License.
*  You may obtain a copy of the License at
*
*       http://www.apache.org/licenses/LICENSE-2.0
*
*   Unless required by applicable law or agreed to in writing, software
*  distributed under the License is distributed on an "AS IS" BASIS,
*   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*   See the License for the specific language governing permissions and
*  limitations under the License.
*/
package jlp.perf.aspects.concreteAspects;

import java.io.File;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.Calendar;
import java.util.Locale;
import java.util.Properties;
import java.util.WeakHashMap;

import jlp.perf.aspects.abstractAspects.Trace;

public aspect ConcreteSqlStatementsDurationPercflow percflow ( callCreatePreparedStatement(String )
		|| statementExec(PreparedStatement)  ) {

	private int countConnexions = 0;
	private static String fileTrace = "";
	private static boolean stripBeforeWhereBool = false;
	private static int longMaxReq = 0;
	private final static Trace outSqlStatementDurations;
	private static double durationMini = 0;
	private static Properties props;
	private static long rank = 0;
	static long debWithSql = 0;
	static long debWithoutSql = 0;
	private String sqlStr = "";
	private static WeakHashMap<Statement, String> statementSql = new WeakHashMap<Statement, String>();
	private static String dirLogs, sep = ";";
	private static DecimalFormat df = new DecimalFormat("#0.000",
			new DecimalFormatSymbols(Locale.ENGLISH));
	private static DecimalFormat dfPercent = new DecimalFormat("#0.0",
			new DecimalFormatSymbols(Locale.ENGLISH));

	private static boolean boolBindParameters = true;
	static {
		Locale.setDefault(Locale.ENGLISH);
		props = jlp.perf.aspects.abstractAspects.AspectsPerfProperties.aspectsPerfProperties;
		if (props.containsKey("aspectsPerf.default.sep")) {
			sep = props.getProperty("aspectsPerf.default.sep");
		}

		if (props.containsKey("aspectsPerf.default.dirLogs")) {
			dirLogs = props.getProperty("aspectsPerf.default.dirLogs");
			if (!dirLogs.endsWith(File.separator)) {
				dirLogs += File.separator;
			}
		} else {
			dirLogs = "";
		}
		System.out.println("Creation aspect ConcreteSqlStatementsDuration ");
		if (props
				.containsKey("jlp.perf.aspects.concreteAspects.ConcreteSqlStatementsDurationPercflow.filelogs")) {
			fileTrace = dirLogs
					+ props.getProperty("jlp.perf.aspects.concreteAspects.ConcreteSqlStatementsDurationPercflow.filelogs");
		} else {
			fileTrace = props.getProperty("aspectsPerf.default.filelogs");
		}
		durationMini = Double
				.parseDouble(props
						.getProperty("jlp.perf.aspects.concreteAspects.ConcreteSqlStatementsDurationPercflow.durationMini"));
		if (props
				.containsKey("jlp.perf.aspects.concreteAspects.ConcreteSqlStatementsDurationPercflow.stripBeforeWhereBool")) {
			if (props
					.getProperty(
							"jlp.perf.aspects.concreteAspects.ConcreteSqlStatementsDurationPercflow.stripBeforeWhereBool")
					.equals("true"))

			{
				stripBeforeWhereBool = true;
			}
		}
		if (props
				.containsKey("jlp.perf.aspects.concreteAspects.ConcreteSqlStatementsDurationPercflow.longMaxReq")) {
			longMaxReq = Integer
					.parseInt(props
							.getProperty("jlp.perf.aspects.concreteAspects.ConcreteSqlStatementsDurationPercflow.longMaxReq"));
		}
		boolBindParameters = Boolean
				.parseBoolean(props
						.getProperty(
								"jlp.perf.aspects.concreteAspects.ConcreteSqlStatementsDurationPercflow.boolBindParameters",
								"true"));

		outSqlStatementDurations = new Trace("####time" + sep + "typeStatement"
				+ sep + "SQL" + sep + "rank" + sep + "duree(ms)\n", fileTrace);
		// outSqlStatementDurations.append(new
		// StringBuilder("####time;typeStatement;SQL;rank;duree \n").toString());
	}

	/** Matches any execution of a JDBC statement */

	public pointcut statementExec(PreparedStatement statement) : execution(public * *..PreparedStatement.execute*(..))
    && target(statement)  ;

	/**
	 * Call to create a Statement.
	 * 
	 * @param connection
	 *            the connection called to create the statement, which is bound
	 *            to track the statement's origin
	 */
	/*
	 * public pointcut callCreateStatement(Connection connection):
	 * call(Statement+ Connection.*(..)) && target(connection);
	 */

	/**
	 * A call to prepare a statement.
	 * 
	 * @param sql
	 *            The SQL string prepared by the statement.
	 */
	public pointcut callCreatePreparedStatement(String sql):
        execution(PreparedStatement Connection.prepare*(String, ..)) 
          && args(sql, ..);

	after(String sql) returning (PreparedStatement statement):
    	callCreatePreparedStatement( sql)
    	{
		synchronized (ConcreteSqlStatementsDurationPercflow.this) {
			if (!statementSql.containsKey(statement) && null != sql
					&& sql.trim().length() > 1)
				statementSql.put(statement, sql);

		}
	}

	before(Statement statement):  statementExec(statement)      
   
   // Object around( Statement statement, String sql):  statementExecWithSQL(statement,sql)  
    {
		if (null == statement)
			return;
		if (statementSql.containsKey(statement)) {
			if (boolBindParameters) {
				// sqlStr=statementSql.get(statement);
				sqlStr = statement.toString();
			} else {
				sqlStr = statementSql.get(statement);
			}
		} else {
			return;
		}
		debWithSql = System.nanoTime();
	}

	after(Statement statement):  statementExec(statement)  
  {
		if (null == statement)
			return;
		long fin = System.nanoTime();
		double duree = fin - debWithSql;
		synchronized (ConcreteSqlStatementsDurationPercflow.this) {
			if (!statementSql.containsKey(statement)) {
				return;
			}
			rank++;

			if (duree / 1000000 >= durationMini) {

				if (stripBeforeWhereBool) {
					sqlStr = stripAfterWhere(sqlStr);
				}

				// String
				// sql=stripAfterWhere((String)statementSql.get(statement));
				if (longMaxReq > 0 && sqlStr.length() > longMaxReq) {
					sqlStr = sqlStr.substring(0, longMaxReq);
				}
				// Suppression des sauts de lignes eventuels
				sqlStr = sqlStr.replaceAll("\\r*\\n+\\r*", " | ");
				outSqlStatementDurations.append(new StringBuilder(
						outSqlStatementDurations.getSdf().format(
								Calendar.getInstance().getTime()))
						.append(sep)
						.append(thisJoinPoint.getSignature().toShortString())
						.append(sep)
						.append(thisJoinPoint.getThis().getClass()
								.getSimpleName()).append(" : ").append(sqlStr)
						.append(sep).append(Long.toString(rank)).append(sep)
						.append(df.format(duree / 1000000)).append("\n")
						.toString());
			}

		}
	}

	/**
	 * To group sensibly and to avoid recording sensitive data, I don't record
	 * the where clause (only used for dynamic SQL since parameters aren't
	 * included in prepared statements)
	 * 
	 * @return subset of passed SQL up to the where clause
	 */
	public static String stripAfterWhere(String sql) {
		for (int i = 0; i < sql.length() - 4; i++) {
			if (sql.charAt(i) == 'w' || sql.charAt(i) == 'W') {
				if (sql.substring(i + 1, i + 5).equalsIgnoreCase("here")) {
					sql = sql.substring(0, i);
				}
			}
		}
		return sql;
	}

	//
	// private Map statementFabric=new WeakIdentityHashMap();

}
