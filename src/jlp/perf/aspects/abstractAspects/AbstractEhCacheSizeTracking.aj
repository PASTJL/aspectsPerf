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
import java.lang.reflect.InvocationTargetException;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Locale;
import java.util.Properties;

import org.aspectj.lang.JoinPoint;

import jlp.perf.aspects.abstractAspects.Trace;

public privileged abstract aspect AbstractEhCacheSizeTracking {
	private static String fileTrace = "";
	private static long nbElementInMemory = 0;
	private static long sizeInByteInMemory = -1;
	private static long nbElementInDisk = 0;
	private static String nameOfCache = "";
	private static long hitCount = 0;
	private static long timeDeb = System.currentTimeMillis();
	private static boolean computeSizesInBytesEnabled = true;
	private static HashMap<String, Long> hmCounter = new HashMap<String, Long>();
	

	private static long compteur = 0;

	private static jlp.perf.aspects.abstractAspects.Trace outDurationMethods;
	private static int freqLogs = 1;
	private static Properties props;
	private static String dirLogs, sep = ";";
	private static String strFreqLogs = "";
	private static DecimalFormat df = new DecimalFormat("#0.000",
			new DecimalFormatSymbols(Locale.ENGLISH));
	private static DecimalFormat dfPercent = new DecimalFormat("#0.0",
			new DecimalFormatSymbols(Locale.ENGLISH));
	private static boolean isTimeFreq = false;
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
				.containsKey("jlp.perf.aspects.abstractAspects.AbstractEhCacheSizeTracking.filelogs")) {
			fileTrace = dirLogs
					+ props.getProperty("jlp.perf.aspects.abstractAspects.AbstractEhCacheSizeTracking.filelogs");
		} else {
			fileTrace = props.getProperty("aspectsPerf.default.filelogs");
		}
		computeSizesInBytesEnabled = Boolean
				.parseBoolean(props
						.getProperty(
								"jlp.perf.aspects.abstractAspects.AbstractEhCacheSizeTracking.computeSizesInBytesEnabled",
								"true"));

		// System.out.println("ConcreteEhCacheSizeTracking : fichier trace = "+fileTrace);
		// outDurationMethods = new
		// Trace("####time"+sep+"nameOfCache"+sep+"Nb Elements in Memory"+sep+"Size in Memory"+sep+"Nb Elements on disk"
		// +sep+"Total nb Elements"+sep+"HitCount\n",fileTrace);
		outDurationMethods = new Trace("####time" + sep + "nameOfCache" + sep
				+ "Nb Elements in Memory" + sep + "Size in Memory" + sep
				+ "Nb Elements on disk" + sep + "hitCount\n", fileTrace);

		/*
		 * outDurationMethods .append(new StringBuilder(
		 * "####time;Class.methods;time in millisecondes\n") .toString());
		 */

		strFreqLogs = props
				.getProperty(
						"jlp.perf.aspects.abstractAspects.AbstractEhCacheSizeTracking.freqLogs",
						"1");
		if (strFreqLogs.contains("ms")) {
			isTimeFreq = true;
			freqLogs = Integer.parseInt(strFreqLogs.substring(0,
					strFreqLogs.indexOf("m")));
		}

	}

	// Put it pointcut for Method to replace
	public abstract pointcut methods();

	before(): methods()	 {

		synchronized (this) {

			

			hitCount++;
			try {
				nameOfCache = (String) thisJoinPoint.getThis().getClass()
						.getMethod("getRegionName", (Class[]) null)
						.invoke(thisJoinPoint.getThis(), (Object[]) null);
			} catch (IllegalArgumentException e2) {
				System.out
						.println("AspectJ LTW  IllegalArgumentException => AbstractEhCacheSizeTracking methods :"
								+ e2.getMessage());
			} catch (SecurityException e2) {
				System.out
						.println("AspectJ LTW SecurityException => AbstractEhCacheSizeTracking methods :"
								+ e2.getMessage());
			} catch (IllegalAccessException e2) {
				System.out
						.println("AspectJ LTW IllegalAccessException => AbstractEhCacheSizeTrackingg methods :"
								+ e2.getMessage());
			} catch (InvocationTargetException e2) {
				System.out
						.println("AspectJ LTW InvocationTargetException => AbstractEhCacheSizeTracking methods :"
								+ e2.getMessage());
			} catch (NoSuchMethodException e2) {
				System.out
						.println("AspectJ LTW InvocationTargetException => AbstractEhCacheSizeTracking methods :"
								+ e2.getMessage());
			}

			String strObjName = new StringBuilder(
					"ConcreteEhCacheSizeTracking:type=").append(nameOfCache)
					.toString();

			if (isTimeFreq) {
				if (hmCounter.containsKey("strObjName")) {
					timeDeb = hmCounter.get("strObjName");
				} else {
					timeDeb = System.currentTimeMillis();
					hmCounter.put("strObjName", timeDeb);
				}
				if ((System.currentTimeMillis() - timeDeb) > freqLogs) {
					hmCounter.put("strObjName", System.currentTimeMillis());
					proceedWrite(thisJoinPoint);
				}
			}

			else {
				if(hmCounter.containsKey("strObjName"))
				{
					hmCounter.put("strObjName",hmCounter.get("strObjName")+1);;
				}
				else
				{
					hmCounter.put("strObjName",1L);
				}
				
				if (hmCounter.get("strObjName") > freqLogs) {
					hmCounter.put("strObjName",0L);;
					proceedWrite(thisJoinPoint);
				}
			}
		}
	}

	private final void proceedWrite(JoinPoint aJoinPoint) {
		try {

			// System.out.println("NomClasse ="+thisJoinPoint.getThis().getClass().getCanonicalName());
			nbElementInMemory = (Long) (aJoinPoint.getThis().getClass()
					.getMethod("getElementCountInMemory", (Class[]) null)
					.invoke(aJoinPoint.getThis(), (Object[]) null));
			if (computeSizesInBytesEnabled)

			{
				sizeInByteInMemory = (Long) aJoinPoint.getThis().getClass()
						.getMethod("getSizeInMemory", (Class[]) null)
						.invoke(aJoinPoint.getThis(), (Object[]) null);
			}
			nbElementInDisk = (Long) aJoinPoint.getThis().getClass()
					.getMethod("getElementCountOnDisk", (Class[]) null)
					.invoke(aJoinPoint.getThis(), (Object[]) null);
			// totalnbElements=(Long)
			// thisJoinPoint.getThis().getClass().getMethod("getSize",(Class[])
			// null).invoke(thisJoinPoint,(Object[])null);
			
			// hitCount=(Long)
			// thisJoinPoint.getThis().getClass().getMethod("getHitCount",(Class[])
			// null).invoke(thisJoinPoint,(Object[])null);
			// invocation static method below
			// Class.forName("FullNameClass").getMethod("staticMethod",
			// (Class[]) null).invoke(null,(Object[])null);
		} catch (IllegalArgumentException e2) {
			System.out
					.println("AspectJ LTW  IllegalArgumentException => AbstractEhCacheSizeTracking methods :"
							+ e2.getMessage());
		} catch (SecurityException e2) {
			System.out
					.println("AspectJ LTW SecurityException => AbstractEhCacheSizeTracking methods :"
							+ e2.getMessage());
		} catch (IllegalAccessException e2) {
			System.out
					.println("AspectJ LTW IllegalAccessException => AbstractEhCacheSizeTrackingg methods :"
							+ e2.getMessage());
		} catch (InvocationTargetException e2) {
			System.out
					.println("AspectJ LTW InvocationTargetException => AbstractEhCacheSizeTracking methods :"
							+ e2.getMessage());
		} catch (NoSuchMethodException e2) {
			System.out
					.println("AspectJ LTW InvocationTargetException => AbstractEhCacheSizeTracking methods :"
							+ e2.getMessage());
		}

		outDurationMethods.append(new StringBuilder(outDurationMethods.getSdf()
				.format(Calendar.getInstance().getTime())).append(sep)
				.append(nameOfCache).append(sep).append(nbElementInMemory)
				.append(sep).append(sizeInByteInMemory).append(sep)
				.append(nbElementInDisk).append(sep).append(hitCount)
				.append("\n").toString());

		// outDurationMethods.flush();

	}

}
