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

public abstract aspect  AbstractCounterInstances {
	private static String fileTrace = "";
	private static jlp.perf.aspects.abstractAspects.Trace outCounterInstances;
	private static HashMap<String,Object> listClass = new HashMap<String,Object>();
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
		if (props
				.containsKey("jlp.perf.aspects.abstractAspects.AbstractCounterInstances.filelogs")) {
			fileTrace = dirLogs
					+ props.getProperty("jlp.perf.aspects.abstractAspects.AbstractCounterInstances.filelogs");
		} else {
			fileTrace = props.getProperty("aspectsPerf.default.filelogs");
		}

		outCounterInstances = new Trace("####time" + sep + "nb Created Ojbects"
				+ sep + "Name of Object\n", fileTrace);
		// outCounterInstances.append(new
		// StringBuilder("####time;nb Created Ojbects;Name of Object\n").toString());
		initialise();

	}

	private static void initialise() {

		if (props
				.containsKey("jlp.perf.aspects.abstractAspects.AbstractCounterInstances.class_list")) {
			String[] tabString = props
					.getProperty(
							"jlp.perf.aspects.abstractAspects.AbstractCounterInstances.class_list")
					.split(";");
			for (int i = 0, len = tabString.length; i < len; i++) {
				listClass.put(tabString[i], new Integer(0));
			}

		}

	}

	public abstract pointcut constructeur();

	private final synchronized void add(String key) {

		Integer integ = ((Integer) listClass.get((String) key));
		integ = new Integer(integ.intValue() + 1);
		listClass.put((String) key, (Integer) integ);

	}

	before() : constructeur()
		{

		if (listClass.containsKey((String) thisJoinPoint.getSignature()
				.getDeclaringTypeName())) {
			synchronized (this) {
				add(thisJoinPoint.getSignature().getDeclaringTypeName());
				StringBuilder buff = new StringBuilder(outCounterInstances
						.getSdf().format(Calendar.getInstance().getTime()))
						.append(sep)
						.append(listClass.get(
								(String) thisJoinPoint.getSignature()
										.getDeclaringTypeName()).toString())
						.append(sep)
						.append(thisJoinPoint.getSignature()
								.getDeclaringTypeName()).append("\n");

				outCounterInstances.append(buff.toString());
			}
			// outCounterInstances.flush();
		}

	}

}
