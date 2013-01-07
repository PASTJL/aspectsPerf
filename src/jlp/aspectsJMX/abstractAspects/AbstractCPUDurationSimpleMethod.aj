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
package jlp.aspectsJMX.abstractAspects;



import java.util.HashMap;
import java.util.Locale;

import java.lang.management.ManagementFactory;
import java.lang.management.ThreadMXBean;


import javax.management.InstanceAlreadyExistsException;
import javax.management.MBeanRegistrationException;
import javax.management.MBeanServer;
import javax.management.MalformedObjectNameException;
import javax.management.NotCompliantMBeanException;
import javax.management.ObjectName;



import jlp.aspectsJMX.mbean.DurationMethodsCPU;





public abstract aspect AbstractCPUDurationSimpleMethod {

			
	private boolean supports = false;
	private static HashMap<String, DurationMethodsCPU> hmBean = new HashMap<String, DurationMethodsCPU>();

	private ObjectName name;
	
	static ThreadMXBean tMB = null;
	static MBeanServer mbs = null;
	static {
		tMB = ManagementFactory.getThreadMXBean();
		Locale.setDefault(Locale.ENGLISH);
		mbs = ManagementFactory.getPlatformMBeanServer();
		/*
		 * outDurationMethods .append(new StringBuffer(
		 * "####time;Class.methods;time in millisecondes\n") .toString());
		 */

	}

	// The pointcut must be a call type pointcut not an execution pointcut.
	public abstract pointcut methods();

	Object around(): methods()	 {
		long deb = 0;
		long cput = 0;

		if (supports || tMB.isCurrentThreadCpuTimeSupported()) {
			if (!supports) {
				tMB.setThreadCpuTimeEnabled(true);
			}

			// System.out.println("AbstractCPUDurationSimpleMethodPerthis : Poincut arround");
			String type = thisJoinPointStaticPart.getSignature()
					.getDeclaringTypeName();
			String nameMethod = thisJoinPointStaticPart.getSignature()
					.getName();
			String noLine="0";
			if(null!=thisJoinPoint.getSourceLocation())
			{
				noLine=Integer.toString(thisJoinPoint.getSourceLocation().getLine());
			}
			
			
			String strObjName = new StringBuilder(
					"DurationMethodsInMilisSecondes:type=").append(type)
					.append(".").append(nameMethod)
					.append("_line")
					.append(noLine)
					.toString();
			DurationMethodsCPU mbean = null;
			synchronized (hmBean) {
				if (!hmBean.containsKey(strObjName)) {
					// ajout de la clé

					// creation et enregistrement du MBean

					try {
						name = new ObjectName(strObjName);
						mbean = new DurationMethodsCPU();
						hmBean.put(strObjName, mbean);
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

				} else {
					mbean = hmBean.get(strObjName);
				}
			}

			deb = System.nanoTime();

			long cpuUserDeb = tMB.getCurrentThreadUserTime();

			cput = tMB.getCurrentThreadCpuTime();

			Object retour = proceed();

			long fin = System.nanoTime();
			;
			// Les temps sont calcules en nanosecondes; mais visualioses en
			// milli-secondes
			double duree = (double) (fin - deb) / 1000000D;
			

			long cputFin = tMB.getCurrentThreadCpuTime();
			long cpuUserFin = tMB.getCurrentThreadUserTime();

			double dureeCPU = (double) (cputFin - cput) / 1000000D;
			double dureeCPUUser = (double) (cpuUserFin - cpuUserDeb) / 1000000D;

			// Traiter les max
			if (mbean.getAspectDurationTimeMax() < duree) {
				mbean.modAspectDurationTimeMax(duree);
			}
			if (mbean.getAspectDurationTimeMini() > duree) {
				mbean.modAspectDurationTimeMini(duree);
			}
			if (mbean.getAspectDurationCPUUserMax() < dureeCPUUser) {
				mbean.modAspectDurationCPUUserMax(dureeCPUUser);
			}
			if (mbean.getAspectDurationCPUSysUserMax() < dureeCPU) {
				mbean.modAspectDurationCPUSysUserMax(dureeCPU);
			}
			long compteur = mbean.getAspectCounterExec();
			// traiter les moy
			mbean
					.modAspectDurationTimeMoy((mbean.getAspectDurationTimeMoy() * compteur + duree)
							/ (compteur + 1));
			mbean.modAspectDurationCPUSysUserMoy((mbean.getAspectDurationCPUSysUserMoy()
					* compteur + dureeCPU)
					/ (compteur + 1));
			mbean.modAspectDurationCPUUserMoy((mbean.getAspectDurationCPUUserMoy()
					* compteur + dureeCPUUser)
					/ (compteur + 1));

			// Valeurs courantes
			mbean.modAspectDurationCPUSysUserCurrent(dureeCPU);
			mbean.modAspectDurationCPUUserCurrent(dureeCPUUser);
			mbean.modAspectDurationTimeCurrent(duree);
			mbean.modAspectCounterExec(mbean.getAspectCounterExec() + 1);
			// outDurationMethods.flush();
			
			return retour;
		}

		else {

			Object retour = proceed();
			return retour;

		}

	}
}
