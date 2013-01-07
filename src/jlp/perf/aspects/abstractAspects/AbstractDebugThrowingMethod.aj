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
import java.util.Calendar;
import java.util.Locale;
import java.util.Properties;

public abstract aspect AbstractDebugThrowingMethod {
	private static String fileTrace = "";

	private static jlp.perf.aspects.abstractAspects.Trace outDebugMethods;
	private static String dirLogs,sep=";";
	private static Properties props;
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
		if (props.containsKey("jlp.perf.aspects.abstractAspects.AbstractDebugThrowingMethod.filelogs")) {
			fileTrace = dirLogs+props
					.getProperty("jlp.perf.aspects.abstractAspects.AbstractDebugThrowingMethod.filelogs");
		} else {
			fileTrace = props.getProperty("aspectsPerf.default.filelogs");
		}

    System.out.println("AbstractDebugThrowingMethods fichier trace = "+fileTrace);
    outDebugMethods = new Trace("####time"+sep+"Class.methods"+sep+"exception or return",fileTrace);
		/*outDurationMethods
				.append(new StringBuilder(
						"####time;Class.methods;time in millisecondes\n")
						.toString());*/

		
	}
	//public abstract pointcut scope();
	public abstract pointcut retour();
	public  abstract pointcut throwingException();
	
	after() returning(): retour()	 {

			outDebugMethods
					.append(new StringBuilder(outDebugMethods.getSdf()
							.format(Calendar.getInstance().getTime())).append(
							sep)
							.append(
									thisJoinPoint.getSignature()
											.getDeclaringTypeName())
							.append(".").append(
									thisJoinPoint.getSignature().getName())
							.append(sep).append(
									"retour OK").append("\n").toString());
			// outDurationMethods.flush();
		

	}
	after() throwing (Throwable t) : throwingException()	 {
		String erreur="Exception";
		if (null!=t.getMessage())
		{
			erreur=new StringBuilder(t.getClass().getName()).append(" ").append(t.getMessage().replaceAll("\\n"," ")).toString();
		}
		else
		{
			erreur=t.getClass().getName();
		}
		outDebugMethods
				.append(new StringBuilder(outDebugMethods.getSdf()
						.format(Calendar.getInstance().getTime())).append(
						sep)
						.append(
								thisJoinPoint.getSignature()
										.getDeclaringTypeName())
						.append(".").append(
								thisJoinPoint.getSignature().getName())
						.append(sep).append(
								"retour KO exception : ")
								.append(erreur)
								.append("\n").toString());
		// outDurationMethods.flush();
	

}
}
