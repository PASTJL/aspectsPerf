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
import java.lang.reflect.Method;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.Calendar;
import java.util.Locale;
import java.util.Properties;

public privileged aspect ConcreteJPACacheFirstLevelSize {

	private static long frequenceMeasure = 1;

	private static jlp.perf.aspects.abstractAspects.Trace outJPACacheSize;

	private static Properties props;
	private static String dirLogs, sep = ";";
	private static long countGlobal = 0;
	private static long sessionExamined = 0;
	public static double sizeMax = 0;
	public static double sizeMin = Double.MAX_VALUE;
	public static double sizeMoy = 0;

	public static boolean serialization = true;
	public static long freqCount = 0;
	public boolean boolWoven = false;

	// Counter 1 => moyenne size
	// Counter 2 => maximum size
	// Counter 3 => session examined

	private static DecimalFormat df = new DecimalFormat("#0.000",
			new DecimalFormatSymbols(Locale.ENGLISH));
	private static DecimalFormat dfPercent = new DecimalFormat("#0.0",
			new DecimalFormatSymbols(Locale.ENGLISH));
	public static boolean boolYetChecked = false;
	public static boolean boolNativeMethod = false;
	private static String fileTrace;
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
				.containsKey("jlp.perf.aspects.concreteAspects.ConcreteJPACacheFirstLevelSize.filelogs")) {
			fileTrace = dirLogs
					+ props.getProperty("jlp.perf.aspects.concreteAspects.ConcreteJPACacheFirstLevelSize.filelogs");
		} else {
			fileTrace = props.getProperty("aspectsPerf.default.filelogs");
		}

		System.out
				.println("Dans static ConcreteJPACacheFirstLevelSize type trace : concreteJPACacheFirstLevelSize fichier trace = "
						+ fileTrace);

		/*
		 * outDurationMethods .append(new StringBuilder(
		 * "####time;Class.methods;time in millisecondes\n") .toString());
		 */

		if (props
				.containsKey("jlp.perf.aspects.concreteAspects.ConcreteJPACacheFirstLevelSize.frequenceMeasure")) {
			frequenceMeasure = Long
					.parseLong(props
							.getProperty("jlp.perf.aspects.concreteAspects.ConcreteJPACacheFirstLevelSize.frequenceMeasure"));
		}

		serialization = Boolean
				.parseBoolean(props
						.getProperty(
								"jlp.perf.aspects.concreteAspects.ConcreteJPACacheFirstLevelSize.serialization",
								"true"));

		outJPACacheSize = new Trace("####time" + sep + "Nom class" + sep
				+ "SizeCurrent in octets" + sep + "Size Moy in octets" + sep
				+ "Size mini in octets" + sep + "SizeMax in Octets" + sep
				+ "Sessions Examined (1 / " + frequenceMeasure + ")" + sep
				+ "Total", fileTrace);
		
		// L'instrumentation aspectj ne donne pas la taille correcte
		
		SizeOf.setInst(org.aspectj.weaver.loadtime.Agent.getInstrumentation());
		
	}

	/*
	 * pointcut methods(): (execution( public *
	 * javax.persistence.EntityManager+.close()) && !cflowbelow(execution(
	 * public * javax.persistence.EntityManager+.close()))) ||( execution(
	 * public * org.hibernate.Session+.close()) && !cflowbelow(execution( public
	 * * org.hibernate.Session+.close()))) ;
	 */

	public final pointcut methods(): 
		execution(  	* org.hibernate.Session+.close())
		 || execution(  	* org.hibernate.Session+.is*())
		 ||
		execution(  	* javax.persistence.EntityManager+.close())
		|| execution(  	* javax.persistence.EntityManager+.is*());

	before(): methods() 
	{
		// System.out.println("Rentree dans before");

		synchronized (ConcreteJPACacheFirstLevelSize.this) {

			countGlobal++;
			freqCount++;
			if (freqCount >= frequenceMeasure) {
				// On trace
				freqCount = 0;

				Object obj = thisJoinPoint.getThis();

				// On serialise diretement.
				// on recupere tous les parametres de la session

				int nbObjects = 1;

				// pour chaque objet on serialise
				long sizeObject = 0;
				if (serialization) {
					ByteArrayOutputStream baos = new ByteArrayOutputStream();
					ObjectOutputStream oos = null;
					try {
						oos = new ObjectOutputStream(baos);
					} catch (IOException e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
					}

					// On serialise

					try {
						// Sic'est un objet Session Hibernate on prend le
						// serializer de Hibernate
						if (!boolYetChecked) {
							if (obj.getClass()
									.getCanonicalName()
									.equals("org.hibernate.impl.SessionImpl")) {
								boolNativeMethod = true;
//								System.out.println ( "ConcreteJPACacheFirstLevelSize : Usage native classe : "+obj.getClass()
//										.getCanonicalName());
							}
							boolYetChecked = true;
						}
						if (boolNativeMethod)  {
							try {
								Method meth = obj.getClass().getDeclaredMethod(
										"writeObject",
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
							oos.writeObject((Serializable) obj);
						}
						oos.flush();
						sizeObject = baos.size();
						oos.close();
						baos.close();
						/*
						 * System.out.println("serialisation reussie pour objet : "
						 * + obj3.getClass().getName());
						 */

					} catch (IOException e) {
						// // TODO Auto-generated catch block
						// System.out
						// .println("erreur serialisation pour objet : "
						// + obj.getClass().getName());
						// e.printStackTrace();
						sizeObject =  baos.size();
					}

					finally {
						if (null != baos) {

							try {
								baos.close();
							} catch (IOException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}

						}
						if (null != oos) {
							try {
								oos.close();
							} catch (IOException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
						}
						// e.printStackTrace();
					}
				} else {
					
					//sizeObject = SizeOf.retainedSizeOf(obj);
					sizeObject = SizeOf.deepSizeOf(obj);

//					double sizeInst=(double)SizeOf.sizeOf(obj);
//					System.out.println("sizeInst="+sizeInst);
//					System.out.println("sizeObject="+sizeObject);
//	 			System.out.println("diff deepSize-sizeInst="+(sizeObject-sizeInst));
					
					
				}
				if(sizeObject>0){
				// on remplit les compteurs depuis le mbean
				if (sizeObject > sizeMax) {
					sizeMax = sizeObject;
				}
				if (sizeObject < sizeMin) {
					sizeMin = sizeObject;
				}
				sizeMoy = (sizeMoy * sessionExamined + sizeObject)
						/ (sessionExamined + 1);

				sessionExamined++;

				// ecriture modification du mbean
				outJPACacheSize.append(new StringBuilder(outJPACacheSize
						.getSdf().format(Calendar.getInstance().getTime()))
						.append(sep)
						.append(thisJoinPoint.getThis().getClass()
								.getSimpleName()).append(sep)

						.append(df.format(sizeObject)).append(sep)
						.append(df.format(sizeMoy)).append(sep)
						.append(df.format(sizeMin)).append(sep)
						.append(df.format(sizeMax)).append(sep)
						.append(sessionExamined).append(sep)
						.append(countGlobal).append("\n").toString());
			}
			}
		}

	}

}
