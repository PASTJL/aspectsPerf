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

import jlp.perf.aspects.abstractAspects.*;


import java.util.Calendar;
import java.util.Locale;
import java.util.Properties;

import java.io.File;
import java.sql.Connection;
import javax.sql.DataSource;

public aspect ConcreteCountJDBCConnexions {
	
	private static int countOpenConnections=0;
	private static int countClosedConnections=0;
	private static int freqLogs =0;
	private static int maxFreqLogs=1;
	private static String fileTrace = "";
	private static Trace outCounterJDBCConnexions;
	
	
	private static Properties props;
	private static String dirLogs,sep=";";
	static {
		Locale.setDefault(Locale.ENGLISH);
		props = jlp.perf.aspects.abstractAspects.AspectsPerfProperties.aspectsPerfProperties;
		if(props.containsKey("aspectsPerf.default.sep"))
		{
			sep=props.
			getProperty("aspectsPerf.default.sep");
		}
		
		if(props.containsKey("aspectsPerf.default.dirLogs"))
		{
			dirLogs = props.
		getProperty("aspectsPerf.default.dirLogs");
			if(!dirLogs.endsWith(File.separator))
			{
				dirLogs+=File.separator;
			}
		}
		else
		{
			dirLogs = "";
		}
		System.out.println("Creation aspect ConcreteCounterJDBCConnexions ");
		if (props.containsKey("jlp.perf.aspects.concreteAspects.ConcreteCountJDBCConnexions.filelogs")) {
			fileTrace =dirLogs+ props
					.getProperty("jlp.perf.aspects.concreteAspects.ConcreteCountJDBCConnexions.filelogs");
		} else {
			fileTrace = props.getProperty("aspectsPerf.default.filelogs");
		}
		maxFreqLogs = Integer.parseInt(props
				.getProperty("jlp.perf.aspects.concreteAspects.ConcreteCountJDBCConnexions.freqLogs","-1"));
		outCounterJDBCConnexions = new Trace("####time"+sep+"method"+sep+"nb JDBC Connections created"+sep+"nb JDBC busy Connections"+sep+"nb Closed Connections \n",fileTrace);
	/*	outCounterJDBCConnexions
				.append(new StringBuilder(
						"####time;method;nb JDBC Connections created;nb JDBC busy Connections; nb Closed Connections \n")
						.toString());*/

	}

	
	// Ouverture des connexions 
	/**
	 * A call to establish a connection using a <code>DataSource</code>
	 */
	public final pointcut dataSourceConnectionCall(DataSource dataSource) : 
        call(java.sql.Connection+ DataSource.getConnection(..)) 
          && target(dataSource);

	/** A call to establish a connection using a URL string */
	public final pointcut directConnectionCall(String url) :
    (call(java.sql.Connection+ Driver.connect(..))  || call(java.sql.Connection+ 
      DriverManager.getConnection(..))) && 
    args(url, ..);

	/**
	 * A database connection call nested beneath another one (common with
	 * proxies).
	 */
	public final pointcut nestedConnectionCall() : 
    cflowbelow(dataSourceConnectionCall(*) || 
      directConnectionCall(*));
	
	
	// Fermeture des connexions :
	public final pointcut closeConnection(): call (public * *..sql..Connection+.close(..));
	
	after()  returning ( Connection con)  : dataSourceConnectionCall(*) || directConnectionCall(*)
	 {
		if(maxFreqLogs <0){
		synchronized (ConcreteCountJDBCConnexions.this)
		{
			countOpenConnections++;
			
			freqLogs++;
			if(freqLogs > maxFreqLogs)
			{
				// on ecrit
				outCounterJDBCConnexions
				.append(new StringBuilder(outCounterJDBCConnexions.getSdf()
						.format(Calendar.getInstance().getTime())).append(
						sep).append(
								thisJoinPoint.getSignature()
								.getDeclaringTypeName())
				.append(".").append(
						thisJoinPoint.getSignature().getName()).append(sep).append(Integer.toString(countOpenConnections)).
						append(sep).append(Integer.toString(countOpenConnections-countClosedConnections))
						.append(sep).append(Integer.toString(countClosedConnections)).append("\n").toString());
				
				freqLogs=0;
			}
		}
		}
			
	}
	after():closeConnection()
	{
		if(maxFreqLogs <0){
	
		synchronized (ConcreteCountJDBCConnexions.this)
		{
			countClosedConnections++;
			freqLogs++;
			if(freqLogs > maxFreqLogs)
			{
				// on ecrit
				outCounterJDBCConnexions
				.append(new StringBuilder(outCounterJDBCConnexions.getSdf()
						.format(Calendar.getInstance().getTime())).append(
						sep).append(
								thisJoinPoint.getSignature()
								.getDeclaringTypeName())
				.append(".").append(
						thisJoinPoint.getSignature().getName()).append(
						sep).append(Integer.toString(countOpenConnections)).
						append(sep).append(Integer.toString(countOpenConnections-countClosedConnections))
						.append(sep).append(Integer.toString(countClosedConnections)).append("\n").toString());
				
				freqLogs=0;
			}
		}
	}
	}
	
	
	
	
	

}
