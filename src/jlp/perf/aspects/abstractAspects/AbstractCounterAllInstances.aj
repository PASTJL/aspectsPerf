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



public abstract aspect  AbstractCounterAllInstances {
	private int countInstance=0;
	private static String fileTrace="";
	private static jlp.perf.aspects.abstractAspects.Trace outCounterInstances;
	private static Properties props;
	private static String dirLogs;
	public static String sep=";";
	
static
	{
	props=  jlp.perf.aspects.abstractAspects.AspectsPerfProperties.aspectsPerfProperties;
	Locale.setDefault(Locale.ENGLISH);
	System.out.println("Creation aspect AbstractCounterAllInstances ");
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
		if(props.containsKey("jlp.perf.aspects.abstractAspects.AbstractCounterAllInstances.filelogs"))
		{
		fileTrace =dirLogs+ props.
		getProperty("jlp.perf.aspects.abstractAspects.AbstractCounterAllInstances.filelogs");
		}
		else
		{
			fileTrace = props.
			getProperty("aspectsPerf.default.filelogs");
		}
		
			outCounterInstances
			   = new Trace("####time"+sep+"nb Instances created"+sep+"name of class\n",fileTrace);
			//outCounterInstances.append(new StringBuilder("####time;nb Instances created;name of class\n").toString());
			
			
		
	}


	
		
		public abstract pointcut  constructeur();
		

		
		private final synchronized void increment()
		{
			countInstance++;
		}
      before() : constructeur() {
		
		
		synchronized(this)
		{
			increment();
		outCounterInstances.append(new StringBuilder(outCounterInstances.getSdf().format(Calendar.getInstance().getTime())).append( 
				sep).append(countInstance).append(sep).append(thisJoinPoint.getSignature().getDeclaringTypeName()).
				append(".").append(thisJoinPoint.getSignature().getName()).append("\n").toString());
		}
		
	}
	
	
}
