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
import java.util.regex.Matcher;
import java.util.regex.Pattern;


public abstract aspect AbstractCPUDurationSimpleMethodWithParentAndSignaturePerThis perthis(methods()){
	private static String fileTrace = "";
	private long deb = 0;
	private long fin =0;
	private long cput = 0;
	private double cpuperc=0;
	private double cpuUserDeb = 0;
	private double cpupercUser;
	private boolean isWeavable = false;
	private String called ;
	private StringBuilder caller ;
	private static jlp.perf.aspects.abstractAspects.Trace outDurationMethods;
	private static double durationMini = 0;
	private static Properties props;
	private static String dirLogs, sep = ";";
	private static ThreadMXBean tMB = null;
	private static boolean supports = false;
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
			supports = true;
			System.out
					.println("AbstractCPUDurationSimpleMethodWithParentAndSignaturePerThis . Supports CPU Time for all Threads ");
		} else {
			System.out
					.println("AbstractCPUDurationSimpleMethodWithParentAndSignaturePerThis . Don t Supports CPU Time for all Threads ");
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
				.containsKey("jlp.perf.aspects.abstractAspects.AbstractCPUDurationSimpleMethodWithParentAndSignaturePerThis.filelogs")) {
			fileTrace = dirLogs
					+ props.getProperty("jlp.perf.aspects.abstractAspects.AbstractCPUDurationSimpleMethodWithParentAndSignaturePerThis.filelogs");
		} else {
			fileTrace = props.getProperty("aspectsPerf.default.filelogs");
		}

		System.out
				.println("AbstractCPUDurationSimpleMethodWithParentAndSignaturePerThis fichier trace = "
						+ fileTrace);
		outDurationMethods = new Trace("####time" + sep + "class.methodCalled"
				+ sep + "class.methodCaller" + sep
				+ "method Time Duration in millis(ms)" + sep
				+ "CPU time method in millis(ms)" + sep + "%CPU Global" + sep
				+ "%CPU User\n", fileTrace);
		/*
		 * outDurationMethods .append(new StringBuilder(
		 * "####time;Class.methods;time in millisecondes\n") .toString());
		 */

		durationMini = Double
				.parseDouble(props
						.getProperty(
								"jlp.perf.aspects.abstractAspects.AbstractCPUDurationSimpleMethodWithParentAndSignaturePerThis.durationMini",
								"0"));
	}

	// The pointcut must be a call type pointcut not an execution pointcut.
	public abstract pointcut methods();

	before(): methods()	 {
		
		if (supports || tMB.isCurrentThreadCpuTimeSupported()) {
			if (!supports) {
				tMB.setThreadCpuTimeEnabled(true);
			}
			isWeavable = true;
			
			deb = System.nanoTime();
		
			 called = simpleSignature(thisJoinPointStaticPart
						.getSignature().toLongString());
				System.out.println("before coucou1");
				 caller = new StringBuilder();
				if (null != thisEnclosingJoinPointStaticPart.getSourceLocation()) {
					System.out.println("before coucou2");
					caller = caller
							.append(simpleSignature(thisEnclosingJoinPointStaticPart
									.getSignature().toLongString()));
					System.out.println("before coucou3");
				} else {
					caller = caller.append("null");

				}
		}
	}

	after(): methods()	 {
		
		if(isWeavable)
		{
		cpuUserDeb = tMB.getCurrentThreadUserTime();
		 cpuperc = -1;
	
		
		cput = tMB.getCurrentThreadCpuTime();

		fin = System.nanoTime();
		
		double duree = fin - deb;
		if (duree >= this.durationMini * 1000000) {
			long cputFin = tMB.getCurrentThreadCpuTime();
			long cpuUserFin = tMB.getCurrentThreadUserTime();

			double dureeCPU = cputFin - cput;
			double dureeCPUUser = cpuUserFin - cpuUserDeb;
			System.out.println("after coucou3");
			if (duree == 0) {
				cpuperc = -1;
				cpupercUser = -1;
			} else {
				cpuperc = Math.min(1.0,
						(double) ((double) dureeCPU / (double) duree));
				cpupercUser = Math.min(1.0,
						(double) ((double) dureeCPUUser / (double) duree));
			}

			System.out.println("after coucou4");
			outDurationMethods.append(new StringBuilder(outDurationMethods
					.getSdf().format(Calendar.getInstance().getTime()))
					.append(sep).append(called)

					.append(sep).append(caller)

					.append(sep).append(df.format(duree / 1000000)).append(sep)
					.append(df.format(dureeCPU / 1000000)).append(sep)
					.append(dfPercent.format(100 * cpuperc)).append(sep)
					.append(dfPercent.format(100 * cpupercUser)).append("\n")
					.toString());

			// outDurationMethods.flush();
		}
		}

	}

	private String simpleSignature(String str) {
		StringBuilder retour = new StringBuilder();

		// Prendre que le 3 ieme champ separe par des \s
		// System.out.println("Entree simpleSignature str=" + str);
		Pattern pat = Pattern.compile("[^\\s]+?\\([^\\)]*\\)");
		Matcher match = pat.matcher(str);
		if (match.find()) {

			String strTmp = match.group();
			// System.out.println("strTmp simpleSignature strTmp=" + strTmp);
			// extraire les parametres des parantheses
			retour.append(strTmp.substring(0, strTmp.indexOf("(")));

			String params = strTmp.substring(strTmp.indexOf("(") + 1,
					strTmp.indexOf(")"));
			if (params.length() != 0) {
				StringBuilder strB = new StringBuilder();
				// reduire la taille en penant les cararteres apres le dernier
				// point
				if (params.contains(",")) {
					String[] tabString = params.trim().split(",");

					for (int i = 0, len = tabString.length; i < len; i++) {
						if (tabString[i].contains(".")) {
							strB.append("_").append(
									tabString[i].substring(tabString[i]
											.lastIndexOf(".") + 1));
						} else {
							strB.append("_").append(tabString[i].trim());
						}
					}
					retour.append(strB);
				} else {
					// 1 seul param
					if (params.contains(".")) {
						strB.append("_").append(
								params.substring(params.lastIndexOf(".") + 1));
					} else {
						strB.append("_").append(params.trim());
					}
					retour.append(strB);
				}
			}
		} else {
			retour.append(str);
		}
		return retour.toString();
	}
}
