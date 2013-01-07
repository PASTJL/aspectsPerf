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

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.lang.management.ManagementFactory;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.text.DecimalFormat;
import java.util.Locale;
import java.util.Properties;

import javax.management.InstanceAlreadyExistsException;
import javax.management.MBeanRegistrationException;
import javax.management.MBeanServer;
import javax.management.MalformedObjectNameException;
import javax.management.NotCompliantMBeanException;
import javax.management.ObjectName;

import jlp.aspectsJMX.mbean.JPACacheFirstLevelSize;
import jlp.helper.SizeOf;

public aspect ConcreteJPACacheFirstLevelSize {

	private static int frequenceMeasure = 1;
	private static Properties props;

	public static int freqCount = 0;

	static private int countGlobal = 0;

	public static DecimalFormat df;
	public static double oldScale = 1;
	static JPACacheFirstLevelSize mbean;
	static MBeanServer mbs;
	public static boolean serialization = true;
	public static boolean boolYetChecked = false;
	public static boolean boolNativeMethod = false;
	static {
		Locale.setDefault(Locale.ENGLISH);
		df = new DecimalFormat("#####0.000");

		props = jlp.perf.aspects.abstractAspects.AspectsPerfProperties.aspectsPerfProperties;

		if (props
				.containsKey("jlp.aspectsJMX.concreteAspects.ConcreteJPACacheFirstLevelSize.frequenceMeasure")) {
			frequenceMeasure = Integer
					.parseInt(props
							.getProperty("jlp.aspectsJMX.concreteAspects.ConcreteJPACacheFirstLevelSize.frequenceMeasure"));

		}
		serialization = Boolean
				.parseBoolean(props
						.getProperty(
								"jlp.aspectsJMX.concreteAspects.ConcreteJPACacheFirstLevelSize.serialization",
								"true"));

		mbs = ManagementFactory.getPlatformMBeanServer();
		ObjectName name;
		try {
			name = new ObjectName(
					"AspectsConcrete:type=concreteJPACacheFirstLevelSize");
			mbean = new JPACacheFirstLevelSize();
			mbs.registerMBean(mbean, name);
			oldScale = mbean.getScale();
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

		mbean.modAspectJPACacheFirstLevelFrequency(frequenceMeasure);
		mbean.modSerializationActivated(serialization);
		SizeOf.setInst(org.aspectj.weaver.loadtime.Agent.getInstrumentation());
	}

	/*
	 * pointcut methods(): (execution( public *
	 * javax.persistence.EntityManager+.close()) && !cflowbelow(execution(
	 * public * javax.persistence.EntityManager+.close()))) || (execution(
	 * public * org.hibernate.Session+.close()) && !cflowbelow(execution( public
	 * * org.hibernate.Session+.close()))) ;
	 */

	public final pointcut methods(): 
		execution( public 	* org.hibernate.Session+.close())
		 && !cflowbelow(execution( public 	* org.hibernate.Session+.close()))
		 ;

	before(): methods() 
	{
		// System.out.println("Rentree dans before");

		synchronized (this) {

			freqCount++;
			countGlobal++;
			this.frequenceMeasure = (int) mbean
					.getAspectJPACacheFirstLevelFrequency();
			if (freqCount >= frequenceMeasure) {
			}
			// On trace
			freqCount = 0;

			double newScale = mbean.getScale();
			Object obj = thisJoinPoint.getThis();

			// On serialise diretement.
			// on recupere tous les parametres de la session

			int nbObjects = 1;
			double sizeObject = 0;
			// pour chaque objet on serialise
			if (mbean.isSerializationActivated()) {
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

					if (!boolYetChecked) {
						if (obj.getClass()
								.getCanonicalName()
								.equals("org.hibernate.impl.SessionImpl")) {
							boolNativeMethod = true;
							System.out.println ( "ConcreteJPACacheFirstLevelSize : Usage native classe : "+obj.getClass()
								.getCanonicalName());
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
					/*
					 * System.out.println("serialisation reussie pour objet : "
					 * + obj3.getClass().getName());
					 */

				} catch (IOException e) {
					// TODO Auto-generated catch block
					// System.out
					// .println("erreur serialisation pour objet : "
					// + obj.getClass().getName());
					// e.printStackTrace();

				}

				try {
					oos.flush();
					sizeObject = (double) ((double) baos.size());
					oos.close();
					baos.close();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					// e.printStackTrace();
				}

			} else {
				//sizeObject = SizeOf.retainedSizeOf(obj);
				sizeObject = (double) SizeOf.deepSizeOf(obj);
			}

			// on remplit les compteurs depuis le mbean
			int sessExamined = mbean.getAspectJPACacheFirstLevelExamined();

			// httSizeMoyen
			double sizeMoyenAvant = mbean.getAspectJPACacheFirstLevelSizeMoy()
					* oldScale;
			double sizeMoyenApres = (sizeMoyenAvant * sessExamined + sizeObject)
					/ (sessExamined + 1);
			/*
			 * System.out.println("sizeMoyenAvant="+sizeMoyenAvant);
			 * System.out.println("sizeMoyenApres="+sizeMoyenApres);
			 */

			// httpSizeMax
			if (mbean.getAspectJPACacheFirstLevelSizeMax() * oldScale < sizeObject) {
				mbean.modAspectJPACacheFirstLevelSizeMax(sizeObject / newScale);
			}

			// sauvegarde HashMap
			sessExamined++;

			// ecriture modification du mbean
			mbean.modAspectJPACacheFirstLevelSizeMoy(sizeMoyenApres / newScale);
			mbean.modAspectNumberAttributes(nbObjects);
			mbean.modAspectJPACacheFirstLevelExamined(sessExamined);
			mbean.modAspectJPACacheFirstLevelTotal(countGlobal);
			mbean.modAspectJPACacheFirstLevelSizeCurrent(sizeObject / newScale);
			this.oldScale = newScale;
		}

	}

}
