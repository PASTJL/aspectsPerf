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
//import jlp.exemple1.*;
import java.io.File;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Locale;
import java.util.Properties;


public abstract aspect  AbstractCounterAllInstancesWithParent {
	private int countInstance=0;
	private static String fileTrace="";
	private static jlp.perf.aspects.abstractAspects.Trace outCounterInstances;
	private static HashMap<String,Object> listClass= new HashMap<String,Object>();
	private static Properties props;
	private static String dirLogs,sep=";";
static
	{
	Locale.setDefault(Locale.ENGLISH);
	props= jlp.perf.aspects.abstractAspects.AspectsPerfProperties.aspectsPerfProperties;
	if(props.containsKey("aspectsPerf.default.sep"))
	{
		sep=props.
		getProperty("aspectsPerf.default.sep");
	}
	System.out.println("Creation aspect AbstractCounterAllInstancesWithParent ");
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
		if(props.containsKey("jlp.perf.aspects.abstractAspects.AbstractCounterAllInstancesWithParent.filelogs"))
		{
		fileTrace =dirLogs+ props.
		getProperty("jlp.perf.aspects.abstractAspects.AbstractCounterAllInstancesWithParent.filelogs");
		}
		else
		{
			fileTrace = props.
			getProperty("aspectsPerf.default.filelogs");
		}
		
			outCounterInstances
			   = new Trace("####time"+sep+"nb Instances created"+sep+"name of class;name of Parent"+sep+"num of line\n",fileTrace);
			//outCounterInstances.append(new StringBuilder("####time;nb Instances created;name of class;name of Parent;num of line\n").toString());
			
			
		
	}


	
		
		public abstract pointcut  constructeur();
		
		private final synchronized void add(String key)
		{
			Integer integ=((Integer)listClass.get((String) key));
			integ=new Integer(integ.intValue()+1);
			listClass.put((String)key,(Integer)integ);
		}
		private final synchronized void increment()
		{
			countInstance++;
		}
	
      before() : constructeur() {
		
    	  synchronized(this) {
    		  increment();
		String nameClasse="null";
		if (null==thisJoinPoint.getSourceLocation().getFileName())
		{
			nameClasse="null";
		}
		else
		{
			StringBuilder strBuff=new StringBuilder(thisJoinPoint.getSourceLocation().getWithinType().getName());
			nameClasse=strBuff.append(";").append(thisJoinPoint.getSourceLocation().getLine()).toString();
		}
		/*outCounterInstances.append(new StringBuilder(outCounterInstances.getSdf().
				format(Calendar.getInstance().getTime())).append( 
				";").append(countInstance).append(";").append(thisJoinPoint.getSignature().getDeclaringTypeName()).
				append(".").append(thisJoinPoint.getSignature().getName()).append(";")
				.append(nameClasse).append("\n").toString());*/
		
		outCounterInstances.append(new StringBuilder(outCounterInstances.getSdf().
				format(Calendar.getInstance().getTime())).append( 
				sep).append(countInstance).append(sep)
				.append(thisJoinPoint.getSignature().getDeclaringTypeName())
				.append(sep)
				.append(nameClasse).append("\n").toString());
	}
      }
	
}
