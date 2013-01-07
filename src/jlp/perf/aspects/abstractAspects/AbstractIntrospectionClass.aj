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
import java.lang.reflect.Method;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Locale;
import java.util.Properties;

import org.aspectj.lang.reflect.MethodSignature;

public abstract aspect AbstractIntrospectionClass {
	private static String fileTrace = "";

	private static jlp.perf.aspects.abstractAspects.Trace outIntrospection;

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
		if (props.containsKey("jlp.perf.aspects.abstractAspects.AbstractIntrospectionClass.filelogs")) {
			fileTrace = dirLogs+props
					.getProperty("jlp.perf.aspects.abstractAspects.AbstractIntrospectionClass.filelogs");
		} else {
			fileTrace = props.getProperty("aspectsPerf.default.filelogs");
		}

		outIntrospection = new Trace("####time"+sep+"Class.method(args)\n",fileTrace);
	/*	outIntrospection.append(new StringBuilder(
				"####time;Class.method(args)\n").toString());*/
	}

	public abstract pointcut introspection();

	

	before(): introspection()	 {
		StringBuilder strBuff = new StringBuilder("(");
		Class[] args = null;
		Method meth = ((MethodSignature) thisJoinPoint.getStaticPart()
				.getSignature()).getMethod();
		Class[] tabClass = null;
		if (null != meth && null != (tabClass = meth.getParameterTypes())) {

			for (int i = 0, len=tabClass.length; i < len; i++) {

				if (i == 0) {
					strBuff.append(tabClass[0].getName().replaceAll(sep, ""));
				} else

					strBuff.append(",").append(
							tabClass[i].getName().replaceAll(sep, ""));
			}
		}
		strBuff.append(")");

		outIntrospection.append(new StringBuilder(outIntrospection.getSdf()
				.format(Calendar.getInstance().getTime())).append(sep).append(
				thisJoinPoint.getSignature().getDeclaringTypeName())
				.append(".").append(thisJoinPoint.getSignature().getName())
				.append(strBuff.toString()).append("\n").toString());
		/*
		 * outIntrospection.append(new
		 * StringBuilder(outIntrospection.getSdf().format(
		 * Calendar.getInstance().getTime())).append( ";").append(
		 * thisJoinPoint.getSignature().getDeclaringTypeName()).append(
		 * ".").append( thisJoinPoint.getSignature().getName())
		 * .append("\n").toString());
		 */

	}

	
}
