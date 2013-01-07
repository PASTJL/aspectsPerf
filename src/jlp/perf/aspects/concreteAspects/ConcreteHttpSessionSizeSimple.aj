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

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.Calendar;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Locale;
import java.util.Properties;

import jlp.helper.Counters;
import jlp.helper.SizeOf;
import jlp.perf.aspects.abstractAspects.Trace;

public aspect ConcreteHttpSessionSizeSimple issingleton (){

	private static String fileTrace = "";

	private static jlp.perf.aspects.abstractAspects.Trace outHttpSessionSize;
	private static long frequenceMeasure = 0;
	private static Properties props;
	private static String dirLogs, sep = ";";
	private static long countGlobal = 0;

	static final Counters counters;
	public static long freqCount = 0;
	public boolean boolWoven = false;
	public static boolean aspectSerialization = false;
	public static String strAspectSerialization = "true";
	public static boolean boolYetChecked = false;
	public static boolean boolNativeMethod = false;
	// Counter 1 => moyenne size
	// Counter 2 => maximum size
	// Counter 3 => session examined
	private static DecimalFormat df = new DecimalFormat("#0.000",
			new DecimalFormatSymbols(Locale.ENGLISH));
	private static DecimalFormat dfPercent = new DecimalFormat("#0.0",
			new DecimalFormatSymbols(Locale.ENGLISH));
	

	
	private static HashMap<String, Long> hmCounter = new HashMap<String, Long>();
	private static boolean isTimeFreq = false;

	static {
		Locale.setDefault(Locale.ENGLISH);

		counters = new Counters(3);
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
				.containsKey("jlp.perf.aspects.concreteAspects.ConcreteHttpSessionSizeSimple.filelogs")) {
			fileTrace = dirLogs
					+ props.getProperty("jlp.perf.aspects.concreteAspects.ConcreteHttpSessionSizeSimple.filelogs");
		} else {
			fileTrace = props.getProperty("aspectsPerf.default.filelogs");
		}

		strAspectSerialization = props
				.getProperty(
						"jlp.perf.aspects.concreteAspects.ConcreteHttpSessionSizeSimple.serialization",
						"false");
		if ("false".equals(strAspectSerialization)) {
			aspectSerialization = false;
		}

		System.out
				.println("Dans static ConcreteHttpSession type trace : HttpSessionSizeSimple fichier trace = "
						+ fileTrace);

		/*
		 * outDurationMethods .append(new StringBuilder(
		 * "####time;Class.methods;time in millisecondes\n") .toString());
		 */

		String strFreqLogs = props
				.getProperty(
						"jlp.perf.aspects.concreteAspects.ConcreteHttpSessionSizeSimple.frequenceMeasure",
						"1");
		if (strFreqLogs.contains("ms")) {
			isTimeFreq = true;
			frequenceMeasure = Integer.parseInt(strFreqLogs.substring(0,
					strFreqLogs.indexOf("m")));
		}
		outHttpSessionSize = new Trace("####time" + sep + "ClassName" + sep
				+ "method" + sep + "nbObjects" + sep + "SizeCurrent in octets"
				+ sep + "SizeMax in Octets" + sep + "Sessions Examined (1 / "
				+ frequenceMeasure + ")" + sep + "Total Invalidated", fileTrace);
		SizeOf.setInst(org.aspectj.weaver.loadtime.Agent.getInstrumentation());
	}


	public final pointcut methods2(): execution ( public * javax.servlet.http.HttpSession+.expire(..))  ;
	public final pointcut methods1(): execution ( public * javax.servlet.http.HttpSession+.invalidate()) ;
	public final pointcut methods() : methods1() || methods2();
	@SuppressWarnings("unchecked")
	before(): methods()
	{
		// System.out.println("Rentree dans before");
		
	
		synchronized (this) {
			
			Object sess = thisJoinPoint.getThis();
			int nbObjects = 0;
			String name = "nameEmpty";
			
			try {

				
				Object obj2 = sess.getClass()
						.getMethod("getServletContext", (Class[]) null)
						.invoke(sess, (Object[]) null);
				name = ((String) obj2.getClass()
						.getMethod("getContextPath", (Class[]) null)
						.invoke(obj2, (Object[]) null)).replaceAll("\\s+",
						"").replaceAll("/", "_");
				
			} catch (IllegalArgumentException e2) {
				System.out
						.println("methods2() passage 1 IllegalArgumentException AspectJ LTW => ConcreteHttpSessionSize methods :"
								+ e2.getMessage());
				return;
			} catch (SecurityException e2) {
				System.out
						.println("methods2() passage 1 SecurityException AspectJ LTW => ConcreteHttpSessionSize methods :"
								+ e2.getMessage());
				return;
			} catch (IllegalAccessException e2) {
				System.out
						.println("methods2() passage 1 IllegalAccessException AspectJ LTW => ConcreteHttpSessionSize methods :"
								+ e2.getMessage());
				return;
			} catch (InvocationTargetException e2) {
				System.out
						.println("methods2() passage 1 InvocationTargetException AspectJ LTW => ConcreteHttpSessionSize methods :"
								+ e2.getMessage());
				System.out.println("methods2() passage 1  InvocationTargetException sess class ="+sess.getClass().getCanonicalName());
				
			} catch (NoSuchMethodException e2) {
				System.out
						.println("methods2() passage 1 NoSuchMethodException AspectJ LTW => ConcreteHttpSessionSize methods :"
								+ e2.getMessage());
				return;
			}
			
			if(!hmCounter.containsKey(name))
			{
				if(isTimeFreq )
				{
				hmCounter.put(name,(Long)System.currentTimeMillis());
								}
				else
				{
					hmCounter.put(name,(Long) 1L);
				}
			}
			if(isTimeFreq )
			{
			long newTime=System.currentTimeMillis();
			freqCount=(int) (newTime-hmCounter.get(name));
			
			}
			else
			{
				freqCount=(int)(long) hmCounter.get(name);
				hmCounter.put(name,(Long)((long)(int)freqCount)+1);
			}
			
			countGlobal++;
			if (freqCount >= frequenceMeasure) {
				// On trace
				if(isTimeFreq )
				{
				
				
				hmCounter.put(name,(Long) System.currentTimeMillis());
				}
				else
				{
					hmCounter.put(name,0L);
				}

				
				try {

					
					Enumeration<String> en = (Enumeration)( sess
							.getClass()
							.getMethod("getAttributeNames",  (Class[]) null)
							.invoke(sess,   (Object[]) null));
					while (en.hasMoreElements()) {
						nbObjects++;
						en.nextElement();

					}
				} catch (IllegalArgumentException e2) {
					System.out
							.println("methods2() passage 2 IllegalArgumentException AspectJ LTW => ConcreteHttpSessionSize methods2 :"
									+ e2.getMessage());
					return;
				} catch (SecurityException e2) {
					System.out
							.println("methods2() passage 2  SecurityException  AspectJ LTW => ConcreteHttpSessionSize methods2 :"
									+ e2.getMessage());
					return;
				} catch (IllegalAccessException e2) {
					System.out
							.println("methods2() passage 2  IllegalAccessException AspectJ LTW => ConcreteHttpSessionSize methods2 :"
									+ e2.getMessage());
					return;
				} catch (InvocationTargetException e2) {
//					System.out
//							.println("methods2() passage 2  InvocationTargetException AspectJ LTW => ConcreteHttpSessionSize methods2 :"
//									+ e2.getMessage());
					System.out.println("methods2() passage 2  InvocationTargetException sess class ="+sess.getClass().getCanonicalName());
					
				} catch (NoSuchMethodException e2) {
					System.out
							.println("methods2() passage 2  NoSuchMethodException AspectJ LTW => ConcreteHttpSessionSize methods2 :"
									+ e2.getMessage());
					return;
				}

				double sizeObject = 0;

				if (aspectSerialization) {
					// On serialise
					ByteArrayOutputStream baos = new ByteArrayOutputStream(1024);
					ObjectOutputStream oos = null;
					try {
						oos = new ObjectOutputStream(baos);
					} catch (IOException e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
					}
					
					
					
					if(!boolYetChecked) 
					{
						boolYetChecked=true;
						if (sess.getClass()
								.getCanonicalName()
								.equals("org.apache.catalina.session.StandardSession"))
						{
							boolNativeMethod=true;
						}
					}
					

						if (boolNativeMethod) {
							try {
								Method meth = sess
										.getClass()
										.getDeclaredMethod(
												"writeObjectData",
												java.io.ObjectOutputStream.class);
								meth.setAccessible(true);
								meth.invoke(sess, oos);
							} catch (IllegalArgumentException e) {
								// TODO Auto-generated catch block

							} catch (SecurityException e) {
								// TODO Auto-generated catch block

							} catch (IllegalAccessException e) {
								// TODO Auto-generated catch block

							} catch (InvocationTargetException e) {
								// TODO Auto-generated catch block

							} catch (NoSuchMethodException e) {
								// TODO Auto-generated catch block

							}
						} else {
							try {
							oos.writeObject((Serializable) sess);
						} catch (IOException e) {
							// TODO Auto-generated catch block

						}
					}

					// on recupere tous les parametres de la session

					try {
						oos.flush();
						sizeObject = (double) baos.size();
						oos.close();
						baos.close();
					} catch (IOException e) {
						// TODO Auto-generated catch block

					}

				} else {
					// sizeObject = SizeOf.retainedSizeOf(sess);
					sizeObject = (double) SizeOf.deepSizeOf(sess);
				}
				if (!counters.getHmCount().containsKey(name)) {
					int sizeTab = counters.getSizeTab();
					Double[] tabDouble = new Double[sizeTab];
					for (int i = 0; i < sizeTab; i++) {
						tabDouble[i] = new Double(0);
					}
					counters.getHmCount().put(name, tabDouble);
				}
				// on remplit le HashMap
				Double[] tabTmpDouble = counters.getHmCount().get(name);
				tabTmpDouble[0] = sizeObject;
				if (tabTmpDouble[1] <= new Double(sizeObject)) {
					tabTmpDouble[1] = new Double(sizeObject);
				}
				tabTmpDouble[2]++;

				// sauvegarde HashMap
				counters.getHmCount().put(name, tabTmpDouble);

				// ecriture
				outHttpSessionSize.append(new StringBuilder(outHttpSessionSize
						.getSdf().format(Calendar.getInstance().getTime()))
						.append(sep).append(name).append(sep)
						.append("sessionExpire").append(sep)
						.append(nbObjects).append(sep)
						.append(df.format(tabTmpDouble[0])).append(sep)
						.append(df.format(tabTmpDouble[1])).append(sep)
						.append((long) tabTmpDouble[2].longValue()).append(sep)
						.append(countGlobal).append("\n").toString());

			}
		}
	
	}

}
