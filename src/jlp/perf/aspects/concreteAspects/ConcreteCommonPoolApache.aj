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
import java.lang.reflect.InvocationTargetException;
import java.net.URL;
import java.text.DecimalFormat;
import java.util.Calendar;
import java.util.Locale;
import java.util.Properties;

import jlp.perf.aspects.abstractAspects.Trace;

aspect ConcreteCommonPoolApache {

	private static String fileTrace = "";

	private static jlp.perf.aspects.abstractAspects.Trace outConcretePoolApache;

	private static int frequenceMeasure = 1;
	private static Properties props;
	private static int nbBorrowedExamined = 0;
	
	public static int nbCurrentBorrowed = 0;
	public static int nbBorrowedMax = 0;
	public static double nbBorrowedMoy = 0;

	public static int freqCount = 0;

	// Counter 1 => moyenne size
	// Counter 2 => maximum size
	// Counter 3 => session examined

	public static DecimalFormat df;

	static URL[] tabURL = null;

	private static String dirLogs, sep = ";";
	static {
		Locale.setDefault(Locale.ENGLISH);
		df = new DecimalFormat("#####0.000");

		props = jlp.perf.aspects.abstractAspects.AspectsPerfProperties.aspectsPerfProperties;
		;

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
		if (props.containsKey("jlp.perf.aspects.concreteAspects.ConcreteCommonPoolApache.filelogs")) {
			fileTrace = dirLogs
					+ props
							.getProperty("jlp.perf.aspects.concreteAspects.ConcreteCommonPoolApache.filelogs");
		} else {
			fileTrace = props.getProperty("aspectsPerf.default.filelogs");
		}
		if (props
				.containsKey("jlp.perf.aspects.concreteAspects.ConcreteCommonPoolApache.frequenceMeasure")) {
			frequenceMeasure = Integer
					.parseInt(props
							.getProperty("jlp.perf.aspects.concreteAspects.ConcreteCommonPoolApache.frequenceMeasure"));

		}

		outConcretePoolApache = new Trace("####time" + sep + "nbBorrowedMoy"
				+ sep + "nbBorrowedMax" + sep + "nbExamined" + sep
				+ "nbCurrentBorrowed" + sep + "currentPoolSize" + sep
				+ "timeBetweenEvictionRunsMillis", fileTrace);

	}

	public final synchronized void ecrireResult(Object obj) {

		int idle = 0;
		long millis = 0;
		int nbBorrow = 0;
		try {
			nbBorrow = (Integer) obj.getClass().getMethod("getNumActive",
					(Class[]) null).invoke(obj, (Object[]) null);
			idle = (Integer) obj.getClass().getMethod("getNumIdle",
					(Class[]) null).invoke(obj, (Object[]) null);
			millis = (Long) obj.getClass().getMethod(
					"getTimeBetweenEvictionRunsMillis", (Class[]) null).invoke(
					obj, (Object[]) null);
		} catch (IllegalArgumentException e) {
			System.out.println("ConcreteCommonPoolApache :" + e.getMessage());
			return;

		} catch (SecurityException e) {
			System.out.println("AspectJ LTW => ConcreteCommonPoolApache :"
					+ e.getMessage());
			return;
		} catch (IllegalAccessException e) {
			System.out.println("AspectJ LTW => ConcreteCommonPoolApache :"
					+ e.getMessage());
			return;
		} catch (InvocationTargetException e) {
			System.out.println("AspectJ LTW => ConcreteCommonPoolApache :"
					+ e.getMessage());
			return;
		} catch (NoSuchMethodException e) {
			System.out.println("AspectJ LTW => ConcreteCommonPoolApache :"
					+ e.getMessage());
			return;
		}
		nbBorrowedMoy = (nbBorrowedMoy * nbBorrowedExamined + nbBorrow)
				/ (nbBorrowedExamined + 1);
		nbBorrowedExamined++;
		if (nbBorrowedMax < nbBorrow) {
			nbBorrowedMax = nbBorrow;
		}
		int currentPoolSize = idle + nbBorrow;

		outConcretePoolApache.append(new StringBuilder(outConcretePoolApache
				.getSdf().format(Calendar.getInstance().getTime())).append(sep)
				.append(df.format(nbBorrowedMoy)).append(sep).append(
						nbBorrowedMax).append(sep).append(nbBorrowedExamined)
				.append(sep).append(nbCurrentBorrowed).append(sep).append(
						currentPoolSize).append(sep).append(
								millis).append("\n").toString());

	}

	public final pointcut methods(): 
		 
		 execution ( public * org.apache.commons.pool..*.borrowObject(..)) ||
		  execution ( public * org.apache.commons.pool..*.returnObject(Object,..));

	after(): methods() 
	{

		synchronized (this) {

			freqCount++;

			if (freqCount >= frequenceMeasure) {

				// On trace
				freqCount = 0;

				Object obj = thisJoinPoint.getThis();
				if (null != obj)
					ecrireResult(obj);

			}
		}

	}

}
