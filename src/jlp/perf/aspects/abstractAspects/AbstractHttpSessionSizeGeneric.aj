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

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.lang.reflect.InvocationTargetException;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.Calendar;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Locale;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

import jlp.helper.SizeOf;


public abstract aspect AbstractHttpSessionSizeGeneric {

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
	private static DecimalFormat df = new DecimalFormat("#0.000",new DecimalFormatSymbols(Locale.ENGLISH));
	private static DecimalFormat dfPercent = new DecimalFormat("#0.0",
			new DecimalFormatSymbols(Locale.ENGLISH));
	public static boolean aspectSerialization = true;
	public static String strAspectSerialization = "true";
	public static boolean boolYetChecked = false;
	public static boolean boolNativeMethod = false;
	private static String fileTrace;

	private static HashMap<String, Long> hmCounter = new HashMap<String, Long>();
	private static HashMap<String,Object> hmAttributes=new HashMap<String,Object>();
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
				.containsKey("jlp.perf.aspects.abstractAspects.AbstractHttpSessionSizeGeneric.filelogs")) {
			fileTrace = dirLogs
					+ props.getProperty("jlp.perf.aspects.abstractAspects.AbstractHttpSessionSizeGeneric.filelogs");
		} else {
			fileTrace = props.getProperty("aspectsPerf.default.filelogs");
		}
		strAspectSerialization = props
				.getProperty(
						"jlp.perf.aspects.abstractAspects.AbstractHttpSessionSizeGeneric.serialization",
						"true");
		if ("false".equals(strAspectSerialization)) {
			aspectSerialization = false;
		}

		System.out
				.println("Dans static abstractHttpSessionSizeGeneric type trace : abstractHttpSessionSizeGeneric fichier trace = "
						+ fileTrace);

		/*
		 * outDurationMethods .append(new StringBuilder(
		 * "####time;Class.methods;time in millisecondes\n") .toString());
		 */

		String strFreqLogs = props
				.getProperty(
						"jlp.perf.aspects.abstractAspects.AbstractHttpSessionSizeGeneric.frequenceMeasure",
						"1");
		if (strFreqLogs.contains("ms")) {
			isTimeFreq = true;
			frequenceMeasure = Integer.parseInt(strFreqLogs.substring(0,
					strFreqLogs.indexOf("m")));
		}

		outHttpCacheSize = new Trace("####time" + sep + "Path Session" + sep
				+ "method" + sep + "SizeCurrent in octets" + sep
				+ "Size Moy in octets" + sep + "SizeMax in Octets" + sep
				+ "Sessions Examined (1 / " + frequenceMeasure + ")" + sep
				+ "Total", fileTrace);
		SizeOf.setInst(org.aspectj.weaver.loadtime.Agent.getInstrumentation());
	}

	public final pointcut methods();

	@SuppressWarnings("unchecked")
	// execution( public *
	// org.apache.catalina.session.StandardSession.expire(boolean)) ;

	before(): methods() 
	{
		// System.out.println("Rentree dans before");

		// System.out.println(" rentree dans before advice");
		boolean canSerialize = false;
		Object sess = thisJoinPoint.getTarget();

		if (null != sess) {
			Object obj2 =null;
			int nbObjects = 0;
			String name = "nameEmpty";
			// if(sess instanceof javax.servlet.http.HttpSession)
			{
				try {

					obj2 = sess.getClass()
							.getMethod("getServletContext", (Class[]) null)
							.invoke(sess, (Object[]) null);
					//System.out.println("obj2="+obj2.getClass().getName());
					
					name = ((String) obj2.getClass()
							.getMethod("getContextPath", (Class[]) null)
							.invoke(obj2, (Object[]) null)).replaceAll("\\s+",
							"").replaceAll("/", "_");

					


				} catch (IllegalArgumentException e2) {
					System.out
							.println("AspectJ LTW => AbstractHttpSessionSizeGeneric methods :"
									+ e2.getMessage());
					return;
				} catch (SecurityException e2) {
					System.out
							.println("AspectJ LTW => AbstractHttpSessionSizeGeneric methods :"
									+ e2.getMessage());
					return;
				} catch (IllegalAccessException e2) {
					System.out
							.println("AspectJ LTW => AbstractHttpSessionSizeGeneric methods :"
									+ e2.getMessage());
					return;
				} catch (InvocationTargetException e2) {
					System.out
							.println("AspectJ LTW => AbstractHttpSessionSizeGeneric methods :"
									+ e2.getMessage());
					return;
				} catch (NoSuchMethodException e2) {
					System.out
							.println("AspectJ LTW => AbstractHttpSessionSizeGeneric methods :"
									+ e2.getMessage());
					return;
				}

				if (!hmCounter.containsKey(name)) {
					if (isTimeFreq) {
						hmCounter.put(name, (Long) System.currentTimeMillis());
					} else {
						hmCounter.put(name, (Long) 0L);
					}
				}
				if (isTimeFreq) {
					long newTime = System.currentTimeMillis();
					freqCount = (int) (newTime - hmCounter.get(name));

				} else {
					freqCount = (int) (long) hmCounter.get(name);
					hmCounter.put(name, (Long) ((long) (int) freqCount) + 1);
				}

				if (freqCount >= frequenceMeasure) {
					// On trace
					// System.out.println("Ontrace");
					if (isTimeFreq) {

						hmCounter.put(name, (Long) System.currentTimeMillis());
					} else {
						hmCounter.put(name, 0L);
					}

					// on recupere tous les parametres de la session
					double sizeObject = 0;
					
					
					synchronized (sess) {
					hmAttributes.clear();
					Enumeration<String> attrNames;
					try {
						attrNames = (Enumeration<String>) sess.getClass()
								.getMethod("getAttributeNames", (Class[]) null)
								.invoke(sess, (Object[]) null);
						while(attrNames.hasMoreElements())
						{
							String attr=(String)attrNames.nextElement();
							String[] tabParam={attr};
							hmAttributes.put(attr, sess.getClass()
								.getMethod("getAttribute", (Class<String>)String.class )
								.invoke(sess, tabParam));
						}
					
					} catch (IllegalArgumentException e2) {
						// TODO Auto-generated catch block
						e2.printStackTrace();
					} catch (SecurityException e2) {
						// TODO Auto-generated catch block
						e2.printStackTrace();
					} catch (IllegalAccessException e2) {
						// TODO Auto-generated catch block
						e2.printStackTrace();
					} catch (InvocationTargetException e2) {
						// TODO Auto-generated catch block
						e2.printStackTrace();
					} catch (NoSuchMethodException e2) {
						// TODO Auto-generated catch block
						e2.printStackTrace();
					}
					
					
					
					if (aspectSerialization) {
						// System.out.println("seraialisation true writeObject");
						ByteArrayOutputStream baos = new ByteArrayOutputStream(
								1024);
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

								boolYetChecked = true;
							}
//							System.out.println(" Serialisation Classe session="
//									+ sess.getClass().getName());
							
							// On prend tous les elements et on serialise
							Set<Map.Entry<String,Object>> en2=hmAttributes.entrySet();
							Iterator it=en2.iterator();
							while(it.hasNext())
							{
								Map.Entry<String,Object> ent=(Map.Entry<String,Object>)it.next();
								Object obj4=ent.getValue();
								if (obj4 instanceof Serializable) {
									oos.writeObject((Serializable) obj4);
								}
								else
								{
									if (new Gen(obj4).type.equals("java.lang.Boolean") ){
										
										sizeObject += 1;
									}
									else if (new Gen(obj4).type.equals("java.lang.Byte"))
									{
										sizeObject += 1;
									}
									else if (new Gen(obj4).type.equals("java.lang.Short"))
									{
										sizeObject += 2;
									}
									else if (new Gen(obj4).type.equals("java.lang.Integer"))
									{
										sizeObject += 4;
									}
									else if (new Gen(obj4).type.equals("java.lang.Long"))
									{
										sizeObject += 8;
									}
									else if (new Gen(obj4).type.equals("java.lang.Double"))
									{
										sizeObject += 8;
									}
									else if (new Gen(obj4).type.equals("java.lang.Float"))
									{
										sizeObject += 4;
									}
								}
							}
							

							/*
							 * System.out.println(
							 * "serialisation reussie pour objet : " +
							 * obj3.getClass().getName());
							 */

						} catch (IOException e) {

							// e.printStackTrace();
							// System.out
							// .println("one object at least is not serializable for context of  : "
							// + obj.getClass().getName());

						}

						try {
							oos.flush();
							sizeObject +=  (double) ((double) baos.size());
							oos.close();
							baos.close();
						} catch (IOException e) {
							// TODO Auto-generated catch block

						}

					} else {
						// System.out.println("seraialisation false deep analyse"+sess.getClass().getName());

						if (null != sess) {
//							System.out.println("Pas de serialisation Classe session="
//									+ sess.getClass().getName());
								sizeObject =0;
								Set<Map.Entry<String,Object>> en2=hmAttributes.entrySet();
								Iterator it=en2.iterator();
								while(it.hasNext())
								{
									Map.Entry<String,Object> ent=(Map.Entry<String,Object>)it.next();
									Object obj4=ent.getValue();
									//sizeObject += SizeOfNonSerializable.retainedSizeOf(obj4);
									sizeObject += (double) SizeOf.deepSizeOf(obj4);
									}
								
								
							
							// sizeObject =
							// SizeOfNonSerializable.retainedSizeOf(sess);
						}
					}
					// on remplit les compteurs depuis le mbean

					// httSizeMoyen

					if (sizeObject > 0) {
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
						String meth = thisJoinPointStaticPart.getSignature()
								.toShortString();
						// ecriture modification du mbean

						outHttpCacheSize.append(new StringBuilder(
								outHttpCacheSize.getSdf().format(
										Calendar.getInstance().getTime()))
								.append(sep).append(name).append(sep)
								.append(meth).append(sep)

								.append((long)sizeObject).append(sep)
								.append((long)sizeMoyen).append(sep).append((long)sizeMax)
								.append(sep).append(sessionExamined)
								.append(sep).append(countGlobal).append("\n")
								.toString());

					} else {
						System.out.println(" sizeObject=" + sizeObject);
					}
				}
				}
			}
		}

	}

}
class Gen<T>{
	
	public String type="";
	public Gen(T a){
		
		type=a.getClass().getName();
	}
}