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
package jlp.aspectsJMX.concreteAspects;

import java.io.File;
import java.lang.management.ManagementFactory;
import java.lang.reflect.InvocationTargetException;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Locale;
import java.util.Properties;

import javax.management.InstanceAlreadyExistsException;
import javax.management.MBeanRegistrationException;
import javax.management.MBeanServer;
import javax.management.MalformedObjectNameException;
import javax.management.NotCompliantMBeanException;
import javax.management.ObjectName;

import org.aspectj.lang.JoinPoint;

import jlp.aspectsJMX.mbean.EhCacheSizeTracking;
import jlp.perf.aspects.abstractAspects.Trace;

public privileged aspect ConcreteEhCacheSizeTracking {
	private static String fileTrace = "";
	private long nbElementInMemory = 0;
	private long sizeInByteInMemory = -1;
	private static long nbElementInDisk = 0;

	
	private static String nameOfCache = "";
	private static long hitCount = 0;
	private static long timeDeb = System.currentTimeMillis();
	private static boolean computeSizesInBytesEnabled = true;
	private static MBeanServer mbs;
	private static long compteur = 0;
	private static HashMap<String, Long> hmCounter = new HashMap<String, Long>();
	private static HashMap<String, EhCacheSizeTracking> hmBean = new HashMap<String, EhCacheSizeTracking>();
	private static jlp.perf.aspects.abstractAspects.Trace outDurationMethods;
	private static long freqLogs = 1;
	private static Properties props;
	private static String dirLogs, sep = ";";
	private static String strFreqLogs = "";
	private static boolean traceLogEnabled= false;
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
				.containsKey("jlp.aspectsJMX.concreteAspects.ConcreteEhCacheSizeTracking.filelogs")) {
			fileTrace = dirLogs
					+ props.getProperty("jlp.aspectsJMX.concreteAspects.ConcreteEhCacheSizeTracking.filelogs");
		} else {
			fileTrace = props.getProperty("aspectsPerf.default.filelogs");
		}

		mbs = ManagementFactory.getPlatformMBeanServer();

		traceLogEnabled= Boolean
		.parseBoolean(props
				.getProperty(
						"jlp.aspectsJMX.concreteAspects.ConcreteEhCacheSizeTracking.traceLogEnabled",
						"false"));
		computeSizesInBytesEnabled = Boolean
				.parseBoolean(props
						.getProperty(
								"jlp.aspectsJMX.concreteAspects.ConcreteEhCacheSizeTracking.computeSizesInBytesEnabled",
								"true"));

		outDurationMethods = new Trace("####time" + sep + "nameOfCache" + sep
				+ "Nb Elements in Memory" + sep + "Size in Memory" + sep
				+ "Nb Elements on disk" + sep + "hitCount\n", fileTrace);
		System.out.println("ConcreteEhCacheSizeTracking : fichier trace = "
				+ fileTrace);
		// outDurationMethods = new
		// Trace("####time"+sep+"nameOfCache"+sep+"Nb Elements in Memory"+sep+"Size in Memory"+sep+"Nb Elements on disk"
		// +sep+"Total nb Elements"+sep+"HitCount\n",fileTrace);

		/*
		 * outDurationMethods .append(new StringBuilder(
		 * "####time;Class.methods;time in millisecondes\n") .toString());
		 */

		strFreqLogs = props
				.getProperty(
						"jlp.aspectsJMX.concreteAspects.ConcreteEhCacheSizeTracking.freqLogs",
						"1");
		if (strFreqLogs.contains("ms")) {
			isTimeFreq = true;
			freqLogs = Long.parseLong(strFreqLogs.substring(0,
					strFreqLogs.indexOf("m")));
			
			
		}
	}

	// Put it pointcut for Method to replace
	public final pointcut methods(): execution(public final * net.sf.ehcache.hibernate.EhCache.put(..)) || execution(public final * net.sf.ehcache.hibernate.EhCache.get(..)) ;

	before(): methods()	 {

		synchronized (this) {
			hitCount++;
			try {
				nameOfCache = (String) thisJoinPoint.getThis().getClass()
						.getMethod("getRegionName", (Class[]) null)
						.invoke(thisJoinPoint.getThis(), (Object[]) null);
			} catch (IllegalArgumentException e2) {
				System.out
						.println("AspectJ LTW  IllegalArgumentException => ConcreteEhCacheSizeTracking methods :"
								+ e2.getMessage());
			} catch (SecurityException e2) {
				System.out
						.println("AspectJ LTW SecurityException => ConcreteEhCacheSizeTracking methods :"
								+ e2.getMessage());
			} catch (IllegalAccessException e2) {
				System.out
						.println("AspectJ LTW IllegalAccessException => ConcreteEhCacheSizeTracking methods :"
								+ e2.getMessage());
			} catch (InvocationTargetException e2) {
				System.out
						.println("AspectJ LTW InvocationTargetException => ConcreteEhCacheSizeTracking methods :"
								+ e2.getMessage());
			} catch (NoSuchMethodException e2) {
				System.out
						.println("AspectJ LTW InvocationTargetException => ConcreteEhCacheSizeTracking methods :"
								+ e2.getMessage());
			}

			String strObjName = new StringBuilder(
					"ConcreteEhCacheSizeTracking:type=").append(nameOfCache)
					.toString();
			
			
			if (isTimeFreq) {
				
					if(hmCounter.containsKey("strObjName"))
					{
					timeDeb = hmCounter.get("strObjName");
					}
					else
					{
						timeDeb=System.currentTimeMillis();
						hmCounter.put("strObjName",timeDeb);
					}
					if ((System.currentTimeMillis() - timeDeb) > freqLogs) {
						hmCounter.put("strObjName",System.currentTimeMillis());
					proceedWrite(thisJoinPoint);
				}

			} else {
				
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
		

		String strObjName = new StringBuilder(
				"ConcreteEhCacheSizeTracking:type=").append(nameOfCache)
				.toString();
		EhCacheSizeTracking mbean = null;
		if (!hmBean.containsKey(strObjName)) {
			// on l'ajoute
			try {
				ObjectName name = new ObjectName(strObjName);
				mbean = new EhCacheSizeTracking();
				mbean.modComputeSizesInBytesEnabled(computeSizesInBytesEnabled);
				mbean.modBoolTraceLog(traceLogEnabled);
				hmBean.put(strObjName, mbean);
				mbs.registerMBean(mbean, name);

			} catch (MalformedObjectNameException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (NullPointerException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (InstanceAlreadyExistsException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (MBeanRegistrationException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (NotCompliantMBeanException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		} else {
			mbean = hmBean.get(strObjName);

		}

		if (mbean.isActivated()) {

			try {
				// System.out.println("NomClasse ="+thisJoinPoint.getThis().getClass().getCanonicalName());
				nbElementInMemory = (Long) (aJoinPoint.getThis().getClass()
						.getMethod("getElementCountInMemory", (Class[]) null)
						.invoke(aJoinPoint.getThis(), (Object[]) null));
				if (computeSizesInBytesEnabled) {
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

				// on sert le mbean
				/*
				 * maxSizeInByteInMemory = -1;
				 * 
				 * nbElementInMemory = 0; nbElementInDisk = 0;
				 * computeSizesInBytesEnabled = true; maxSizeInByteInMemory =
				 * -1; hitCount = 0; activated = true; boolTraceLog = false;
				 */
				mbean.modHitCount(hitCount);
				mbean.modNbElementInDisk(nbElementInDisk);
				long maxNbElementInMemory = mbean.getMaxNbElementInMemory();
				mbean.modNbElementInMemory(nbElementInMemory);
				if (nbElementInMemory > maxNbElementInMemory) {
					mbean.modMaxNbElementInMemory(nbElementInMemory);
				}

				if (mbean.isComputeSizesInBytesEnabled()) {
					long maxSizeInByteInMemory = mbean
							.getMaxSizeInByteInMemory();
					mbean.modSizeInByteInMemory(sizeInByteInMemory);
					if (sizeInByteInMemory > maxSizeInByteInMemory) {
						mbean.modMaxSizeInByteInMemory(sizeInByteInMemory);
					}
				}
			} catch (IllegalArgumentException e2) {
				System.out
						.println("AspectJ LTW  IllegalArgumentException => ConcreteEhCacheSizeTracking methods :"
								+ e2.getMessage());
			} catch (SecurityException e2) {
				System.out
						.println("AspectJ LTW SecurityException => ConcreteEhCacheSizeTracking methods :"
								+ e2.getMessage());
			} catch (IllegalAccessException e2) {
				System.out
						.println("AspectJ LTW IllegalAccessException => ConcreteEhCacheSizeTracking methods :"
								+ e2.getMessage());
			} catch (InvocationTargetException e2) {
				System.out
						.println("AspectJ LTW InvocationTargetException => ConcreteEhCacheSizeTracking methods :"
								+ e2.getMessage());
			} catch (NoSuchMethodException e2) {
				System.out
						.println("AspectJ LTW InvocationTargetException =>ConcreteEhCacheSizeTracking methods :"
								+ e2.getMessage());
			}
			hmBean.put(strObjName,mbean);
			
			if (mbean.isBoolTraceLog()) {
				
				ConcreteEhCacheSizeTracking.traceLogEnabled=true;
				outDurationMethods.append(new StringBuilder(outDurationMethods
						.getSdf().format(Calendar.getInstance().getTime()))
						.append(sep).append(nameOfCache).append(sep)
						.append(nbElementInMemory).append(sep)
						.append(sizeInByteInMemory).append(sep)
						.append(nbElementInDisk).append(sep).append(hitCount)
						.append("\n").toString());
				//outDurationMethods.flush();
			}

		}
	}

}
