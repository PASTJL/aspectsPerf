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
package jlp.perf.aspects.abstractAspects;

//import jlp.perf.aspects.abstractAspects.AbstractPoolDBCPCountJDBCConnexionsMultiDS.StructWeakRef;

import java.io.File;
import java.lang.ref.WeakReference;
import java.lang.reflect.InvocationTargetException;
import java.util.Calendar;
import java.util.Locale;
import java.util.Properties;

public abstract aspect AbstractPoolTomcatDBCPCountJDBCConnexions {
	
	
	private static int freqLogs =0;
	private static int maxFreqLogs=1;
	private static String fileTrace = "";
	private static Trace outCounterJDBCConnexions;
	private static Properties props;
	public static WeakReference dsRef =null;
	public static String url="";
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
		System.out.println("[Aspect Instrumentation AbstractPoolTomcatDBCPCountJDBCConnexions] Creation aspect AbstractPoolTomcatDBCPCountJDBCConnexions ");
		if (props.containsKey("jlp.perf.aspects.abstractAspects.AbstractPoolTomcatDBCPCountJDBCConnexions.filelogs")) {
			fileTrace =dirLogs+ props
					.getProperty("jlp.perf.aspects.abstractAspects.AbstractPoolTomcatDBCPCountJDBCConnexions.filelogs");
		} else {
			fileTrace = props.getProperty("aspectsPerf.default.filelogs");
		}
			if (props.containsKey("jlp.perf.aspects.abstractAspects.AbstractPoolTomcatDBCPCountJDBCConnexions.url")) {
			url = props
					.getProperty("jlp.perf.aspects.abstractAspects.AbstractPoolTomcatDBCPCountJDBCConnexions.url");
		} 
		maxFreqLogs = Integer.parseInt(props
				.getProperty("jlp.perf.aspects.abstractAspects.AbstractPoolTomcatDBCPCountJDBCConnexions.freqLogs","1"));
		outCounterJDBCConnexions = new Trace("####time"+sep+"url"+sep+"nb JDBC Connections Idle"+sep+"nb JDBC busy Connections"+sep+"maxConn"+sep+"InitialSize"+sep+"MaxIdle"+sep+"MaxPreparedStatement \n",fileTrace);
		/*
		 * outCounterJDBCConnexions .append(new StringBuilder( "####time;nb JDBC
		 * Connections Idle;nb JDBC busy Connections; maxConn \n") .toString());
		 */

	}
	public final  pointcut creationDatasource(): within(org.apache.tomcat.dbcp.dbcp..*) && 
	( execution(public  org.apache.tomcat.dbcp.dbcp.BasicDataSource.new()) 
			|| execution(private * org.apache.tomcat.dbcp.dbcp.BasicDataSource.createDataSource(..))) ;
	 public abstract pointcut validateConnexion();

	
	// Ouverture des connexions
	/**
	 * A call to establish a connection using a <code>DataSource</code>
	 */
	
   

	//
	// Fermeture des connexions :
	
     Object around(): creationDatasource()
 	{
 		synchronized (AbstractPoolTomcatDBCPCountJDBCConnexions.this)
 		{
 	Object obj=proceed();
 	
dsRef= new WeakReference(thisJoinPoint.getThis());

 	 System.out.println( "[Aspect Instrumentation AbstractPoolTomcatDBCPCountJDBCConnexions] DS interceptee dans aspect");
 	// System.out.println (" Url = "+((org.apache.tomcat.dbcp.dbcp.BasicDataSource )this.dsRef.get()).getUrl());
 	 return obj;
 	 }
   }
	
     before () : validateConnexion()
	 {
		synchronized (AbstractPoolTomcatDBCPCountJDBCConnexions.this)
		{
		
		
		
			freqLogs++;
			// System.out.println("ValidationConnection entree freqlogs = "+
			// freqLogs);
			if(freqLogs > maxFreqLogs)
			{
				
				// on ecrit
				
				try {
				int idle= (Integer) this.dsRef.get().getClass().getMethod("getNumIdle",null).invoke(this.dsRef.get(), null);
				int active= (Integer) this.dsRef.get().getClass().getMethod("getNumActive",null).invoke(this.dsRef.get(), null);
				int initial=(Integer) this.dsRef.get().getClass().getMethod("getInitialSize",null).invoke(this.dsRef.get(), null);
				int	maxConn=(Integer) this.dsRef.get().getClass().getMethod("getMaxActive",null).invoke(this.dsRef.get(), null);
				// System.out.println("idle = "+idle+" ; active = "+active);
				int maxIdle= (Integer) this.dsRef.get().getClass().getMethod("getMaxIdle",null).invoke(this.dsRef.get(), null);
				int maxPreparedStatement= (Integer) this.dsRef.get().getClass().getMethod("getMaxOpenPreparedStatements",null).invoke(this.dsRef.get(), null);
				String url="null";
				if (null!= this.dsRef.get().getClass().getMethod("getUrl",null).invoke(this.dsRef.get(), null))
				{
			url = (String)   this.dsRef.get().getClass().getMethod("getUrl",null).invoke(this.dsRef.get(), null);
				}
		// System.out.println("idle = "+idle+" ; active = "+active);
	
				
				
				outCounterJDBCConnexions
		.append(new StringBuilder(outCounterJDBCConnexions.getSdf()
				.format(Calendar.getInstance().getTime())).append(
				sep).append(url).append(sep).append(Integer.toString(idle)).
				append(sep).append(Integer.toString(active))
					.append(sep).append(Integer.toString(maxConn))
					.append(sep).append(Integer.toString(maxConn))
					.append(sep).append(Integer.toString(initial))
					.append(sep).append(Integer.toString(maxIdle))
					.append(sep).append(Integer.toString( maxPreparedStatement))
					.append("\n").toString());
				freqLogs=0;
				
				} catch (IllegalArgumentException e2) {
					// TODO Auto-generated catch block
					e2.printStackTrace();
				} catch (SecurityException e2) {
					// TODO Auto-generated catch block
					e2.printStackTrace();
				} catch (IllegalAccessException e2) {
					// TODO Auto-generated catch block
					e2.printStackTrace();
				} catch (InvocationTargetException e2) {
					// TODO Auto-generated catch block
					e2.printStackTrace();
				} catch (NoSuchMethodException e2) {
					// TODO Auto-generated catch block
					e2.printStackTrace();
				}
						}
			}
		
			
	}
	
	class StructWeakRef {
	public String nameDS="";
	public WeakReference dsRef =null;
	
	public StructWeakRef(String _nameDS, WeakReference _dsRef)
	{
		nameDS=_nameDS;
		dsRef=_dsRef;
		
	}
	
	
	}
	
	
	

}
