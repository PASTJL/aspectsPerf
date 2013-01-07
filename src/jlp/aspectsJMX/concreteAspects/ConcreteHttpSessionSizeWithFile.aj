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
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.lang.management.ManagementFactory;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.text.DecimalFormat;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Locale;
import java.util.Properties;

import javax.management.InstanceAlreadyExistsException;
import javax.management.MBeanRegistrationException;
import javax.management.MBeanServer;
import javax.management.MalformedObjectNameException;
import javax.management.NotCompliantMBeanException;
import javax.management.ObjectName;

import jlp.aspectsJMX.mbean.HttpSessionSize;
import jlp.helper.SizeOf;

public aspect ConcreteHttpSessionSizeWithFile {

	private static int frequenceMeasure = 1;
	private static Properties props;

	public static long freqCount = 0L;

	// Counter 1 => moyenne size
	// Counter 2 => maximum size
	// Counter 3 => session examined

	public static DecimalFormat df;
	public static double oldScale = 1;
	static HttpSessionSize mbean;
	static MBeanServer mbs;
	static private int countGlobal = 0;

	static String folder = "";
	static File fout = null;
	public static boolean boolYetChecked = false;
	public static boolean boolNativeMethod = false;

	public static HashMap<ObjectName, jlp.aspectsJMX.mbean.HttpSessionSize> hmMbean = new HashMap<ObjectName, jlp.aspectsJMX.mbean.HttpSessionSize>();
	private static HashMap<ObjectName, Long> hmCounter = new HashMap<ObjectName, Long>();
	private static boolean isTimeFreq = false;

	static {
		Locale.setDefault(Locale.ENGLISH);
		df = new DecimalFormat("#####0.000");

		props = jlp.perf.aspects.abstractAspects.AspectsPerfProperties.aspectsPerfProperties;

		String strFreqLogs = props
				.getProperty(
						"jlp.aspectsJMX.concreteAspects.ConcreteHttpSessionSizeWithFile.frequenceMeasure",
						"1");
		if (strFreqLogs.contains("ms")) {
			isTimeFreq = true;
			frequenceMeasure = Integer.parseInt(strFreqLogs.substring(0,
					strFreqLogs.indexOf("m")));
		}

		folder = props.getProperty("aspectsPerf.default.dirLogs", "/tmp");

		fout = new File(folder + File.separator + "sessionSerialized.bin");
		mbs = ManagementFactory.getPlatformMBeanServer();

		SizeOf.setInst(org.aspectj.weaver.loadtime.Agent.getInstrumentation());
	}

	public final pointcut methods(Object obj): 
		execution( public 	* javax.servlet.http.HttpSessionListener+.sessionDestroyed(Object))
		&& args(obj)  ;

	@SuppressWarnings("unchecked")
	before(Object obj): methods(obj) 
	{
		// System.out.println("Rentree dans before");

		synchronized (this) {

			Object objEvent = thisJoinPoint.getThis();
			Object sess=null;
			String path=null;
			ObjectName name=null;
			int nbObjects=0;
			try {
				sess = objEvent.getClass()
				.getMethod("getSession", (Class[]) null)
				.invoke(objEvent, (Object[]) null);
				Object obj2 = sess.getClass()
						.getMethod("getServletContext", (Class[]) null)
						.invoke(sess, (Object[]) null);
				path = ((String) obj2.getClass()
						.getMethod("getContextPath", (Class[]) null)
						.invoke(obj2, (Object[]) null)).replaceAll("\\s+",
						"").replaceAll("/", "_");

				
				
				
			} catch (IllegalArgumentException e2) {
				System.out
						.println("AspectJ LTW => ConcreteHttpSessionSizeJonas5 methods :"
								+ e2.getMessage());
				return;
			} catch (SecurityException e2) {
				System.out
						.println("AspectJ LTW => ConcreteHttpSessionSizeJonas5 methods :"
								+ e2.getMessage());
				return;
			} catch (IllegalAccessException e2) {
				System.out
						.println("AspectJ LTW => ConcreteHttpSessionSizeJonas5 methods :"
								+ e2.getMessage());
				return;
			} catch (InvocationTargetException e2) {
				System.out
						.println("AspectJ LTW => ConcreteHttpSessionSizeJonas5 methods :"
								+ e2.getMessage());
				return;
			} catch (NoSuchMethodException e2) {
				System.out
						.println("AspectJ LTW => ConcreteHttpSessionSizeJonas5 methods :"
								+ e2.getMessage());
				return;
			}
			
			
			try {
				name = new ObjectName(
						"AspectsConcrete:type=httpSessionSizeInOctets_"+path);
			} catch (MalformedObjectNameException e3) {
				// TODO Auto-generated catch block
				e3.printStackTrace();
			} catch (NullPointerException e3) {
				// TODO Auto-generated catch block
				e3.printStackTrace();
			}
					if(hmMbean.containsKey(name))
					{
						mbean=hmMbean.get(name);
						
						
					}
					else
					{
						mbean = new HttpSessionSize();
						mbean.modAspectHttpSessFrequency(frequenceMeasure);
						
						try {
							mbs.registerMBean(mbean, name);
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
						hmMbean.put(name, mbean);
						if(isTimeFreq )
						{
						hmCounter.put(name,(Long)System.currentTimeMillis());
										}
						else
						{
							hmCounter.put(name,(Long) 0L);
						}
						oldScale = mbean.getScale();
					}
					
					frequenceMeasure = (int) mbean.getAspectHttpSessFrequency();
					
					if(isTimeFreq )
					{
					long newTime=System.currentTimeMillis();
					freqCount=(int) (newTime-hmCounter.get(name));
					
					}
					else
					{
						freqCount= hmCounter.get(name);
						hmCounter.put(name,(Long)freqCount++);
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
				
					
					
					 nbObjects = 0;
					 double sizeObject=0;
				try {
					
					Enumeration<String> en = (Enumeration<String>) sess
							.getClass()
							.getMethod("getAttributeNames", (Class[]) null)
							.invoke(sess, (Object[]) null);
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

				// pour chaque objet on serialise
				double newScale = mbean.getScale();
				FileOutputStream fos = null;
				try {
					fos = new FileOutputStream(fout, false);
					// System.out.println("creation file :"+fout.getAbsolutePath()+" reussie");
				} catch (FileNotFoundException e2) {
					// TODO Auto-generated catch block
					e2.printStackTrace();
				}
				ObjectOutputStream oos = null;
				try {
					oos = new ObjectOutputStream(fos);
				} catch (IOException e1) {
					// TODO Auto-generated catch block
					// e1.printStackTrace();
				}

				// On serialise

				try {

					if (!boolYetChecked) {
						if (sess.getClass()
								.getCanonicalName()
								.equals("org.apache.catalina.session.StandardSession")) {
							boolNativeMethod = true;
							System.out
									.println("ConcreteHttpSessionSizeWithFile : Usage native classe : "
											+ sess.getClass()
													.getCanonicalName());
						}
						boolYetChecked = true;
					}
					if (boolNativeMethod) {
						try {
							Method meth = obj.getClass().getDeclaredMethod(
									"writeObjectData",
									java.io.ObjectOutputStream.class);
							meth.setAccessible(true);
							meth.invoke(obj, oos);
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
					// System.out
					// .println("methods error serialization for objet : "
					// + sess.getClass().getName());
					// e.printStackTrace();

				}

			
				try {
					oos.flush();
					fos.flush();
					sizeObject = (double) fout.length();
					oos.close();
					fos.close();
					// System.out.println("Fermeture file :"+fout.getAbsolutePath()+" reussie");
				} catch (IOException e) {
					// TODO Auto-generated catch block
					// e.printStackTrace();
				}

				// on remplit les compteurs depuis le mbean
				int sessExamined = mbean.getAspectHttpSessExamined();

				// httSizeMoyen
				double sizeMoyenAvant = mbean.getAspectHttpSessSizeMoy()
						* oldScale;
				double sizeMoyenApres = (sizeMoyenAvant * sessExamined + sizeObject)
						/ (sessExamined + 1);
				/*
				 * System.out.println("sizeMoyenAvant="+sizeMoyenAvant);
				 * System.out.println("sizeMoyenApres="+sizeMoyenApres);
				 */

				// httpSizeMax
				if (mbean.getAspectHttpSessSizeMax() * oldScale < sizeObject) {
					mbean.modAspectHttpSessSizeMax(sizeObject / newScale);
				}

				// sauvegarde HashMap
				sessExamined++;

				// ecriture modification du mbean
				mbean.modAspectHttpSessSizeMoy(sizeMoyenApres / newScale);
				mbean.modAspectNumberAttributes(nbObjects);
				mbean.modAspectHttpSessExamined(sessExamined);
				mbean.modAspectHttpSessTotal(countGlobal);
				mbean.modAspectHttpSessSizeCurrent(sizeObject / newScale);
				oldScale = newScale;
				mbean.changeScale(oldScale);
				hmMbean.put(name, mbean);
			}
		}

	}

	public final pointcut methods3(): 
		
		 execution ( public * org.apache.catalina.session.StandardSession.expire(boolean));

	public final pointcut methods4(): execution(public * javax.servlet.http.HttpSession+.invalidate(..)) 
	&& !cflowbelow(execution(public * javax.servlet.http.HttpSession+.invalidate(..)));

	public final pointcut methods2(): methods3() || methods4() ;

	@SuppressWarnings("unchecked")
	before(): methods2()
	{
		// traitement invalidate
		synchronized (this) {

			Object sess = thisJoinPoint.getThis();
			
			String path=null;
			ObjectName name=null;
			int nbObjects=0;
			try {
				
				Object obj2 = sess.getClass()
						.getMethod("getServletContext", (Class[]) null)
						.invoke(sess, (Object[]) null);
				path = ((String) obj2.getClass()
						.getMethod("getContextPath", (Class[]) null)
						.invoke(obj2, (Object[]) null)).replaceAll("\\s+",
						"").replaceAll("/", "_");

				Enumeration<String> en = (Enumeration<String>) sess
						.getClass()
						.getMethod("getAttributeNames", (Class[]) null)
						.invoke(sess, (Object[]) null);
				
				while (en.hasMoreElements()) {
					nbObjects++;
					en.nextElement();

				}
			} catch (IllegalArgumentException e2) {
				System.out
						.println("AspectJ LTW => ConcreteHttpSessionSizeJonas5 methods :"
								+ e2.getMessage());
				return;
			} catch (SecurityException e2) {
				System.out
						.println("AspectJ LTW => ConcreteHttpSessionSizeJonas5 methods :"
								+ e2.getMessage());
				return;
			} catch (IllegalAccessException e2) {
				System.out
						.println("AspectJ LTW => ConcreteHttpSessionSizeJonas5 methods :"
								+ e2.getMessage());
				return;
			} catch (InvocationTargetException e2) {
				System.out
						.println("AspectJ LTW => ConcreteHttpSessionSizeJonas5 methods :"
								+ e2.getMessage());
				return;
			} catch (NoSuchMethodException e2) {
				System.out
						.println("AspectJ LTW => ConcreteHttpSessionSizeJonas5 methods :"
								+ e2.getMessage());
				return;
			}
			
			
			try {
				name = new ObjectName(
						"AspectsConcrete:type=httpSessionSizeInOctets_"+path);
			} catch (MalformedObjectNameException e3) {
				// TODO Auto-generated catch block
				e3.printStackTrace();
			} catch (NullPointerException e3) {
				// TODO Auto-generated catch block
				e3.printStackTrace();
			}
					if(hmMbean.containsKey(name))
					{
						mbean=hmMbean.get(name);
						
						
					}
					else
					{
						mbean = new HttpSessionSize();
						mbean.modAspectHttpSessFrequency(frequenceMeasure);
						
						try {
							mbs.registerMBean(mbean, name);
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
						hmMbean.put(name, mbean);
						if(isTimeFreq )
						{
						hmCounter.put(name,(Long)System.currentTimeMillis());
										}
						else
						{
							hmCounter.put(name,(Long) 0L);
						}
						oldScale = mbean.getScale();
					}
					
					frequenceMeasure = (int) mbean.getAspectHttpSessFrequency();
					
					if(isTimeFreq )
					{
					long newTime=System.currentTimeMillis();
					freqCount=(int) (newTime-hmCounter.get(name));
					
					}
					else
					{
						freqCount= hmCounter.get(name);
						hmCounter.put(name,(Long)freqCount++);
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
				
					
					
					
					
					
					 nbObjects = 0;
				try {

					Enumeration<String> en = (Enumeration<String>) sess
							.getClass()
							.getMethod("getAttributeNames", (Class[]) null)
							.invoke(sess, (Object[]) null);

					while (en.hasMoreElements()) {
						nbObjects++;
						String nameAttr = en.nextElement();
						// System.out.println("Attr="+nameAttr);
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
				double newScale = mbean.getScale();

				// on recupere tous les parametres de la session

				FileOutputStream fos = null;
				try {
					fos = new FileOutputStream(fout, false);
					// System.out.println("creation file :"+fout.getAbsolutePath()+" reussie");
				} catch (FileNotFoundException e2) {
					// TODO Auto-generated catch block
					// e2.printStackTrace();
				}
				ObjectOutputStream oos = null;
				try {
					oos = new ObjectOutputStream(fos);
				} catch (IOException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
				double sizeObject = 0;

				// On serialise

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
						oos.writeObject( sess);
					}
					/*
					 * System.out.println("serialisation reussie pour objet : "
					 * + obj3.getClass().getName());
					 */

				} catch (IOException e) {
					// TODO Auto-generated catch block
					// System.out
					// .println("method2 erreur serialisation pour objet : "
					// + sess.getClass().getName());
					// e.printStackTrace();

				}

				try {
					oos.flush();
					fos.flush();
					sizeObject = (double) fout.length();
					oos.close();
					fos.close();
					// System.out.println("Fermeture file :"+fout.getAbsolutePath()+" reussie");
				} catch (IOException e) {
					// TODO Auto-generated catch block
					// e.printStackTrace();
				}

				// on remplit les compteurs

				// on remplit les compteurs depuis le mbean

				// httSizeMoyen
				int sessExamined = mbean.getAspectHttpSessExamined();
				int countGlobal = mbean.getAspectHttpSessTotal();
				double sizeMoyenAvant = mbean.getAspectHttpSessSizeMoy()
						* oldScale;
				double sizeMoyenApres = (sizeMoyenAvant * sessExamined + sizeObject)
						/ (sessExamined + 1);

				// httpSizeMax
				if (mbean.getAspectHttpSessSizeMax() * oldScale < sizeObject) {
					mbean.modAspectHttpSessSizeMax(sizeObject / newScale);
				}

				// sauvegarde HashMap
				sessExamined++;
				countGlobal++;
				// ecriture modification du mbean
				mbean.modAspectHttpSessSizeMoy(sizeMoyenApres / newScale);
				mbean.modAspectNumberAttributes(nbObjects);
				mbean.modAspectHttpSessExamined(sessExamined);
				mbean.modAspectHttpSessTotal(countGlobal);
				mbean.modAspectHttpSessSizeCurrent(sizeObject / newScale);
				oldScale = newScale;
				mbean.changeScale(newScale);
				hmMbean.put(name, mbean);
			}
		}
	}

}
