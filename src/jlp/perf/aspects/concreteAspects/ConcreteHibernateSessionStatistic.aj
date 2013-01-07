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

public privileged aspect ConcreteHibernateSessionStatistic {

	private static long frequenceMeasure = 1;

	private static jlp.perf.aspects.abstractAspects.Trace outJPACacheSize;
	private static boolean statisticsEnabled = false;
	private static boolean boolsStatisticsUpdated = false;

	private static Properties props;
	private static String dirLogs, sep = ";";
	private static long countGlobal = 0;
	private static long sessionExamined = 0;
	public static double sizeMax = 0;
	public static double sizeMin = Double.MAX_VALUE;
	public static double sizeMoy = 0;

	public static boolean boolComputeSizeSession = false;
	public static boolean serialization = true;
	public static long freqCount = 0;
	public boolean boolWoven = false;

	// Counter 1 => moyenne size
	// Counter 2 => maximum size
	// Counter 3 => session examined

	private static DecimalFormat df = new DecimalFormat("#0.000",
			new DecimalFormatSymbols(Locale.ENGLISH));
	public static long nbEntityDeleteCount = 0;
	public static long nbEntityInsertCount = 0;
	public static long nbEntityLoadCount = 0;
	public static long nbEntityFetchCount = 0;;
	public static long nbEntityUpdateCount = 0;
	public static long nbQueryExecutionCount = 0;
	public static long nbQueryExecutionMaxTime = 0;
	public static long nbQueryCacheHitCount = 0;
	public static long nbQueryCacheMissCount = 0;
	public static long nbQueryCachePutCount = 0;
	public static long nbFlushCount = 0;
	public static long nbConnectCount = 0;
	public static long nbSecondLevelCacheHitCount = 0;
	public static long nbSecondLevelCacheMissCount = 0;
	public static long nbSecondLevelCachePutCount = 0;
	public static long nbSessionCloseCount = 0;
	public static long nbSessionOpenCount = 0;
	public static long nbCollectionLoadCount = 0;
	public static long nbCollectionFetchCount = 0;
	public static long nbCollectionUpdateCount = 0;
	public static long nbCollectionRemoveCount = 0;
	public static long nbCollectionRecreateCount = 0;
	public static long nbSuccessfulTransactionCount = 0;
	public static long nbTransactionCount = 0;
	public static long nbPrepareStatementCount = 0;
	public static long nbCloseStatementCount = 0;
	public static long nbOptimisticFailureCount = 0;

	private static String fileTrace;
	public static boolean boolYetChecked = false;
	public static boolean boolNativeMethod = false;
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
				.containsKey("jlp.perf.aspects.concreteAspects.ConcreteHibernateSessionStatistic.filelogs")) {
			fileTrace = dirLogs
					+ props.getProperty("jlp.perf.aspects.concreteAspects.ConcreteHibernateSessionStatistic.filelogs");
		} else {
			fileTrace = props.getProperty("aspectsPerf.default.filelogs");
		}

		System.out
				.println("Dans static ConcreteHibernateSessionStatistic type trace : ConcreteHibernateSessionStatistic fichier trace = "
						+ fileTrace);

		/*
		 * outDurationMethods .append(new StringBuilder(
		 * "####time;Class.methods;time in millisecondes\n") .toString());
		 */

		if (props
				.containsKey("jlp.perf.aspects.concreteAspects.ConcreteHibernateSessionStatistic.frequenceMeasure")) {
			frequenceMeasure = Long
					.parseLong(props
							.getProperty("jlp.perf.aspects.concreteAspects.ConcreteHibernateSessionStatistic.frequenceMeasure"));
		}
		boolComputeSizeSession = Boolean
				.parseBoolean(props
						.getProperty(
								"jlp.perf.aspects.concreteAspects.ConcreteHibernateSessionStatistic.boolComputeSizeSession",
								"false"));

		serialization = Boolean
				.parseBoolean(props
						.getProperty(
								"jlp.perf.aspects.concreteAspects.ConcreteHibernateSessionStatistic.serialization",
								"true"));

		String statistics = new StringBuffer("####time" + sep + "Nom class"
				+ sep + "SizeCurrent in octets" + sep + "Size Moy in octets"
				+ sep + "Size mini in octets" + sep + "SizeMax in Octets" + sep
				+ "Sessions Examined (1 / " + frequenceMeasure + ")" + sep
				+ "Total" + sep).append("nbEntityDeleteCount").append(sep)
				.append("nbEntityInsertCount").append(sep)
				.append("nbEntityLoadCount").append(sep)
				.append("nbEntityFetchCount").append(sep)
				.append("nbEntityUpdateCount").append(sep)
				.append("nbQueryExecutionCount").append(sep)
				.append("nbQueryExecutionMaxTime").append(sep)
				.append("nbQueryCacheHitCount").append(sep)
				.append("nbQueryCacheMissCount").append(sep)
				.append("nbQueryCachePutCount").append(sep)
				.append("nbFlushCount").append(sep).append("nbConnectCount")
				.append(sep).append("nbSecondLevelCacheHitCount").append(sep)
				.append("nbSecondLevelCacheMissCount").append(sep)
				.append("nbSecondLevelCachePutCount").append(sep)
				.append("nbSessionCloseCount").append(sep)
				.append("nbSessionOpenCount").append(sep)
				.append("nbCollectionLoadCount").append(sep)
				.append("nbCollectionFetchCount").append(sep)
				.append("nbCollectionUpdateCount").append(sep)
				.append("nbCollectionRemoveCount").append(sep)
				.append("nbCollectionRecreateCount").append(sep)
				.append("nbSuccessfulTransactionCount").append(sep)
				.append("nbTransactionCount").append(sep)
				.append("nbPrepareStatementCount").append(sep)
				.append("nbCloseStatementCount").append(sep)
				.append("nbOptimisticFailureCount").append(sep).toString();

		outJPACacheSize = new Trace(statistics, fileTrace);
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
		execution( public 	* org.hibernate.Session+.close())
		 || execution( public 	* org.hibernate.Session+.is*()) ;

	before(): methods() 
	{
		// System.out.println("Rentree dans before");

		synchronized (ConcreteHibernateSessionStatistic.this) {

			countGlobal++;
			freqCount++;
			if (freqCount >= frequenceMeasure) {
				Object obj = thisJoinPoint.getThis();
				Object obj2 = null;
				Object obj3 = null;

				if (!boolsStatisticsUpdated) {

					try {
						obj2 = obj.getClass()
								.getMethod("getFactory", (Class[]) null)
								.invoke(obj, (Object[]) null);
						obj3 = obj2.getClass()
								.getMethod("getStatistics", (Class[]) null)
								.invoke(obj2, (Object[]) null);

						statisticsEnabled = (Boolean) obj3
								.getClass()
								.getMethod("isStatisticsEnabled",
										(Class[]) null)
								.invoke(obj3, (Object[]) null);
						System.out.println("statisticsEnabled="
								+ statisticsEnabled);
					} catch (IllegalArgumentException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (SecurityException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (IllegalAccessException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (InvocationTargetException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (NoSuchMethodException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}

					boolsStatisticsUpdated = true;
				}
				// On trace
				freqCount = 0;

				double sizeObject = -1;
				if (boolComputeSizeSession) {

					// On serialise diretement.
					// on recupere tous les parametres de la session

					// pour chaque objet on serialise

					if (serialization) {
						ByteArrayOutputStream baos = new ByteArrayOutputStream();
						ObjectOutputStream oos = null;
						try {
							oos = new ObjectOutputStream(baos);
						} catch (IOException e1) {
							// TODO Auto-generated catch block
//							e1.printStackTrace();
						}

						// On serialise

						try {

							//System.out.println("joinPoint ="+obj.getClass().getCanonicalName());
							if (!boolYetChecked) {
								if (obj.getClass()
										.getCanonicalName()
										.equals("org.hibernate.impl.SessionImpl")) {
									boolNativeMethod = true;
									System.out.println ( "ConcreteHibernateSessionStatistic : Usage native classe : "+obj.getClass()
											.getCanonicalName());
								}
								boolYetChecked = true;
							}
							if (boolNativeMethod) {
								try {
									//System.out.println("Serialisation par Session Hibernate");
									Method meth=obj.getClass()
											.getDeclaredMethod("writeObject",
													java.io.ObjectOutputStream.class);
									meth.setAccessible(true);
											meth.invoke(obj, oos);
								} catch (IllegalArgumentException e) {
									// TODO Auto-generated catch block
									System.out.println("IllegalArgumentException :"+e.getMessage());
								} catch (SecurityException e) {
									// TODO Auto-generated catch block
									System.out.println("SecurityException :"+e.getMessage());
								} catch (IllegalAccessException e) {
									// TODO Auto-generated catch block
									System.out.println("IllegalAccessException  :"+e.getMessage());
								} catch (InvocationTargetException e) {
									// TODO Auto-generated catch block
									System.out.println("InvocationTargetException  :"+e.getMessage());
								} catch (NoSuchMethodException e) {
									// TODO Auto-generated catch block
									System.out.println("NoSuchMethodException  :"+e.getMessage());
								}
							} else 
							{
								oos.writeObject((Serializable) obj);
							}
							oos.flush();
							sizeObject = (double) ((double) baos.size());
							oos.close();
							baos.close();
							/*
							 * System.out.println(
							 * "serialisation reussie pour objet : " +
							 * obj3.getClass().getName());
							 */

						} catch (IOException e) {
							// TODO Auto-generated catch block
//							System.out
//									.println("erreur serialisation pour objet : "
//											+ obj.getClass().getName());
							// e.printStackTrace();
							
						}
						finally
						{
							if(null != baos)
							{
								
									try {
										baos.close();
									} catch (IOException e) {
										// TODO Auto-generated catch block
//										e.printStackTrace();
									}
								
							}
							if( null != oos)
							{
								try {
									oos.close();
								} catch (IOException e) {
									// TODO Auto-generated catch block
									
								}
							}
						}

						
					} else {
						//sizeObject = SizeOf.retainedSizeOf(obj);
						sizeObject = (double) SizeOf.deepSizeOf(obj);
					}

					// on remplit les compteurs depuis le mbean
					if (sizeObject > sizeMax) {
						sizeMax = sizeObject;
					}
					if (sizeObject < sizeMin) {
						sizeMin = sizeObject;
					}
					sizeMoy = (sizeMoy * sessionExamined + sizeObject)
							/ (sessionExamined + 1);
				} else {
					sizeMoy = -1;
					sizeMax = -1;
					sizeMin = -1;

				}
				sessionExamined++;

				if (statisticsEnabled) {

					try {
						obj2 = obj.getClass()
								.getMethod("getFactory", (Class[]) null)
								.invoke(obj, (Object[]) null);
						obj3 = obj2.getClass()
								.getMethod("getStatistics", (Class[]) null)
								.invoke(obj2, (Object[]) null);

					} catch (IllegalArgumentException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (SecurityException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (IllegalAccessException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (InvocationTargetException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (NoSuchMethodException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}

					fillStat(obj3);
				}

				// ecriture modification du mbean
				outJPACacheSize.append(new StringBuilder(outJPACacheSize
						.getSdf().format(Calendar.getInstance().getTime()))
						.append(sep)
						.append(thisJoinPoint.getThis().getClass()
								.getSimpleName()).append(sep)

						.append((long)sizeObject).append(sep)
						.append((long)(sizeMoy)).append(sep)
						.append((long)(sizeMin)).append(sep)
						.append((long)(sizeMax)).append(sep)
						.append(sessionExamined).append(sep)
						.append(countGlobal).append(sep)
						.append(nbEntityDeleteCount).append(sep)
						.append(nbEntityInsertCount).append(sep)
						.append(nbEntityLoadCount).append(sep)
						.append(nbEntityFetchCount).append(sep)
						.append(nbEntityUpdateCount).append(sep)
						.append(nbQueryExecutionCount).append(sep)
						.append(nbQueryExecutionMaxTime).append(sep)
						.append(nbQueryCacheHitCount).append(sep)
						.append(nbQueryCacheMissCount).append(sep)
						.append(nbQueryCachePutCount).append(sep)
						.append(nbFlushCount).append(sep)
						.append(nbConnectCount).append(sep)
						.append(nbSecondLevelCacheHitCount).append(sep)
						.append(nbSecondLevelCacheMissCount).append(sep)
						.append(nbSecondLevelCachePutCount).append(sep)
						.append(nbSessionCloseCount).append(sep)
						.append(nbSessionOpenCount).append(sep)
						.append(nbCollectionLoadCount).append(sep)
						.append(nbCollectionFetchCount).append(sep)
						.append(nbCollectionUpdateCount).append(sep)
						.append(nbCollectionRemoveCount).append(sep)
						.append(nbCollectionRecreateCount).append(sep)
						.append(nbSuccessfulTransactionCount).append(sep)
						.append(nbTransactionCount).append(sep)
						.append(nbPrepareStatementCount).append(sep)
						.append(nbCloseStatementCount).append(sep)
						.append(nbOptimisticFailureCount).append(sep)
						.append("\n").toString());
			}
		}

	}

	private void fillStat(Object obj3) {

		try {
			nbEntityDeleteCount = (Long) obj3.getClass()
					.getMethod("getEntityDeleteCount", (Class[]) null)
					.invoke(obj3, (Object[]) null);
			nbEntityInsertCount = (Long) obj3.getClass()
					.getMethod("getEntityInsertCount", (Class[]) null)
					.invoke(obj3, (Object[]) null);
			nbEntityLoadCount = (Long) obj3.getClass()
					.getMethod("getEntityLoadCount", (Class[]) null)
					.invoke(obj3, (Object[]) null);
			nbEntityFetchCount = (Long) obj3.getClass()
					.getMethod("getEntityFetchCount", (Class[]) null)
					.invoke(obj3, (Object[]) null);
			nbEntityUpdateCount = (Long) obj3.getClass()
					.getMethod("getEntityUpdateCount", (Class[]) null)
					.invoke(obj3, (Object[]) null);
			nbQueryExecutionCount = (Long) obj3.getClass()
					.getMethod("getQueryExecutionCount", (Class[]) null)
					.invoke(obj3, (Object[]) null);
			nbQueryExecutionMaxTime = (Long) obj3.getClass()
					.getMethod("getQueryCacheHitCount", (Class[]) null)
					.invoke(obj3, (Object[]) null);
			nbQueryCacheHitCount = (Long) obj3.getClass()
					.getMethod("getQueryCacheHitCount", (Class[]) null)
					.invoke(obj3, (Object[]) null);
			nbQueryCacheMissCount = (Long) obj3.getClass()
					.getMethod("getQueryCacheMissCount", (Class[]) null)
					.invoke(obj3, (Object[]) null);
			nbQueryCachePutCount = (Long) obj3.getClass()
					.getMethod("getQueryCachePutCount", (Class[]) null)
					.invoke(obj3, (Object[]) null);
			nbFlushCount = (Long) obj3.getClass()
					.getMethod("getFlushCount", (Class[]) null)
					.invoke(obj3, (Object[]) null);
			nbConnectCount = (Long) obj3.getClass()
					.getMethod("getConnectCount", (Class[]) null)
					.invoke(obj3, (Object[]) null);
			nbSecondLevelCacheHitCount = (Long) obj3.getClass()
					.getMethod("getSecondLevelCacheHitCount", (Class[]) null)
					.invoke(obj3, (Object[]) null);
			nbSecondLevelCacheMissCount = (Long) obj3.getClass()
					.getMethod("getSecondLevelCacheMissCount", (Class[]) null)
					.invoke(obj3, (Object[]) null);
			nbSecondLevelCachePutCount = (Long) obj3.getClass()
					.getMethod("getSecondLevelCachePutCount", (Class[]) null)
					.invoke(obj3, (Object[]) null);
			nbSessionCloseCount = (Long) obj3.getClass()
					.getMethod("getSessionCloseCount", (Class[]) null)
					.invoke(obj3, (Object[]) null);
			nbSessionOpenCount = (Long) obj3.getClass()
					.getMethod("getSessionOpenCount", (Class[]) null)
					.invoke(obj3, (Object[]) null);
			nbCollectionLoadCount = (Long) obj3.getClass()
					.getMethod("getCollectionLoadCount", (Class[]) null)
					.invoke(obj3, (Object[]) null);
			nbCollectionFetchCount = (Long) obj3.getClass()
					.getMethod("getCollectionFetchCount", (Class[]) null)
					.invoke(obj3, (Object[]) null);
			nbCollectionUpdateCount = (Long) obj3.getClass()
					.getMethod("getCollectionUpdateCount", (Class[]) null)
					.invoke(obj3, (Object[]) null);
			nbCollectionRemoveCount = (Long) obj3.getClass()
					.getMethod("getCollectionRemoveCount", (Class[]) null)
					.invoke(obj3, (Object[]) null);
			nbCollectionRecreateCount = (Long) obj3.getClass()
					.getMethod("getCollectionRecreateCount", (Class[]) null)
					.invoke(obj3, (Object[]) null);
			nbSuccessfulTransactionCount = (Long) obj3.getClass()
					.getMethod("getSuccessfulTransactionCount", (Class[]) null)
					.invoke(obj3, (Object[]) null);
			nbTransactionCount = (Long) obj3.getClass()
					.getMethod("getTransactionCount", (Class[]) null)
					.invoke(obj3, (Object[]) null);
			nbPrepareStatementCount = (Long) obj3.getClass()
					.getMethod("getPrepareStatementCount", (Class[]) null)
					.invoke(obj3, (Object[]) null);
			nbCloseStatementCount = (Long) obj3.getClass()
					.getMethod("getCloseStatementCount", (Class[]) null)
					.invoke(obj3, (Object[]) null);
			nbOptimisticFailureCount = (Long) obj3.getClass()
					.getMethod("getOptimisticFailureCount", (Class[]) null)
					.invoke(obj3, (Object[]) null);

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

		// TODO Auto-generated method stub

	}

}
