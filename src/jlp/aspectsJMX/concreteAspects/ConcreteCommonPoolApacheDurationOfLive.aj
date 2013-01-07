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
import java.lang.management.ManagementFactory;
import java.text.DecimalFormat;
import java.util.Locale;
import java.util.Properties;
import java.util.WeakHashMap;

import javax.management.InstanceAlreadyExistsException;
import javax.management.MBeanRegistrationException;
import javax.management.MBeanServer;
import javax.management.MalformedObjectNameException;
import javax.management.NotCompliantMBeanException;
import javax.management.ObjectName;

import jlp.aspectsJMX.mbean.CommonPoolApacheDurationOfLive;
import jlp.helper.SizeOf;

aspect ConcreteCommonPoolApacheDurationOfLive {

	private static int frequenceMeasure = 1;
	private static Properties props;

	public static int freqCount = 0;

	private static WeakHashMap<Object, Long> objectHashMap = new WeakHashMap<Object, Long>();
	public static DecimalFormat df;
	public static double oldScale = 1;
	static CommonPoolApacheDurationOfLive mbean;
	static MBeanServer mbs;
	public static boolean serialization=true;
	static {
		Locale.setDefault(Locale.ENGLISH);
		df = new DecimalFormat("#####0.000");

		props = jlp.perf.aspects.abstractAspects.AspectsPerfProperties.aspectsPerfProperties;
		;

		if (props
				.containsKey("jlp.aspectsJMX.concreteAspects.ConcreteCommonPoolApacheDurationOfLive.frequenceMeasure")) {
			frequenceMeasure = Integer
					.parseInt(props
							.getProperty("jlp.aspectsJMX.concreteAspects.ConcreteCommonPoolApacheDurationOfLive.frequenceMeasure"));

		}

		mbs = ManagementFactory.getPlatformMBeanServer();
		ObjectName name;
		try {
			name = new ObjectName(
					"AspectsConcrete:type=concreteCommonPoolApacheDurationOfLive");
			mbean = new CommonPoolApacheDurationOfLive();
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
		serialization=Boolean.parseBoolean(props
							.getProperty("jlp.aspectsJMX.concreteAspects.ConcreteCommonPoolApacheDurationOfLive.serialization","true"));
		mbean.modSizeSerializationActivated(serialization);
		mbean.modAspectBorrowedFrequency(frequenceMeasure);

	}

	public final synchronized void modifierMBean(long duration, Object obj) {
		int examined = mbean.getAspectExamined();
		double durationMoyenAvant = mbean.getAspectDurationMoy();
		long durationMaxAvant = mbean.getAspectDurationMax();
		int idle = 0;
		long millis = 0;

		double durationMoyenApres = (durationMoyenAvant * examined + duration)
				/ (examined + 1);
		if (durationMaxAvant < duration) {
			mbean.modAspectDurationMax(duration);
		}

		mbean.modAspectDurationMoy(durationMoyenApres);

		mbean.modAspectCurrentDuration(duration);

		mbean.modAspectExamined(examined + 1);
		double sizeObject = -1;
		if (mbean.isSizeSerializationActivated()) {
			
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

				oos.writeObject(obj);
				/*
				 * System.out.println("serialisation reussie pour objet : " +
				 * obj3.getClass().getName());
				 */

			} catch (IOException e) {
				// TODO Auto-generated catch block
				System.out.println("methods erreur serialisation pour objet : "
						+ obj.getClass().getName());
				// e.printStackTrace();

			}

			try {
				oos.flush();
				sizeObject = (double) ((double) baos.size());
				oos.close();
				baos.close();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

			

		}
		else
		{
		//	sizeObject = SizeOf.retainedSizeOf(obj);
			sizeObject = (double) SizeOf.deepSizeOf(obj);
		}
		mbean.modAspectSizeObject(sizeObject);
		if (mbean.getAspectSizeMax() < sizeObject) {
			mbean.modAspectSizeMax(sizeObject);
		}

	}

 public final	pointcut methods(): 
		
		 execution ( public * org.apache.commons.pool..*.borrowObject()) ;

public final 	pointcut methods2(): 	 
		 
		 execution ( public * org.apache.commons.pool..*.returnObject(Object));

	after() returning (Object objParam): methods( ) 
	{

		

			synchronized (this) {

				freqCount++;

				if (freqCount >= frequenceMeasure) {
					freqCount = 0;

					objectHashMap.put(objParam, new Long(System
							.currentTimeMillis()));

				}
			}
		

	}

	before(): methods2()
	{
		Object objParam = thisJoinPoint.getArgs()[0];
		if (objectHashMap.containsKey(objParam) && null!=objectHashMap.get(objParam) ) {
			long duration = System.currentTimeMillis()
					- objectHashMap.get(objParam);
			modifierMBean(duration, objParam);

			// Peut-être a supprimer
			 objectHashMap.put(objParam,null);
		}
	}

}
