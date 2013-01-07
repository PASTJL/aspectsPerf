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

import java.io.File;
import java.lang.management.ManagementFactory;
import java.lang.management.ThreadMXBean;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.Calendar;
import java.util.Date;
import java.util.Iterator;
import java.util.Locale;
import java.util.Properties;
import java.util.Set;
import java.util.WeakHashMap;

public abstract aspect AbstractThreadCPUUsage {
	private static String fileTrace = "";

	private static jlp.perf.aspects.abstractAspects.Trace outCpuUsage;
	private static double frequency = 1; // en millis
	private static double percentMini = 50;
	private static int depthStackTrace=20;
	private static long dateInMillisStart = System.currentTimeMillis();
	private static Properties props;
	private static String dirLogs, sep = ";";
	private static ThreadMXBean tMB = null;
	private static boolean supports = false;
	private static WeakHashMap<Long, Long> hmLastCPUTime = new WeakHashMap<Long, Long>();
	private static DecimalFormat df = new DecimalFormat("#0.000",
			new DecimalFormatSymbols(Locale.ENGLISH));
	private static DecimalFormat dfPercent = new DecimalFormat("#0.0",
			new DecimalFormatSymbols(Locale.ENGLISH));

	static {
		Locale.setDefault(Locale.ENGLISH);
		tMB = ManagementFactory.getThreadMXBean();
		if (tMB.isThreadCpuTimeSupported()) {
			if (!tMB.isThreadCpuTimeEnabled()) {
				tMB.setThreadCpuTimeEnabled(true);
			}
			tMB.setThreadContentionMonitoringEnabled(true);
			supports = true;
			System.out
					.println("AbstractThreadCPUUsage . Supports CPU Time for all Threads ");
		} else {
			System.out
					.println("AbstractThreadCPUUsage . Don t Supports CPU Time for all Threads ");
		}
		props = jlp.perf.aspects.abstractAspects.AspectsPerfProperties.aspectsPerfProperties;
		if (props.containsKey("aspectsPerf.default.sep")) {
			sep = props.getProperty("aspectsPerf.default.sep", ";");
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
				.containsKey("jlp.perf.aspects.abstractAspects.AbstractThreadCPUUsage.filelogs")) {
			fileTrace = dirLogs
					+ props.getProperty("jlp.perf.aspects.abstractAspects.AbstractThreadCPUUsage.filelogs");
		} else {
			fileTrace = props.getProperty("aspectsPerf.default.filelogs");
		}

		System.out.println("AbstractThreadCPUUsage fichier trace = "
				+ fileTrace);
		outCpuUsage = new Trace("####time" + sep + "ThreadID" + sep
				+ "CPU Duration in millis(ms)" + sep + "%CPU " + sep
				+ "Stack Trace " + "\n", fileTrace);
		/*
		 * outDurationMethods .append(new StringBuilder(
		 * "####time;Class.methods;time in millisecondes\n") .toString());
		 */

		frequency = Double
				.parseDouble(props
						.getProperty(
								"jlp.perf.aspects.abstractAspects.AbstractThreadCPUUsage.frequency",
								"1"));
		percentMini = Double
				.parseDouble(props
						.getProperty(
								"jlp.perf.aspects.abstractAspects.AbstractThreadCPUUsage.percentMini",
								"50"));
		depthStackTrace = Integer
				.parseInt(props
						.getProperty(
								"jlp.perf.aspects.abstractAspects.AbstractThreadCPUUsage.depthStackTrace",
								"20"));
	}

	// The pointcut must be a call type pointcut not an execution pointcut.
	public abstract pointcut methods();

	Object around(): methods()	 {

		// Verification de la periode
		long currentTime = System.currentTimeMillis();
		long delta = currentTime - dateInMillisStart;
		Object ret = null;
		if (delta > frequency ) {
			synchronized (this) {

				Date dateCurrent = Calendar.getInstance().getTime();
				ret = proceed();
				// on traite
				// recuperation de tous les threadId

				long[] tids = tMB.getAllThreadIds();
				// Pour chaque Id on verifie qu'il est dans le WeakHashMap,
				// sinon on
				// l'ajoute

				for (long tid : tids) {
					StringBuilder strB = new StringBuilder();
					Long oldThreadCpuTime = 0L;
					if (!hmLastCPUTime.containsKey(tid)) {
						oldThreadCpuTime = tMB.getThreadCpuTime(tid);
						hmLastCPUTime.put(tid, oldThreadCpuTime);

					} else {
						oldThreadCpuTime = hmLastCPUTime.get(tid);
					}
					long newThreadCpuTime = tMB.getThreadCpuTime(tid);
					hmLastCPUTime.put(tid, newThreadCpuTime);
					double percentCpu = (double) (newThreadCpuTime - oldThreadCpuTime)
							* 100 /(1000000 * delta);
					if (percentCpu > percentMini) {
						// on complete le StringBuilder
						StringBuilder stackTrace = new StringBuilder("");

						StackTraceElement[] tabStackTrace = tMB.getThreadInfo(
								tid, depthStackTrace).getStackTrace();
						if (null == tabStackTrace || tabStackTrace.length == 0) {
							strB.append(
									outCpuUsage.getSdf().format(dateCurrent))
									.append(sep).append(tid).append(sep)
									.append((newThreadCpuTime/1000000)).append(sep)
									.append(percentCpu).append(sep)
									.append("No Stack Trace available")
									.append("\n");
							outCpuUsage.append(strB.toString());
						} else

						{
							for (StackTraceElement elem : tabStackTrace) {
								stackTrace.append(elem.toString())
										.append(" | ");
							}
							strB.append(
									outCpuUsage.getSdf().format(dateCurrent))
									.append(sep).append(tid).append(sep)
									.append(newThreadCpuTime/1000000).append(sep)
									.append(percentCpu).append(sep)
									.append(stackTrace.toString()).append("\n");
							outCpuUsage.append(strB.toString());
						}
					}
				}
				dateInMillisStart = currentTime;

				// nettoyage hmLastCPUTime
				Set<Long> kSet = hmLastCPUTime.keySet();
				Iterator<Long> it = kSet.iterator();
				while (it.hasNext()) {
					Long lg = (Long) it.next();

					boolean trouve = false;
					for (long tid : tids) {
						if (tid == lg) {
							trouve = true;
						}
					}
					if (!trouve)
						hmLastCPUTime.put(lg, null);
				}
			}
		} else {
			ret = proceed();
		}

		return ret;
	}

}
