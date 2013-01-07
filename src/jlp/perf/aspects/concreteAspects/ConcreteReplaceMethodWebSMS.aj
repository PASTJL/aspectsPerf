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
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.Calendar;
import java.util.Locale;
import java.util.Properties;

import jlp.perf.aspects.abstractAspects.Trace;
public privileged aspect ConcreteReplaceMethodWebSMS {
	private static String fileTrace = "";

	private static jlp.perf.aspects.abstractAspects.Trace outDurationMethods;
	private static double sleepTime = 0;
	private static Properties props;
	private static String dirLogs,sep=";";
	private static boolean traceEnabled=false;
	private static DecimalFormat df=new DecimalFormat("#0.000",new  DecimalFormatSymbols(Locale.ENGLISH));
	private static DecimalFormat dfPercent=new DecimalFormat("#0.0",new DecimalFormatSymbols(Locale.ENGLISH));
	
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
		if (props.containsKey("jlp.perf.aspects.concreteAspects.ConcreteReplaceMethodWebSMS.filelogs")) {
			fileTrace = dirLogs+props
					.getProperty("jlp.perf.aspects.concreteAspects.ConcreteReplaceMethodWebSMS.filelogs");
		} else {
			fileTrace = props.getProperty("aspectsPerf.default.filelogs");
		}
		traceEnabled=Boolean.parseBoolean(props
		.getProperty("jlp.perf.aspects.concreteAspects.ConcreteReplaceMethodWebSMS.traceEnabled","false"))
		;
  
    
	if (traceEnabled)
	{
		System.out.println("ConcreteReplaceMethodWebSMS fichier trace = "+fileTrace);
    outDurationMethods = new Trace("####time"+sep+"Duration in millisecondes\n",fileTrace);
	}
		/*outDurationMethods
				.append(new StringBuilder(
						"####time;Class.methods;time in millisecondes\n")
						.toString());*/

		sleepTime = Double.parseDouble(props
				.getProperty("jlp.perf.aspects.concreteAspects.ConcreteReplaceMethodWebSMS.sleepTime","0"));
	}

	// Put it pointcut for Method to replace
	//pointcut methods(): call(String com.btsl.channel.service.impl.PushMesssage.pushGatewayMessage(..));
	
	
//	public final pointcut methods(Runnable r): execution (void myPackage.AThread.run(..)) && this(r);
	//public final pointcut methods(Runnable r): call (void myPackage.AThread.run(..)) && target(r);
	//pointcut methods(): call(void myPackage.AThread.run(..));
	//public final pointcut methods(): execution(void com.btsl.channel.service.impl.PushMesssage.run()) ;
	public final pointcut methods(): execution(void com.btsl.channel.service.impl.PushMesssage.sendSMSMessage*(..)) ;
	Object around(): methods()	 {

		long deb =System.nanoTime();
		
		Object retour =null;
		try {
			Thread.sleep((long) this.sleepTime);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		///Object retour = proceed();
		
		// put here the modification of the method
		
		long fin = System.nanoTime();
		double duree= fin-deb;
		
		

			if(traceEnabled)
			{
			
			outDurationMethods
					.append(new StringBuilder(outDurationMethods.getSdf()
							.format(Calendar.getInstance().getTime())).append(
							sep)
							.append(
									df.format(duree/1000000)).append("\n").toString());
			
			
			// outDurationMethods.flush();
			}
		return new String("200") ;
		//	return null;
	}

}
