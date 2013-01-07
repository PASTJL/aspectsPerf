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

public abstract aspect AbstractNbCallMethod {
	private static String fileTrace = "";

	private static jlp.perf.aspects.abstractAspects.Trace outNbCallMethods;

	private static Properties props;
	private static String dirLogs, sep = ";";
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
		if (props.containsKey("jlp.perf.aspects.abstractAspects.AbstractNbCallMethod.filelogs")) {
			fileTrace = dirLogs
					+ props.getProperty("jlp.perf.aspects.abstractAspects.AbstractNbCallMethod.filelogs");
		} else {
			fileTrace = props.getProperty("aspectsPerf.default.filelogs");
		}

		outNbCallMethods = new Trace("####time" + sep
				+ "Class.methods with  Arguments\n", fileTrace);
		// outDurationMethods
		// .append(new StringBuilder(
		// "####time;Class.methods with  Arguments;time in millisecondes\n")
		// .toString());

	}

	public abstract pointcut methods();

	before(): methods()	 
	{

		

		
		String noLine = "0";
		if (null != thisJoinPointStaticPart.getSourceLocation()) {
			noLine = Integer.toString(thisJoinPointStaticPart
					.getSourceLocation().getLine());
		}

		outNbCallMethods.append(new StringBuilder(outNbCallMethods.getSdf()
				.format(Calendar.getInstance().getTime())).append(sep)
				.append(thisJoinPointStaticPart.getSignature().getDeclaringTypeName())
				.append(".").append(thisJoinPointStaticPart.getSignature().getName())
				.append("_line_").append(noLine).append("\n").toString());

	}

}
