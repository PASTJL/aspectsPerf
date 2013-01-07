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

import jlp.helper.SizeOf;
import jlp.perf.aspects.abstractAspects.Trace;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.lang.reflect.InvocationTargetException;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Locale;
import java.util.Properties;

public aspect ConcreteHttpSessionSizeJonas5 {

	private static long frequenceMeasure = 1;
	private static Properties props;
	private static jlp.perf.aspects.abstractAspects.Trace outHttpCacheSize;
	public static int freqCount = 0;

	// Counter 1 => moyenne size
	// Counter 2 => maximum size
	// Counter 3 => session examined

	public static String sep;
	public static String dirLogs;
	public static int sessionExamined = 0;
	public static int countGlobal = 0;
	public static double sizeMoyen = 0;
	public static double sizeMax = 0;
	private static DecimalFormat df = new DecimalFormat("#0.000",
			new DecimalFormatSymbols(Locale.ENGLISH));
	private static DecimalFormat dfPercent = new DecimalFormat("#0.0",
			new DecimalFormatSymbols(Locale.ENGLISH));
	public static boolean aspectSerialization = true;
	public static String strAspectSerialization = "true";
	public static boolean boolYetChecked = false;
	public static boolean boolNativeMethod = false;
	private static String fileTrace;

	private static HashMap<String, Long> hmCounter = new HashMap<String, Long>();
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
				.containsKey("jlp.perf.aspects.concreteAspects.ConcreteHttpSessionSizeJonas5.filelogs")) {
			fileTrace = dirLogs
					+ props
							.getProperty("jlp.perf.aspects.concreteAspects.ConcreteHttpSessionSizeJonas5.filelogs");
		} else {
			fileTrace = props.getProperty("aspectsPerf.default.filelogs");
		}
		strAspectSerialization = props.getProperty(
				"jlp.perf.aspects.concreteAspects.ConcreteHttpSessionSizeJonas5.serialization",
				"true");
		if ("false".equals(strAspectSerialization)) {
			aspectSerialization = false;
		}

		System.out
				.println("Dans static concreteHttpSessionSizeJonas5 type trace : concreteHttpSessionSizeJonas5 fichier trace = "
						+ fileTrace);

		/*
		 * outDurationMethods .append(new StringBuilder(
		 * "####time;Class.methods;time in millisecondes\n") .toString());
		 */

		String strFreqLogs = props
				.getProperty(
						"jlp.perf.aspects.concreteAspects.ConcreteHttpSessionSizeJonas5.frequenceMeasure",
						"1");
		if (strFreqLogs.contains("ms")) {
			isTimeFreq = true;
			frequenceMeasure = Integer.parseInt(strFreqLogs.substring(0,
					strFreqLogs.indexOf("m")));
		}
		
		outHttpCacheSize = new Trace("####time" + sep + "Path Session" + sep
				+"method"+sep
				+ "SizeCurrent in octets" + sep + "Size Moy in octets" + sep
				+ "SizeMax in Octets" + sep + "Sessions Examined (1 / "
				+ frequenceMeasure + ")" + sep + "Total", fileTrace);
		SizeOf.setInst(org.aspectj.weaver.loadtime.Agent.getInstrumentation());
	}

	public final pointcut methods(): 
		execution( public 	*  org.apache.catalina.session.StandardSession.expire(boolean)) ||
		execution (public * org.apache.catalina.session.ManagerBase+.expireSession(String));

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
						.println("AspectJ LTW => ConcreteHttpSessionSize methods :"
								+ e2.getMessage());
				return;
			} catch (SecurityException e2) {
				System.out
						.println("AspectJ LTW => ConcreteHttpSessionSize methods :"
								+ e2.getMessage());
				return;
			} catch (IllegalAccessException e2) {
				System.out
						.println("AspectJ LTW => ConcreteHttpSessionSize methods :"
								+ e2.getMessage());
				return;
			} catch (InvocationTargetException e2) {
				System.out
						.println("AspectJ LTW => ConcreteHttpSessionSize methods :"
								+ e2.getMessage());
				return;
			} catch (NoSuchMethodException e2) {
				System.out
						.println("AspectJ LTW => ConcreteHttpSessionSize methods :"
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

				
				// on recupere tous les parametres de la session
				double sizeObject = 0;
				if (aspectSerialization) {
					ByteArrayOutputStream baos = new ByteArrayOutputStream(1024);
					ObjectOutputStream oos = null;
					try {
						oos = new ObjectOutputStream(baos);
					} catch (IOException e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
					}

					// On serialise

					try {
						// System.out.println("Rentree dans before methods pt 4");
						if (!boolYetChecked) {
							if (sess.getClass()
									.getCanonicalName()
									.equals("org.apache.catalina.session.StandardSession")) {
								boolNativeMethod = true;
								System.out.println ( "ConcreteHttpSessionSizeJonas5 : Usage native classe : "+sess.getClass()
										.getCanonicalName());
							}
							boolYetChecked = true;
						}
						if (boolNativeMethod)  {
							try {
								sess.getClass()
										.getMethod("writeObjectData",
												ObjectOutputStream.class)
										.invoke(sess, oos);
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
							if(sess instanceof Serializable){
								oos.writeObject((Serializable) sess);
							}
						}
						/*
						 * System.out.println("serialisation reussie pour objet : "
						 * + obj3.getClass().getName());
						 */

					} catch (IOException e) {

						// e.printStackTrace();
//						System.out
//								.println("one object at least is not serializable for context of  : "
//										+ obj.getClass().getName());

					}

					try {
						oos.flush();
						sizeObject = (double) ((double) baos.size());
						oos.close();
						baos.close();
					} catch (IOException e) {
						// TODO Auto-generated catch block
						
					}

				} else {
					//sizeObject = SizeOf.retainedSizeOf(sess);
					if ( null !=sess)
					sizeObject = (double) SizeOf.deepSizeOf(sess);
				}
				// on remplit les compteurs depuis le mbean

				// httSizeMoyen
				if (sizeObject>0){
				sizeMoyen = (sizeMoyen * sessionExamined + sizeObject)
						/ (sessionExamined + 1);
				/*
				 * System.out.println("sizeMoyenAvant="+sizeMoyenAvant);
				 * System.out.println("sizeMoyenApres="+sizeMoyenApres);
				 */

				// httpSizeMax
				if (sizeMax < sizeObject) {
					sizeMax = sizeObject;
				}

				// sauvegarde HashMap
				sessionExamined++;

				// ecriture modification du mbean

				outHttpCacheSize.append(new StringBuilder(outHttpCacheSize
						.getSdf().format(Calendar.getInstance().getTime()))
						.append(sep).append(
								name).append(sep)
						.append("expire").append(sep)

						.append(sizeObject).append(sep).append(sizeMoyen)
						.append(sep).append(sizeMax).append(sep).append(
								sessionExamined).append(sep)
						.append(countGlobal).append("\n").toString());

			}
			}
		}
	}

}
