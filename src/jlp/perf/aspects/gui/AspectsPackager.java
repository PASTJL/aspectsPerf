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

import java.awt.Dimension;
import java.awt.Font;
import java.awt.Point;
import java.awt.Toolkit;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.Properties;

import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.SwingUtilities;

public class AspectsPackager extends JFrame {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private JMenuBar jJMenuBar = null;
	private JMenu fileMenu;
	private JMenu helpMenu;
	private JMenuItem aboutMenuItem;
	private JDialog aboutDialog;
	private JScrollPane aboutContentPane;
	private JTextArea aboutVersionLabel;
	private JMenuItem newProject;
	public static String currentProject = "";
	public static String evol = "";
	public static String version = "LTWPackager Version 2.1.0 26/Dec/2012";

	public MyActionListener myListener = new MyActionListener(this);
	private JMenuItem openProject;
	
	private JMenuItem closeProject;
	private JMenuItem exitMenuItem;
	public static String footAopXml = null;
	public static String AspectsHome = null;
	public static String footAopXmlVerbose = null;

	public static String footAopXmlDebug = null;
	public static Properties allAspectsProps = new Properties();

	public AspectsPackager(String title) {
		super(title);
		// Preparation des 3 niveaux de foot

		String dir = System.getProperty("root") + File.separator + "config";
		AspectsHome = dir;
		RandomAccessFile raf;
		File f = new File(System.getProperty("root") + File.separator
				+ "config" + File.separator + "aspects.properties");
		try {
			allAspectsProps.load(new FileInputStream(f));
		} catch (FileNotFoundException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		} catch (IOException e2) {
			// TODO Auto-generated catch block
			e2.printStackTrace();
		}

		try {
			raf = new RandomAccessFile(new File(dir + File.separator
					+ "footAopXml.txt"), "r");

			byte[] tabBytes = new byte[(int) raf.length()];
			raf.readFully(tabBytes);
			footAopXml = new String(tabBytes);
			raf.close();

			raf = new RandomAccessFile(new File(dir + File.separator
					+ "footAopXmlVerbose.txt"), "r");
			tabBytes = new byte[(int) raf.length()];
			raf.readFully(tabBytes);
			footAopXmlVerbose = new String(tabBytes);
			raf.close();

			raf = new RandomAccessFile(new File(dir + File.separator
					+ "footAopXmlDebug.txt"), "r");
			tabBytes = new byte[(int) raf.length()];
			raf.readFully(tabBytes);
			footAopXmlDebug = new String(tabBytes);
			raf.close();

		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		System.out.println("footAopXml =" + footAopXml);
		System.out.println("footAopXmlVebose =" + footAopXmlVerbose);
		System.out.println("footAopXmlDebug =" + footAopXmlDebug);
		this.setJMenuBar(this.getJJMenuBar());

		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

		this.setResizable(true);

		this.setVisible(true);

	}

	private JMenuBar getJJMenuBar() {
		if (jJMenuBar == null) {
			jJMenuBar = new JMenuBar();
			jJMenuBar.add(getFileMenu());
			jJMenuBar.add(getHelpMenu());

		}
		return jJMenuBar;
	}

	public JMenu getFileMenu() {
		if (fileMenu == null) {
			fileMenu = new JMenu();
			fileMenu.setText("File");
			fileMenu.setName("fileMenu");
			fileMenu.add(getNewProject());
			fileMenu.add(getOpenProject());


			fileMenu.add(getCloseProject());
			// fileMenu.add(getSaveMenuItem());
			fileMenu.add(getExitMenuItem());

		}
		return fileMenu;
	}

	public JMenuItem getExitMenuItem() {
		if (exitMenuItem == null) {
			exitMenuItem = new JMenuItem();
			exitMenuItem.setText("Exit");
			exitMenuItem.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					System.exit(0);
				}
			});
		}
		return exitMenuItem;
	}

	public JMenuItem getCloseProject() {
		if (closeProject == null) {
			closeProject = new JMenuItem();
			closeProject.setText("Close Project");
			closeProject.setName("closeProject");
			closeProject.addActionListener(myListener);
			closeProject.setEnabled(false);

		}
		return closeProject;
	}



	private JMenuItem getOpenProject() {
		if (openProject == null) {
			openProject = new JMenuItem();
			openProject.setText("Open Project");
			openProject.setName("openProject");
			openProject.addActionListener(myListener);
			openProject.setEnabled(true);
		}
		return openProject;
	}

	private JMenuItem getNewProject() {
		if (newProject == null) {
			newProject = new JMenuItem();
			newProject.setText("New Project");
			newProject.setName("newProject");
			newProject.addActionListener(myListener);
			newProject.setEnabled(true);

		}
		return newProject;
	}

	public JMenu getHelpMenu() {
		if (helpMenu == null) {
			helpMenu = new JMenu();
			helpMenu.setName("helpMenu");
			helpMenu.setText("Help");
			helpMenu.add(getAboutMenuItem());

		}
		return helpMenu;
	}

	private JMenuItem getAboutMenuItem() {
		if (aboutMenuItem == null) {
			aboutMenuItem = new JMenuItem();
			aboutMenuItem.setText("About");
			aboutMenuItem.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					JDialog aboutDialog = getAboutDialog();
					aboutDialog.pack();
					Point loc = getLocation();
					loc.translate(20, 20);
					aboutDialog.setLocation(loc);
					aboutDialog.setVisible(true);
				}
			});
		}
		return aboutMenuItem;
	}

	private JDialog getAboutDialog() {
		if (aboutDialog == null) {
			aboutDialog = new JDialog(this, true);
			aboutDialog.setTitle("About");
			aboutDialog.setContentPane(getAboutContentPane());
		}
		return aboutDialog;
	}

	private JScrollPane getAboutContentPane() {
		if (aboutContentPane == null) {
			aboutContentPane = new JScrollPane(getAboutVersionLabel());
			aboutContentPane.setPreferredSize(new Dimension(500, 600));
			aboutContentPane.setSize(new Dimension(500, 600));

			aboutContentPane.getVerticalScrollBar().setValue(
					aboutContentPane.getVerticalScrollBar().getMinimum());
			aboutContentPane.getVerticalScrollBar().repaint();
			aboutContentPane.repaint();
		}
		return aboutContentPane;
	}

	private JTextArea getAboutVersionLabel() {
		if (aboutVersionLabel == null) {
			aboutVersionLabel = new JTextArea();
			aboutVersionLabel.setText(version
					+ "\nAuteur Jean-Louis Pasturel\n\n" + evol);
			aboutVersionLabel.setFont(new Font("Arial", Font.BOLD, 12));
			aboutVersionLabel.setCaretPosition(0);
			aboutVersionLabel.setEditable(false);
		}
		return aboutVersionLabel;
	}

	public static void main(String[] args) {
		// TODO Auto-generated method stub

		SwingUtilities.invokeLater(new Runnable() {
			public void run() {
				final AspectsPackager application = new AspectsPackager(
						AspectsPackager.version);

				try {
					RandomAccessFile raf = new RandomAccessFile(System
							.getProperty("root")
							+ File.separator
							+ "config"
							+ File.separator + "evolutions.txt", "r");
					String line = "";
					StringBuilder strBuff = new StringBuilder();
					while ((line = raf.readLine()) != null) {
						strBuff.append(line).append("\n");

					}
					evol = strBuff.toString();
					raf.close();
				} catch (FileNotFoundException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}

				Dimension d = Toolkit.getDefaultToolkit().getScreenSize();
				System.out.println("avant dim : " + d.width + " x " + d.height);
				application.setSize(d.width - 30, d.height - 30);
				application.setPreferredSize(new Dimension(d.width - 30,
						d.height - 30));
				application.repaint();

				application.setResizable(true);
				application.setVisible(true);

			}
		});
	}

}
