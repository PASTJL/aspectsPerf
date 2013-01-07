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
import java.util.Locale;
import java.util.Properties;

public  abstract aspect AbstractCPUDurationSimpleMethod {
	private static String fileTrace = "";

	private static jlp.perf.aspects.abstractAspects.Trace outDurationMethods;
	private static double durationMini = 0;
	private static Properties props;
	private static String dirLogs, sep = ";";
	private static ThreadMXBean tMB = null;
	private static boolean supports = false;
	private static DecimalFormat df=new DecimalFormat("#0.000",new  DecimalFormatSymbols(Locale.ENGLISH));
	private static DecimalFormat dfPercent=new DecimalFormat("#0.0",new DecimalFormatSymbols(Locale.ENGLISH));
	
	static {
		Locale.setDefault(Locale.ENGLISH);
		tMB = ManagementFactory.getThreadMXBean();
		if (tMB.isThreadCpuTimeSupported()) {
			if (!tMB.isThreadCpuTimeEnabled()) {
				tMB.setThreadCpuTimeEnabled(true);
			}
			supports = true;
			System.out
					.println("AbstractCPUDurationSimpleMethods . Supports CPU Time for all Threads ");
		} else {
			System.out
					.println("AbstractCPUDurationSimpleMethods . Don t Supports CPU Time for all Threads ");
		}
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
				.containsKey("jlp.perf.aspects.abstractAspects.AbstractCPUDurationSimpleMethod.filelogs")) {
			fileTrace = dirLogs
					+ props
							.getProperty("jlp.perf.aspects.abstractAspects.AbstractCPUDurationSimpleMethod.filelogs");
		} else {
			fileTrace = props.getProperty("aspectsPerf.default.filelogs");
		}

		System.out
				.println("AbstractCPUDurationSimpleMethods fichier trace = "
						+ fileTrace);
		outDurationMethods = new Trace("####time" + sep + "class.methodCalled"
				+ sep 
				+ "method Time Duration in millis(ms)" + sep
				+ "CPU time method in millis(ms)" + sep + "%CPU Global" + sep
				+ "%CPU User\n", fileTrace);
		/*
		 * outDurationMethods .append(new StringBuilder(
		 * "####time;Class.methods;time in millisecondes\n") .toString());
		 */

		durationMini = Double
				.parseDouble(props
						.getProperty("jlp.perf.aspects.abstractAspects.AbstractCPUDurationSimpleMethod.durationMini","0"));
	}

	// The pointcut must be a call type pointcut not an execution pointcut.
	public abstract pointcut methods();

	Object around(): methods()	 {

		if (supports || tMB.isCurrentThreadCpuTimeSupported()) {
			if (!supports) {
				tMB.setThreadCpuTimeEnabled(true);
			}
			long deb = System.nanoTime();
			long cput = 0;

			long cpuUserDeb = tMB.getCurrentThreadUserTime();
			double cpuperc = -1;
			double cpupercUser = -1;

			cput = tMB.getCurrentThreadCpuTime();;;
			int noLine=0;
			if(null!=thisJoinPoint.getStaticPart().getSourceLocation())
			{
				noLine=thisJoinPoint.getStaticPart().getSourceLocation().getLine();
				
			}
			Object retour = proceed();

			long fin = System.nanoTime();
			;
			double duree = fin - deb;
			if (duree >= AbstractCPUDurationSimpleMethod.durationMini * 1000000) {
				long cputFin = tMB.getCurrentThreadCpuTime();
				long cpuUserFin = tMB.getCurrentThreadUserTime();

				double dureeCPU = cputFin - cput;
				double dureeCPUUser = cpuUserFin - cpuUserDeb;

				if (duree == 0) {
					cpuperc = -1;
					cpupercUser = -1;
				} else {
					cpuperc = Math.min(1.0,
							(double) ((double) dureeCPU / (double) duree));
					cpupercUser = Math.min(1.0,
							(double) ((double) dureeCPUUser / (double) duree));
				}
				String nameClasseMethodSource = "null";
				
				if(noLine == 0){
				outDurationMethods.append(new StringBuilder(outDurationMethods
						.getSdf().format(Calendar.getInstance().getTime()))
						.append(sep).append(
								thisJoinPointStaticPart.getSignature()
										.getDeclaringTypeName()).append(".")
						.append(
								thisJoinPointStaticPart.getSignature()
										.getName())
										.append(sep).append(df.format(
								duree / 1000000)).append(sep).append(df.format(dureeCPU/1000000))
						.append(sep).append(dfPercent.format(cpuperc*100)).append(sep).append(dfPercent.format(
								cpupercUser*100)).append("\n").toString());
				}
				else
				{
					outDurationMethods.append(new StringBuilder(outDurationMethods
							.getSdf().format(Calendar.getInstance().getTime()))
							.append(sep).append(
									thisJoinPointStaticPart.getSignature()
											.getDeclaringTypeName()).append(".")
							.append(
									thisJoinPointStaticPart.getSignature()
											.getName()).append("_line_")
											.append(noLine)
											.append(sep).append(df.format(
									duree / 1000000)).append(sep).append(df.format(dureeCPU/1000000))
							.append(sep).append(dfPercent.format(cpuperc*100)).append(sep).append(dfPercent.format(
									cpupercUser*100)).append("\n").toString());
				}
//				
				
				
				// outDurationMethods.flush();
			}
			return retour;
		} else {

			Object retour = proceed();
			return retour;

		}

	}

}
