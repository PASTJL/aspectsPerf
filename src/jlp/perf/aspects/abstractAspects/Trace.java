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

import java.io.BufferedWriter;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Locale;
import java.util.Observable;
import java.util.Observer;
import java.util.zip.GZIPOutputStream;

import sun.misc.Signal;
import sun.misc.SignalHandler;

public class Trace implements Observer, Runnable {
	// private PrintWriter myPrintWriter;
	private String fileLogs = null;
	private String title = "###Title;of;FileLogs";
	private BufferedWriter buffOut = null;
	private SimpleDateFormat sdf = new SimpleDateFormat(
			"yyyy/MM/dd HH:mm:ss.SSS");
	public boolean isZipped = false;
	public FileOutputStream fos = null;
	public GZIPOutputStream gzOs = null;
	private static Runtime runtime = Runtime.getRuntime();
	public static MySignalHandler sh = new MySignalHandler();
	public boolean exiting = false;
	public String signalCourant = "NONE";

	public Trace(String title, String nomFileLogs) {

		Locale.setDefault(Locale.ENGLISH);
		this.title = title;
		System.out
				.println("[Instrumentation Aspects by AspectsPerf ] Deb Creation Trace os.name = "
						+ System.getProperty("os.name").toUpperCase());

		fileLogs = nomFileLogs;

		int i = nomFileLogs.lastIndexOf(".");
		SimpleDateFormat sdf2 = new SimpleDateFormat("yyyyMMdd_HHmmss");
		String dateF = sdf2.format(Calendar.getInstance().getTime());
		nomFileLogs = nomFileLogs.substring(0, i) + "_" + dateF + "."
				+ nomFileLogs.substring(i + 1);
		System.out.println(Version.version);
		System.out
				.println("[Instrumentation Aspects by AspectsPerf ] jlp.perf.aspects.abstractAspects.Trace nomFileLogs =  "
						+ nomFileLogs);
		System.out
				.println("[Instrumentation Aspects by AspectsPerf ] jlp.perf.aspects.abstractAspects.Trace title =  "
						+ title);
		try {

			if ("false".equals(AspectsPerfProperties.aspectsPerfProperties
					.getProperty("aspectsPerf.default.filegzip"))) {
				// myPrintWriter=new PrintWriter(new BufferedWriter(new
				// FileWriter(nomFileLogs,true)));
				buffOut = new BufferedWriter(new FileWriter(nomFileLogs, true));
				isZipped = false;
			} else {

				fos = new FileOutputStream(nomFileLogs + ".gz", true);
				isZipped = true;
				// myPrintWriter=new PrintWriter(new BufferedWriter (new
				// OutputStreamWriter( new GZIPOutputStream(fos))));
				gzOs = new GZIPOutputStream(fos);
				buffOut = new BufferedWriter(new OutputStreamWriter(gzOs));

			}

			if (null == buffOut) {
				System.out.println("buffOut is null");
			}
			// append(title+"\n");
			if (null != buffOut) {
				try {

					buffOut.write(title + "\n");

				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			} else {
				System.out.println("Ecriture KO, buffOut is null");
			}

			if (AspectsPerfProperties.aspectsPerfProperties
					.containsKey("aspectsPerf.handleSignal")) {
				String signal = AspectsPerfProperties.aspectsPerfProperties
						.getProperty("aspectsPerf.handleSignal");
				if (!"NONE".equals(signal)) {
					signalCourant = signal;

					// sh.handleSignal(signal);
					if (null == sh) {
						System.out.println("sh est null");
					} else {
						System.out.println("sh n est pas null");
					}
					sh.setMyTrace(this);
					System.out.println("Before handle signal");
					sh.handleSignal(signal);
					System.out.println("After handle signal");
					sh.addObserver(this);
					System.out
							.println("[Instrumentation Aspects by AspectsPerf ] Signal Handler initialized by signal : |"
									+ signal + "|");
				}
			}

		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		runtime.addShutdownHook(new Thread(this));

	}

	public final synchronized void reouverture() {
		try {
			int i = this.fileLogs.lastIndexOf(".");
			SimpleDateFormat sdf2 = new SimpleDateFormat("yyyyMMdd_HHmmss");
			String dateF = sdf2.format(Calendar.getInstance().getTime());
			String nomFileLogs = this.fileLogs.substring(0, i) + "_" + dateF
					+ "." + this.fileLogs.substring(i + 1);
			if ("false".equals(AspectsPerfProperties.aspectsPerfProperties
					.getProperty("aspectsPerf.default.filegzip"))) {
				// myPrintWriter=new PrintWriter(new BufferedWriter(new
				// FileWriter(nomFileLogs,true)));
				buffOut = new BufferedWriter(new FileWriter(nomFileLogs, true));
				isZipped = false;
			} else {
				fos = new FileOutputStream(nomFileLogs + ".gz", true);
				isZipped = true;
				// myPrintWriter=new PrintWriter(new BufferedWriter (new
				// OutputStreamWriter( new GZIPOutputStream(fos))));
				gzOs = new GZIPOutputStream(fos);
				buffOut = new BufferedWriter(new OutputStreamWriter(gzOs));

			}
			append(title + "\n");

		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public final synchronized void append(String myString) {
		// myPrintWriter.write(myString);

		if (null != buffOut) {
			try {

				buffOut.write(myString);

			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		} else {
			// reouverture
			/*
			 * reouverture(); try{ buffOut.write(myString); flush(); } catch
			 * (IOException e) { // TODO Auto-generated catch block
			 * e.printStackTrace(); }
			 */
		}
	}

	public final synchronized void flush() {
		// myPrintWriter.flush();
		try {
			//
			if (isZipped )gzOs.flush();
			buffOut.flush();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public  final SimpleDateFormat getSdf() {
		return sdf;
	}

	public final void setSdf(SimpleDateFormat sdf) {
		this.sdf = sdf;
	}

	public final BufferedWriter getBuffOut() {
		return buffOut;
	}

	public final void setBuffOut(BufferedWriter buffOut) {
		this.buffOut = buffOut;
	}

	public void run() {
		System.out.println(Version.version);
		System.out
				.println("[Instrumentation Aspects by AspectsPerf ] Received a control C");
		System.out
				.println("[Instrumentation Aspects by AspectsPerf ] Closing all OutpuStreams");
		try {
			if (null != buffOut) {
				buffOut.flush();
				buffOut.close();
				buffOut = null;
				Thread.sleep(500);
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	public final synchronized void update(final Observable o, final Object arg) {
		// use the same method that the Timer employs to trigger a
		// rotation, which ensures that signal and timer don't screw
		// each other up.
		System.out.println(Version.version);
		System.out
				.println("[Instrumentation Aspects par AspectsPerf ] Received signal: "
						+ arg);
		if (this.signalCourant.equals("NONE")) {
			// on ne fait rien on continue
			return;
		}
		if (!this.signalCourant.equals(((Signal) arg).getName())) {
			// on ne fait rien on continue
			return;
		}
		try {
			if (null != buffOut) {
				buffOut.close();
				buffOut = null;
				Thread.sleep(10);
				System.out.println(Version.version);
				System.out
						.println("[Instrumentation Aspects by AspectsPerf ] Closing all streams and re-opening new OutPutStreams");

			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		if (System.getProperty("os.name").toUpperCase().indexOf("WINDOW") >= 0) {
			System.out
					.println("[Instrumentation Aspects by AspectsPerf ]Continue (O/N or Y/N) : ?");
			int read1 = 0;
			try {
				read1 = System.in.read();
				while (!exiting && (System.in.read()) != (int) '\n') {
					Thread.sleep(100);
				}
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			if (read1 != (int) 'O' && read1 != 'o' && read1 != (int) 'Y'
					&& read1 != 'y') {
				exiting = true;
				System.exit(0);
			} else {
				if (!exiting) {
					reouverture();
				}
			}

		} else {
			reouverture();
		}

	}

}

class MySignalHandler extends Observable implements sun.misc.SignalHandler {
	private SignalHandler oldHandler;

	private Trace myTrace;

	public final Trace getMyTrace() {
		return myTrace;
	}

	public final void setMyTrace(Trace myTrace) {
		this.myTrace = myTrace;
	}

	// public static MySignalHandler install(Trace _myTrace,String signalName)
	public final void handleSignal(final String signalName)
			throws IllegalArgumentException {
		try {

			// sun.misc.Signal.handle(new sun.misc.Signal(signalName), this);
			// sun.misc.Signal.handle(new sun.misc.Signal(signalName),
			// myHandler);
			sun.misc.Signal.handle(new sun.misc.Signal(signalName), this);
		} catch (IllegalArgumentException x) {
			// Most likely this is a signal that's not supported on this
			// platform or with the JVM as it is currently configured
			throw x;
		} catch (Throwable x) {
			// We may have a serious problem, including missing classes
			// or changed APIs
			throw new IllegalArgumentException("Usupported signal : "
					+ signalName, x);
		}
	}

	public MySignalHandler(Trace trc) {
		super();
		myTrace = trc;
	}

	public MySignalHandler() {
		// TODO Auto-generated constructor stub
	}

	public final MySignalHandler install(final String signalName) {

		// myTrace=_myTrace;
		Signal diagSignal = new Signal(signalName);

		MySignalHandler myHandler = new MySignalHandler();

		myHandler.oldHandler = Signal.handle(diagSignal, myHandler);

		return myHandler;

	}

	/**
	 * Called by Sun Microsystems' signal trapping routines in the JVM.
	 * 
	 * @param signal
	 *            The {@link sun.misc.Signal} that we received
	 */
	public final void handle(final sun.misc.Signal signal) {
		// setChanged ensures that notifyObservers actually calls someone. In
		// simple cases this seems like extra work but in asynchronous designs,
		// setChanged might be called on one thread, and notifyObservers, on
		// another or only when multiple changes may have been completed (to
		// wrap up multiple changes in a single notifcation).
		// myTrace.update(signal.getName());
		setChanged();
		notifyObservers(signal);
	}

}
