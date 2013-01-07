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
package jlp.perf.aspects.gui;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.Font;
import java.util.Iterator;
import java.util.Set;

import javax.swing.JDialog;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;

public class UploadsDialog extends JDialog implements Runnable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	public static String jtaContent = "";
	private AspectsPackager main;
	public Thread myPrincipalThread = null;
	public MyUploadThread myThread = null;
	private JScrollPane jspJtextArea = null;
	private JTextArea jta = null;
	private JPanel jpContentPane;
	boolean boolSpring = false;
	boolean boolJmxAspectsOnly = false;

	public UploadsDialog(AspectsPackager _AspectsPackager, boolean _spring,
			boolean _jmxAspectsOnly) {

		setModal(false);
		boolSpring = _spring;
		boolJmxAspectsOnly = _jmxAspectsOnly;
		this.setPreferredSize(new Dimension(900, 600));
		main = _AspectsPackager;
		jpContentPane = new JPanel();
		jpContentPane.setLayout(new BorderLayout());
		this.setContentPane(jpContentPane);
		jspJtextArea = new javax.swing.JScrollPane();
		jta = new JTextArea();
		jta.setLineWrap(true);

		this.jspJtextArea.setViewportView(jta);
		jspJtextArea.setAutoscrolls(true);
		jta.setText("");
		jta.setFont(new Font("Arial", Font.BOLD, 12));
		jpContentPane.add(jspJtextArea, BorderLayout.CENTER);
		this.pack();
		this.setVisible(true);

		myPrincipalThread = new Thread(this);
		myPrincipalThread.start();
		myThread = new MyUploadThread(this);
		myThread.start();
	}

	public void run() {

		while (null != myThread && myThread.isAlive())

		{
			try {

				if (Thread.currentThread() == myPrincipalThread) {

					jtaContent = new StringBuilder(jtaContent).append(". ")
							.toString();
					;
					getJta().setText(jtaContent);
					this.jspJtextArea.getVerticalScrollBar().setValue(
							this.jspJtextArea.getVerticalScrollBar()
									.getMaximum());

				}
				Thread.sleep(1000);

			} catch (InterruptedException e1) {
				// TODO Auto-generated catch block

				e1.printStackTrace();

			}

		}
		jta.setText(jtaContent);
		this.jspJtextArea.getVerticalScrollBar().setValue(
				this.jspJtextArea.getVerticalScrollBar().getMaximum());

		try {
			Thread.sleep(4000);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		dispose();

	}

	public JTextArea getJta() {
		return jta;
	}

	public void setJta(JTextArea jta) {
		this.jta = jta;
	}

	public AspectsPackager getMain() {
		return main;
	}

	public void setMain(AspectsPackager main) {
		this.main = main;
	}

}

class MyUploadThread extends Thread {
	UploadsDialog upDg;

	public MyUploadThread(UploadsDialog _upDg) {
		upDg = _upDg;
	}

	public void run() {

		long deb = System.currentTimeMillis();
		UploadsDialog.jtaContent = new StringBuilder(UploadsDialog.jtaContent)
				.append("\n Begin  Upnloading Files :\n ").toString();
		upDg.getJta().setText(UploadsDialog.jtaContent);

		Set keyset = AspectsPerf.hmAdresseAppli.keySet();
		Iterator it = keyset.iterator();
		while (it.hasNext()) {
			String key = (String) it.next();
			String rep = ExecCommand.executeCommand(key,
					"cd " + AspectsPerf.dirInstall + ";pwd").trim();

			if (!rep.endsWith("/")
					&& AspectsPerf.hmAdresseAppli.get(key).type.toLowerCase()
							.equals("unix")) {
				rep += "/";
			}
			System.out.println("UploadsDialog.run rep=" + rep);
			System.out.println("UploadsDialog.run AspectsPerf.dirInstall="
					+ AspectsPerf.dirInstall);
			if (rep.indexOf(AspectsPerf.dirInstall) >= 0) {
				UploadsDialog.jtaContent = new StringBuilder(
						UploadsDialog.jtaContent)
						.append("\n Install Dir found at :")
						.append(AspectsPerf.dirInstall)
						.append("\n Beginning uploads\n").toString();
				upDg.getJta().setText(UploadsDialog.jtaContent);
				if (!upDg.boolSpring && !upDg.boolJmxAspectsOnly) {
					UploadsDialog.jtaContent = new StringBuilder(
							UploadsDialog.jtaContent).append(
							"\n Uploading myaspectjweaver.jar\n").toString();
					upDg.getJta().setText(UploadsDialog.jtaContent);
					System.out.println("avant upload myaspectjweaver.jar ");
					ScpTo.scpTo(key, "myaspectjweaver.jar");
				}
				if (upDg.boolSpring && !upDg.boolJmxAspectsOnly) {
					UploadsDialog.jtaContent = new StringBuilder(
							UploadsDialog.jtaContent).append(
							"\n Uploading springmyaspectjweaver.jar\n")
							.toString();
					upDg.getJta().setText(UploadsDialog.jtaContent);
					ScpTo.scpTo(key, "springmyaspectjweaver.jar");
				}
				if (upDg.boolSpring && upDg.boolJmxAspectsOnly) {
					UploadsDialog.jtaContent = new StringBuilder(
							UploadsDialog.jtaContent).append(
							"\n Uploading springjmxaspectjweaver.jar\n")
							.toString();
					upDg.getJta().setText(UploadsDialog.jtaContent);
					ScpTo.scpTo(key, "springjmxaspectjweaver.jar");
				}
				if (!upDg.boolSpring && upDg.boolJmxAspectsOnly) {
					UploadsDialog.jtaContent = new StringBuilder(
							UploadsDialog.jtaContent).append(
							"\n Uploading jmxaspectjweaver.jar\n").toString();
					upDg.getJta().setText(UploadsDialog.jtaContent);
					ScpTo.scpTo(key, "jmxaspectjweaver.jar");
				}

				// Changement des droits en 777
				// si Unix changement des droits en 777

				if (AspectsPerf.osType.equals("unix")) {
					UploadsDialog.jtaContent = new StringBuilder(
							UploadsDialog.jtaContent).append(
							"\n Changements des droits en 777\n").toString();
					upDg.getJta().setText(UploadsDialog.jtaContent);

					rep = ExecCommand.executeCommand(key, "cd "
							+ AspectsPerf.dirInstall
							+ ";chmod 777 *aspectjweaver.jar");
				}
			}

		}

		// Traiter les 2 fichiers sur tous les serveurs

		long fin = System.currentTimeMillis();

		long nbMin = (fin - deb) / (1000 * 60);
		long nbSecs = ((fin - deb) / 1000) - nbMin * 60;
		long millis = (fin - deb) - (nbSecs * 1000) - nbMin * 60 * 1000;
		String mesg = "Treated in " + nbMin + " mn " + nbSecs + " secs "
				+ millis + " ms ";
		UploadsDialog.jtaContent = new StringBuilder(UploadsDialog.jtaContent)
				.append("\n End of  Uploading Files \n\t").append(mesg)
				.toString();
		upDg.getJta().setText(UploadsDialog.jtaContent);

		this.interrupt();

	}

	private String[] returnTabFilesFromDir() {
		String[] tabStr2 = null;
		;
		// remplir avec la liste des repertoire distant pour controler leur
		// existance

		return tabStr2;

	}

	private void upload(String idCon, String lfile) {
		// JLP à faire

		new ScpTo().scpTo(idCon, lfile);
	}

}
