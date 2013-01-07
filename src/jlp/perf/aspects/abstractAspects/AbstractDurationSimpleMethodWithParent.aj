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
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.Calendar;
import java.util.Locale;
import java.util.Properties;

public abstract aspect AbstractDurationSimpleMethodWithParent {
	private static String fileTrace = "";

	private static jlp.perf.aspects.abstractAspects.Trace outDurationMethods;
	private static double durationMini = 0;
	private static Properties props;
	private static String dirLogs,sep=";";
	
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
		if (props.containsKey("jlp.perf.aspects.abstractAspects.AbstractDurationSimpleMethodWithParent.filelogs")) {
			fileTrace =dirLogs+ props
					.getProperty("jlp.perf.aspects.abstractAspects.AbstractDurationSimpleMethodWithParent.filelogs");
		} else {
			fileTrace = props.getProperty("aspectsPerf.default.filelogs");
		}

    System.out.println("AbstractDurationSimpleMethodsWithParent fichier trace = "+fileTrace);
		outDurationMethods = new Trace("####time"+sep+"class.methodCalled"+sep+"class.methodCaller"+sep+"time called method in millisecondes(ms)\n",fileTrace);
		/*outDurationMethods
				.append(new StringBuilder(
						"####time;Class.methods;time in millisecondes\n")
						.toString());*/

		durationMini = Double.parseDouble(props
				.getProperty("jlp.perf.aspects.abstractAspects.AbstractDurationSimpleMethodWithParent.durationMini"));
	}

	// The pointcut must be a call type pointcut not an execution pointcut.
	public abstract pointcut methods();

	Object around(): methods()	 {
		
		long deb = System.nanoTime();
		Object retour = proceed();
		long fin = System.nanoTime();
		double duree= fin-deb;
		if (duree/1000000 >= this.durationMini) {
			
			
			String nameClasseMethodSource="null";
			
			String noLine="0";
			if(null!=thisJoinPointStaticPart.getSourceLocation())
			{
				noLine=Integer.toString(thisJoinPointStaticPart.getSourceLocation().getLine());
			}
			String noLine1="0";
			if(null!=thisEnclosingJoinPointStaticPart.getSourceLocation())
			{
				noLine1=Integer.toString(thisEnclosingJoinPointStaticPart.getSourceLocation().getLine());
			}

			outDurationMethods
					.append(new StringBuilder(outDurationMethods.getSdf()
							.format(Calendar.getInstance().getTime())).append(
							sep)
							.append(
									thisJoinPointStaticPart.getSignature().getDeclaringTypeName())
							.append(".").append(
									thisJoinPointStaticPart.getSignature().getName()).append("_line").
									append(noLine)
								.append(sep).append(thisEnclosingJoinPointStaticPart.getSignature().getDeclaringTypeName()).
								append(".").append(thisEnclosingJoinPointStaticPart.getSignature().getName())
								.append("_line").
									append(noLine1)
							.append(sep).append(
									df.format(((double)duree/1000000))).append("\n").toString());
			// outDurationMethods.flush();
		}
		return retour;

	}

}
