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

import java.io.File;
import java.lang.ref.WeakReference;
import java.lang.reflect.InvocationTargetException;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Locale;
import java.util.Properties;
import java.util.Set;
import java.util.Map.Entry;

public abstract aspect AbstractPoolDBCPCountJDBCConnexionsMultiDS {
	
	private static int countDS=0;
	private static int freqLogs =0;
	private static int maxFreqLogs=1;
	private static String fileTrace = "";
	private static Trace outCounterJDBCConnexions;
	private static Properties props;
	public static HashMap hmWeakStruc=new HashMap();
	public static WeakReference tmpDsRef =null;
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
		System.out.println("[Aspect Instrumentation AbstractPoolDBCPCountJDBCConnexionsMultiDS] Creation aspect AbstractPoolDBCPCountJDBCConnexionsMultiDS ");
		if (props.containsKey("jlp.perf.aspects.abstractAspects.AbstractPoolDBCPCountJDBCConnexionsMultiDS.filelogs")) {
			fileTrace = props
					.getProperty("jlp.perf.aspects.abstractAspects.AbstractPoolDBCPCountJDBCConnexionsMultiDS.filelogs");
		} else {
			fileTrace = dirLogs+props.getProperty("aspectsPerf.default.filelogs");
		}
			if (props.containsKey("jlp.perf.aspects.abstractAspects.AbstractPoolDBCPCountJDBCConnexionsMultiDS.url")) {
			url = props
					.getProperty("jlp.perf.aspects.abstractAspects.AbstractPoolDBCPCountJDBCConnexionsMultiDS.url");
		} 
		maxFreqLogs = Integer.parseInt(props
				.getProperty("jlp.perf.aspects.abstractAspects.AbstractPoolDBCPCountJDBCConnexionsMultiDS.freqLogs"));
		outCounterJDBCConnexions = new Trace("####time"+sep+"DataSource"+sep+"url"+sep+"nb JDBC Connections Idle"+sep+"nb JDBC busy Connections"+sep+"maxConn"+sep+"InitialSize"+sep+"MaxIdle"+sep+"MaxPreparedStatement \n",fileTrace);
		/*
		 * outCounterJDBCConnexions .append(new StringBuilder( "####time;nb JDBC
		 * Connections Idle;nb JDBC busy Connections; maxConn \n") .toString());
		 */

	}
	public final pointcut creationDatasource(): within(org.apache.commons.dbcp..*) && ( execution(public  org.apache.commons.dbcp.BasicDataSource.new()) || execution(private * org.apache.commons.dbcp.BasicDataSource.createDataSource(..))) ;
	 public abstract pointcut validateConnexion();

	
	// Ouverture des connexions
	/**
	 * A call to establish a connection using a <code>DataSource</code>
	 */
	
   

	
	//
	// Fermeture des connexions :
	
     Object around(): creationDatasource()
 	{
 		synchronized (AbstractPoolDBCPCountJDBCConnexionsMultiDS.this)
 		{
 	Object obj=proceed();
 	
 	tmpDsRef= new WeakReference(thisJoinPoint.getThis());
 	Set set=hmWeakStruc.entrySet();
 	Iterator it=set.iterator();
 	boolean trouve=false;
 	while (it.hasNext())
 	{
 		Entry entry=(Entry)it.next();
 		StructWeakRef swr= (StructWeakRef) entry.getValue();
 		if(tmpDsRef==swr.dsRef)
 		{
 			trouve=true;
 			break;
 		}
 	}
 	if (!trouve)
 	{
 		StructWeakRef swr=new StructWeakRef("DS_"+Integer.toString(countDS),tmpDsRef);
 		hmWeakStruc.put("DS_"+Integer.toString(countDS), swr);
 		 System.out.println( "[Aspect Instrumentation AbstractPoolDBCPCountJDBCConnexionsMultiDS] DS_"+Integer.toString(countDS)+" interceptee dans aspect");
 		countDS++;
 	}
 	tmpDsRef=null;
 	

 	
 	// System.out.println (" Url = "+((org.apache.commons.dbcp.BasicDataSource )this.dsRef.get()).getUrl());
 	 return obj;
 	 }
   }
	
     before () : validateConnexion()
	 {
		synchronized (AbstractPoolDBCPCountJDBCConnexionsMultiDS.this)
		{
		
		
		
			freqLogs++;
			// System.out.println("ValidationConnection entree freqlogs = "+
			// freqLogs);
			if(freqLogs > maxFreqLogs)
			{
				try {

				// on ecrit pour toutes les ds recencées
				for ( int i=0; i< countDS;i++)
				{
					WeakReference dsRefTmp2=((StructWeakRef)hmWeakStruc.get("DS_"+Integer.toString(i))).dsRef;
					
				int idle= (Integer) dsRefTmp2.get().getClass().getMethod("getNumIdle",null).invoke(dsRefTmp2.get(), null);
				
				int active= (Integer) dsRefTmp2.get().getClass().getMethod("getNumActive",null).invoke(dsRefTmp2.get(), null);
				int	maxConn= (Integer) dsRefTmp2.get().getClass().getMethod("getMaxActive",null).invoke(dsRefTmp2.get(), null);
				int initial=(Integer) dsRefTmp2.get().getClass().getMethod("getInitialSize",null).invoke(dsRefTmp2.get(), null);
				int maxIdle= (Integer) dsRefTmp2.get().getClass().getMethod("getMaxIdle",null).invoke(dsRefTmp2.get(), null);
				int maxPreparedStatement= (Integer) dsRefTmp2.get().getClass().getMethod("getMaxOpenPreparedStatements",null).invoke(dsRefTmp2.get(), null);
				String url="null";
				if (null!=  dsRefTmp2.get().getClass().getMethod("getUrl",null).invoke(dsRefTmp2.get(), null))
						{
					url =  (String)dsRefTmp2.get().getClass().getMethod("getUrl",null).invoke(dsRefTmp2.get(), null);
						}
				// System.out.println("idle = "+idle+" ; active = "+active);
				outCounterJDBCConnexions
				.append(new StringBuilder(outCounterJDBCConnexions.getSdf()
						.format(Calendar.getInstance().getTime())).append(
						sep).append("DS_").append(Integer.toString(i)).
						append(sep).append(url).append(sep).append(Integer.toString(idle)).
						append(";").append(Integer.toString(active))
							.append(sep).append(Integer.toString(maxConn))
							.append(sep).append(Integer.toString(maxConn))
							.append(sep).append(Integer.toString(initial))
							.append(sep).append(Integer.toString(maxIdle))
							.append(sep).append(Integer.toString( maxPreparedStatement))
							.append("\n").toString());
				}
				
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
				
				
				freqLogs=0;
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
