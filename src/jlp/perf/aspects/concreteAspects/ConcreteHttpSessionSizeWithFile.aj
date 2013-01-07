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
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.lang.reflect.InvocationTargetException;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.Calendar;
import java.util.Enumeration;
import java.util.Locale;
import java.util.Properties;

import jlp.helper.Counters;
import jlp.helper.SizeOf;
import jlp.perf.aspects.abstractAspects.Trace;

public aspect ConcreteHttpSessionSizeWithFile {

	private static String fileTrace = "";

	private static jlp.perf.aspects.abstractAspects.Trace outHttpSessionSize;
	private static long frequenceMeasure = 1;
	private static Properties props;
	private static String dirLogs, sep = ";";
	private static long countGlobal = 0;

	static final Counters counters;
	public static long freqCount = 0;
	public boolean boolWoven = false;

	// Counter 1 => moyenne size
	// Counter 2 => maximum size
	// Counter 3 => session examined
	private static DecimalFormat df = new DecimalFormat("#0.000",
			new DecimalFormatSymbols(Locale.ENGLISH));
	private static DecimalFormat dfPercent = new DecimalFormat("#0.0",
			new DecimalFormatSymbols(Locale.ENGLISH));
	static String folder = "";
	static File fout = null;
	public static boolean aspectSerialization = true;
	public static String strAspectSerialization = "true";

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
				.containsKey("jlp.perf.aspects.concreteAspects.ConcreteHttpSessionSizeWithFile.filelogs")) {
			fileTrace = dirLogs
					+ props
							.getProperty("jlp.perf.aspects.concreteAspects.ConcreteHttpSessionSizeWithFile.filelogs");
		} else {
			fileTrace = props.getProperty("aspectsPerf.default.filelogs");
		}

		System.out
				.println("Dans static ConcreteHttpSession type trace : HttpSessionSize fichier trace = "
						+ fileTrace);

		/*
		 * outDurationMethods .append(new StringBuilder(
		 * "####time;Class.methods;time in millisecondes\n") .toString());
		 */
		folder = props.getProperty("aspectsPerf.default.dirLogs", "/tmp");

		fout = new File(folder + File.separator + "sessionSerialized.bin");
		frequenceMeasure = Long
				.parseLong(props
						.getProperty("jlp.perf.aspects.concreteAspects.ConcreteHttpSessionSizeWithFile.frequenceMeasure","1"));
		
		strAspectSerialization = props.getProperty(
				"jlp.perf.aspects.concreteAspects.ConcreteHttpSessionSizeWithFile.serialization",
				"true");
		if ("false".equals(strAspectSerialization)) {
			aspectSerialization = false;
		}
		
		outHttpSessionSize = new Trace("####time" + sep + "ClassName" + sep
				+ "method" + sep + "nbObjects+" + sep
				+ "SizeCurrent in octets" + sep + "SizeMax in Octets" + sep
				+ "Sessions Examined (1 / " + frequenceMeasure + ")" + sep
				+ "Total Invalidated", fileTrace);
		SizeOf.setInst(org.aspectj.weaver.loadtime.Agent.getInstrumentation());
	}

	public final pointcut methods(Object hev): 
		execution( public 	* javax.servlet.http.HttpSessionListener+.sessionDestroyed(Object))
		&& args(hev) && !cflowbelow(execution( public 	* javax.servlet.http.HttpSessionListener+.sessionDestroyed(Object))
		) ;

	public final pointcut methods2(): execution(public * javax.servlet.http.HttpSession+.invalidate())
	&& !cflowbelow( execution(public * javax.servlet.http.HttpSession+.invalidate())) ;;

	before(Object hev): methods(hev)
	{
		// System.out.println("Rentree dans before");

		synchronized (this) {

			freqCount++;
			this.countGlobal++;

			if (freqCount >= frequenceMeasure) {
				// On trace
				freqCount = 0;
				Object obj = thisJoinPoint.getThis();
				Object sess = null;
				int nbObjects = 0;
				String name = "nameEmpty";
				try {

					sess = hev.getClass().getMethod("getSession",
							(Class[]) null).invoke(hev, (Object[]) null);
					Object obj2=sess.getClass().getMethod(
							"getServletContext", (Class[]) null).invoke(sess,
									(Object[]) null);
					name = ((String)obj2.getClass().getMethod(
							"getContextPath", (Class[]) null).invoke(obj2,
							(Object[]) null)).replaceAll("\\s+", "").replaceAll("/", "_");
					Enumeration<String> en = (Enumeration<String>) sess
							.getClass().getMethod("getAttributeNames",
									(Class[]) null).invoke(sess,
									(Object[]) null);
					while (en.hasMoreElements()) {
						nbObjects++;
						en.nextElement();

					}
				} catch (IllegalArgumentException e2) {
					System.out
							.println("AspectJ LTW => ConcreteHttpSessionSizeWithFile methods :"
									+ e2.getMessage());
					return;
				} catch (SecurityException e2) {
					System.out
							.println("AspectJ LTW => ConcreteHttpSessionSizeWithFile methods :"
									+ e2.getMessage());
					return;
				} catch (IllegalAccessException e2) {
					System.out
							.println("AspectJ LTW => ConcreteHttpSessionSizeWithFile methods :"
									+ e2.getMessage());
					return;
				} catch (InvocationTargetException e2) {
					System.out
							.println("AspectJ LTW => ConcreteHttpSessionSizeWithFile methods :"
									+ e2.getMessage());
					return;
				} catch (NoSuchMethodException e2) {
					System.out
							.println("AspectJ LTW => ConcreteHttpSessionSizeWithFile methods :"
									+ e2.getMessage());
					return;
				}

				double sizeObject = 0;
				if (aspectSerialization) {
				// On serialise
				FileOutputStream fos = null;
				try {
					fos = new FileOutputStream(fout, false);
				} catch (FileNotFoundException e2) {
					// TODO Auto-generated catch block
					
				}
				ObjectOutputStream oos = null;
				try {
					oos = new ObjectOutputStream(fos);
				} catch (IOException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
				try {

					if (sess.getClass()
							.getCanonicalName()
							.equals("org.apache.catalina.session.StandardSession")) {
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
						oos.writeObject((Serializable) sess);
					}
					/*
					 * System.out.println("serialisation reussie pour objet : "
					 * + obj3.getClass().getName());
					 */

				} catch (IOException e) {
					// TODO Auto-generated catch block
//					System.out.println("erreur serialisation pour objet : "
//							+ sess.getClass().getName());
					// e.printStackTrace();

				}

				try {
					oos.flush();
					fos.flush();
					sizeObject = (double) fout.length();

					oos.close();
					fos.close();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}

				}
				else
				{
					//sizeObject = SizeOf.sizeof(obj);
					sizeObject = (double) SizeOf.deepSizeOf(obj);
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
						.append(sep).append(name).
						append(sep).append("destroyed").
						append(sep).append(
								df.format(tabTmpDouble[0])).append(sep).append(
								df.format(tabTmpDouble[1])).append(sep).append(
								nbObjects).append(sep).append(
								(long) tabTmpDouble[2].longValue()).append(sep)
						.append(countGlobal).append("\n")
						.toString());

			}
		}

	}

	@SuppressWarnings("unchecked")
	before(): methods2()
	{
		// System.out.println("Rentree dans before");

		synchronized (this) {

			freqCount++;
			this.countGlobal++;

			if (freqCount >= frequenceMeasure) {
				// On trace
				freqCount = 0;

				Object sess = null;

				sess = thisJoinPoint.getThis();
				int nbObjects = 0;
				String name = "nameEmpty";
				try {

					name = ((String) sess.getClass().getMethod(
							"getServletContext", (Class[]) null).invoke(sess,
							(Object[]) null)).replaceAll("\\s+", "");
					Enumeration<String> en = (Enumeration<String>) sess
							.getClass().getMethod("getAttributeNames",
									(Class[]) null).invoke(sess,
									(Object[]) null);
					while (en.hasMoreElements()) {
						nbObjects++;
						en.nextElement();

					}
				} catch (IllegalArgumentException e2) {
					System.out
							.println("AspectJ LTW => ConcreteHttpSessionSizeWithFile methods2 :"
									+ e2.getMessage());
					return;
				} catch (SecurityException e2) {
					System.out
							.println("AspectJ LTW => ConcreteHttpSessionSizeWithFile methods2 :"
									+ e2.getMessage());
					return;
				} catch (IllegalAccessException e2) {
					System.out
							.println("AspectJ LTW => ConcreteHttpSessionSizeWithFile methods2 :"
									+ e2.getMessage());
					return;
				} catch (InvocationTargetException e2) {
					System.out
							.println("AspectJ LTW => ConcreteHttpSessionSizeWithFile methods2 :"
									+ e2.getMessage());
					return;
				} catch (NoSuchMethodException e2) {
					System.out
							.println("AspectJ LTW => ConcreteHttpSessionSizeWithFile methods2 :"
									+ e2.getMessage());
					return;
				}

				double sizeObject = 0;
				if (aspectSerialization) {
				// On serialise
				FileOutputStream fos = null;
				try {
					fos = new FileOutputStream(fout, false);
				} catch (FileNotFoundException e2) {
					// TODO Auto-generated catch block
					e2.printStackTrace();
				}
				ObjectOutputStream oos = null;
				try {
					oos = new ObjectOutputStream(fos);
				} catch (IOException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
				try {

					if (sess.getClass()
							.getCanonicalName()
							.equals("org.apache.catalina.session.StandardSession")) {
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
						oos.writeObject((Serializable) sess);
					}
					/*
					 * System.out.println("serialisation reussie pour objet : "
					 * + obj3.getClass().getName());
					 */

				} catch (IOException e) {
					// TODO Auto-generated catch block
//					System.out.println("erreur serialisation pour objet : "
//							+ sess.getClass().getName());
					// e.printStackTrace();

				}

				// on recupere tous les parametres de la session

				try {
					oos.flush();
					fos.flush();
					sizeObject = (double) fout.length();

					oos.close();
					fos.close();
				} catch (IOException e) {
					// TODO Auto-generated catch block
				
				}
				}
				else
				{
				//	sizeObject = SizeOf.sizeof(sess);
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
						.append(sep).append(name).
						append(sep).append("invalidate_expire").
						
						append(sep).append(nbObjects)
						.append(sep).append(df.format(tabTmpDouble[0])).append(
								sep).append(df.format(tabTmpDouble[1])).append(
								sep).append((long) tabTmpDouble[2].longValue())
						.append(sep).append(countGlobal).append(
								"\n").toString());

			}
		}
	}

}
