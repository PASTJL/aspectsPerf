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

import java.lang.management.ManagementFactory;
import java.lang.reflect.InvocationTargetException;
import java.net.URL;
import java.net.URLClassLoader;
import java.text.DecimalFormat;
import java.util.Locale;
import java.util.Properties;

import javax.management.InstanceAlreadyExistsException;
import javax.management.MBeanRegistrationException;
import javax.management.MBeanServer;
import javax.management.MalformedObjectNameException;
import javax.management.NotCompliantMBeanException;
import javax.management.ObjectName;

import jlp.aspectsJMX.mbean.CommonPoolApache;

aspect ConcreteCommonPoolApache {

	private static int frequenceMeasure = 1;
	private static Properties props;
	
	public static int freqCount = 0;
	public static int nbBorrow = 0;

	// Counter 1 => moyenne size
	// Counter 2 => maximum size
	// Counter 3 => session examined

	public static DecimalFormat df;
	public static double oldScale = 1;
	static CommonPoolApache mbean;
	private static MBeanServer mbs;
	static String addClasspath = "";
	static URL[] tabURL = null;
	static URLClassLoader myClassLoader;
	static Class clazz = null;
	
	static {
		Locale.setDefault(Locale.ENGLISH);
		df = new DecimalFormat("#####0.000");

		props = jlp.perf.aspects.abstractAspects.AspectsPerfProperties.aspectsPerfProperties;
		;

		if (props
				.containsKey("jlp.aspectsJMX.concreteAspects.ConcreteCommonPoolApache.frequenceMeasure")) {
			frequenceMeasure = Integer
					.parseInt(props
							.getProperty("jlp.aspectsJMX.concreteAspects.ConcreteCommonPoolApache.frequenceMeasure"));

		}


		mbs = ManagementFactory.getPlatformMBeanServer();
		ObjectName name;
		try {
			name = new ObjectName(
					"AspectsConcrete:type=concreteCommonPoolApache");
			mbean = new CommonPoolApache();
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

		mbean.modAspectBorrowedFrequency(frequenceMeasure);
		
	}

	public final synchronized void modifierMBean(Object obj, int i) {
		// i vaut 1 a l'allocation et 0 au retour du pool
		int borrowedExamined = mbean.getAspectBorrowedExamined();
		double sizeMoyenAvant = mbean.getAspectBorrowedMoy();
		int idle = 0;
		long millis = 0;
		try {
			nbBorrow = (Integer) obj.getClass().getMethod("getNumActive",
					(Class[]) null).invoke(obj, (Object[]) null);
			idle = (Integer) obj.getClass().getMethod("getNumIdle",
					(Class[]) null).invoke(obj, (Object[]) null);
			millis = (Long) obj.getClass().getMethod(
					"getTimeBetweenEvictionRunsMillis", (Class[]) null).invoke(
					obj, (Object[]) null);
		} catch (IllegalArgumentException e) {
			System.out.println("ConcreteCommonPoolApache :" + e.getMessage());
			return;

			
		} catch (SecurityException e) {
			System.out.println("AspectJ LTW => ConcreteCommonPoolApache :"
					+ e.getMessage());
			return;
		} catch (IllegalAccessException e) {
			System.out.println("AspectJ LTW => ConcreteCommonPoolApache :"
					+ e.getMessage());
			return;
		} catch (InvocationTargetException e) {
			System.out.println("AspectJ LTW => ConcreteCommonPoolApache :"
					+ e.getMessage());
			return;
		} catch (NoSuchMethodException e) {
			System.out.println("AspectJ LTW => ConcreteCommonPoolApache :"
					+ e.getMessage());
			return;
		}
		double borrowedMoyenApres = (sizeMoyenAvant * borrowedExamined + nbBorrow
				* i)
				/ (borrowedExamined + i);
		if (mbean.getAspectBorrowedMax() < nbBorrow) {
			mbean.modAspectBorrowedMax(nbBorrow);
		}
		mbean.modAspectBorrowedMoy(borrowedMoyenApres);
		mbean.modAspectCurrentBorrowed(nbBorrow);

		mbean.modAspectCurrentIdle(idle);
		mbean.modAspectCurrentPoolSize(idle + nbBorrow);
		mbean.modAspectBorrowedExamined(borrowedExamined + i);

		mbean.modAspectTimeBetweenEvictionRunsMillis(millis);

	}

	public final pointcut methods(): 
		
		 execution ( public * org.apache.commons.pool..*.borrowObject(..)) ||
		 execution ( public * org.apache.commons.pool..*.returnObject(Object,..));

	after(): methods() 
	{

		if (mbean.isActivated()) {

			synchronized (this) {

				freqCount++;

				if (freqCount >= frequenceMeasure) {
					freqCount = 0;
					Object obj = thisJoinPoint.getThis();
					if (null != obj) {
						if (thisJoinPoint.getSignature().getName().contains(
								"returnObject")) {
							
							modifierMBean(obj, 0);
						} else {
							
							modifierMBean(obj, 1);
						}

					}
				}
			}

		}
	}

}
