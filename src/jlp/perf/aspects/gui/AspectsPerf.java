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

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.Toolkit;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.ItemEvent;
import java.awt.event.ItemListener;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.RandomAccessFile;
import java.nio.channels.FileChannel;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Properties;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import java.util.zip.ZipOutputStream;

import javax.swing.DefaultCellEditor;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JPasswordField;
import javax.swing.JRadioButton;
import javax.swing.JScrollPane;
import javax.swing.JTabbedPane;
import javax.swing.JTable;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.table.DefaultTableModel;
import javax.swing.table.TableColumnModel;
import javax.swing.table.TableModel;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import jlp.perf.aspects.util.CopyFile;

import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

public class AspectsPerf extends JPanel implements ActionListener,
		ItemListener, KeyListener {

	/**
	 * 
	 */

	private static Pattern[] patMandatoryFilters = new Pattern[] {
			Pattern.compile("jlp/aspectj/test.*"),
			Pattern.compile("jlp/aspectsJMX/mbean"),
			Pattern.compile("jlp/helper/"),
			Pattern.compile("jlp/perf/aspects/abstractAspects/(Trace|Version|MySignalHandler|StructPhantomRefQueueRef|AspectsPerfProperties)"),
			Pattern.compile("aj/"),
			Pattern.compile("aj/org/objectweb/asm/"),
			Pattern.compile("attachapi/launcher/"),
			Pattern.compile("org/aspectj/"),
			Pattern.compile("org/springframework/"),
			Pattern.compile("aspectj_1_5_0.dtd"),
			Pattern.compile("META-INF/[Mm][Aa][Nn][Ii][Ff][Ee][Ss][Tt].[Mm][Ff]"), };
	private static final long serialVersionUID = 1L;
	public static HashMap<String, InfoAspect> hmAspectsChosen = new HashMap<String, InfoAspect>();
	public static HashMap<String, AdresseAppli> hmAdresseAppli = new HashMap<String, AdresseAppli>();
	private JTabbedPane jtpParamsPerfStats = null;

	private JScrollPane jScrollConnexions = null;
	private JScrollPane jScrollAspects = null;

	public static String osType = "unix";

	public static String dirInstall = "";
	public static String dirLogs = "";
	public static String sep = ";";

	private JPanel jpAspects = null;
	private JLabel[] tabJlIntra = null;
	private JTextArea jtaPointcut = new JTextArea("", 5, 70);
	public String signal = "HUP";

	public JRadioButton jrbSpring = new JRadioButton("Spring Application ?");
	public JRadioButton jrbGzip = new JRadioButton("gzip trace ?");
	public JRadioButton jrbDebug = new JRadioButton(
			" Aspects in Debug and Verbose mode?");
	public JRadioButton jrbVerbose = new JRadioButton(
			" Aspects in  Verbose mode?");
	public JRadioButton jrbAllAspects = new JRadioButton(" All Aspects ?");

	public String currentSignal = "HUP";

	public static Properties customProps = new Properties();

	JTextField jtfDirInstall = null;
	JTextField jtfDirLogs = null;
	JTextField jtfSep = null;
	JPanel jpIntSep = new JPanel();

	public static Properties allAspects = new Properties();
	JComboBox jcbSignal = null;

	private Dimension dmTfJcb = new Dimension(250, 30);
	private Dimension littleDmTf = new Dimension(60, 30);
	private Dimension bigDmTfJcb = new Dimension(500, 30);

	JButton jbAspects = new JButton("Aspects Choice");

	private Dimension dmJb = new Dimension(180, 30);
	private JButton jbOK = null;
	private JButton jbOKFull = null;
	JTable jTableConnections = null;
	private JButton jbCancel = null;

	JTextArea jtaProperties = new JTextArea();;
	JScrollPane jspProperties = null;

	JScrollPane jspAopXml = null;
	JTextArea jtaAopXml = new JTextArea();

	JScrollPane jspEnvAspects = null;
	JTextArea jtaEnvAspects = new JTextArea();

	public String strPointcut = "";

	private JButton jbSaveConfiguration = null;
	public String headAopxml = "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n<aspectj>\n\t<aspects>\n\t\t"
			+ "\n\t</aspects>\n";

	String type = "concrete";
	public String headPerfStatsProperties = "aspectsPerf.default.filegzip = true\n";

	public static String rootProject = "";
	public String classpathAsp = "";
	public static boolean boolGzip = true;
	public AspectsPackager aspectsPerfs = null;
	public static String fullPathPerfStatsXml = null;

	public static String currentProject = "";

	public AspectsPerf(AspectsPackager aspectsPerfs) {
		hmAspectsChosen.clear();
		jrbAllAspects.setSelected(false);
		this.aspectsPerfs = aspectsPerfs;
		currentProject = AspectsPackager.currentProject;
		rootProject = System.getProperty("workspace") + File.separator
				+ AspectsPackager.currentProject;
		System.out.println("rootProject = " + rootProject);
		getJContentPane();
		fill();

		jbAspects.setFont(new Font("Arial", Font.BOLD, 14));
		jbAspects.addActionListener(this);
		this.jrbGzip.addItemListener(this);
		this.setVisible(true);
		aspectsPerfs.setContentPane(this);
		this.repaint();
		aspectsPerfs.repaint();
		aspectsPerfs.pack();

	}

	private void fill() {
		fullPathPerfStatsXml = new StringBuilder(
				System.getProperty("workspace")).append(File.separator)
				.append(AspectsPackager.currentProject).append(File.separator)
				.append("aspectsPerf.xml").toString();

		if (new File(fullPathPerfStatsXml).exists()) {
			System.out
					.println("Le fichier de configuration aspectsPerf, on remplit");
			DocumentBuilderFactory fabrique = DocumentBuilderFactory
					.newInstance();

			// création d'un constructeur de documents
			DocumentBuilder constructeur;
			try {
				constructeur = fabrique.newDocumentBuilder();
				File xml = new File(fullPathPerfStatsXml);
				Document document = constructeur.parse(xml);
				NodeList ndList = document.getElementsByTagName("Connection");

				int taille = ndList.getLength();
				hmAdresseAppli.clear();
				for (int i = 0; i < taille; i++) {
					Node nd = ndList.item(i);
					NodeList ndList2 = nd.getChildNodes();
					String idCnx = "";
					String type = "";
					String ipServer = "";
					String ipPort = "";

					String login = "";
					String passwd = "";

					for (int j = 0; j < ndList2.getLength(); j++) {
						if (ndList2.item(j).getNodeName().equals("IdCnx")) {
							this.jTableConnections.setValueAt(ndList2.item(j)
									.getFirstChild().getNodeValue(), i, 0);
							idCnx = (String) jTableConnections.getValueAt(i, 0);
						}

						if (ndList2.item(j).getNodeName().equals("IpServer")) {
							this.jTableConnections.setValueAt(ndList2.item(j)
									.getFirstChild().getNodeValue(), i, 1);
							ipServer = (String) jTableConnections.getValueAt(i,
									1);
						}
						if (ndList2.item(j).getNodeName().equals("IpPort")) {
							this.jTableConnections.setValueAt(ndList2.item(j)
									.getFirstChild().getNodeValue(), i, 2);
							ipPort = (String) jTableConnections
									.getValueAt(i, 2);
						}
						if (ndList2.item(j).getNodeName().equals("type")) {
							this.jTableConnections.setValueAt(ndList2.item(j)
									.getFirstChild().getNodeValue(), i, 3);
							type = (String) jTableConnections.getValueAt(i, 3);
						}
						if (ndList2.item(j).getNodeName().equals("Login")) {
							this.jTableConnections.setValueAt(ndList2.item(j)
									.getFirstChild().getNodeValue(), i, 4);
							login = (String) jTableConnections.getValueAt(i, 4);
							// System.out.println("login ="+login);
						}
						if (ndList2.item(j).getNodeName().equals("Password")) {
							this.jTableConnections.setValueAt(ndList2.item(j)
									.getFirstChild().getNodeValue(), i, 5);
							passwd = (String) jTableConnections
									.getValueAt(i, 5);
							// System.out.println("passwd ="+passwd);
						}

					}
					hmAdresseAppli.put(idCnx, new AdresseAppli(idCnx, ipServer,
							ipPort, type, login, passwd));

				}

			} catch (ParserConfigurationException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (SAXException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		if (new File(AspectsPackager.AspectsHome + File.separator
				+ "aspectsPerf.properties").exists()) {

			File f = new File(AspectsPerf.rootProject + File.separator
					+ "aspectsPerf.properties");
			try {
				FileInputStream fis = new FileInputStream(f);

				allAspects.load(fis);
				fis.close();

			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		}
		if (new File(AspectsPerf.rootProject + File.separator
				+ "aspectsPerf.properties").exists()) {

			try {
				File f = new File(AspectsPerf.rootProject + File.separator
						+ "aspectsPerf.properties");
				FileInputStream fis = new FileInputStream(f);
				customProps.load(fis);
				if (customProps.containsKey("aspectsPerf.springAppli")) {
					String spring = customProps.getProperty(
							"aspectsPerf.springAppli").toLowerCase();
					if (spring.equals("true")) {
						this.jrbSpring.setSelected(true);
					} else {
						this.jrbSpring.setSelected(false);
					}
				} else {
					customProps.setProperty("aspectsPerf.springAppli", "false");
					this.jrbSpring.setSelected(false);
				}

				if (customProps.containsKey("aspectsPerf.default.filegzip")) {
					String tmpGzip = customProps.getProperty(
							"aspectsPerf.default.filegzip").toLowerCase();
					if (tmpGzip.equals("true")) {
						this.jrbGzip.setSelected(true);
						boolGzip = true;
					} else {
						this.jrbGzip.setSelected(false);
						boolGzip = false;
					}
				} else {
					customProps.setProperty("aspectsPerf.default.filegzip",
							"true");
					this.jrbGzip.setSelected(true);
				}

				if (customProps.containsKey("aspectsPerf.debugMode")) {
					String debug = customProps.getProperty(
							"aspectsPerf.debugMode").toLowerCase();
					if (debug.equals("true")) {
						this.jrbDebug.setSelected(true);
					} else {
						this.jrbDebug.setSelected(false);
					}
				} else {
					customProps.setProperty("aspectsPerf.debugMode", "false");
					this.jrbDebug.setSelected(false);
				}

				if (customProps.containsKey("aspectsPerf.verboseMode")) {
					String verbose = customProps.getProperty(
							"aspectsPerf.verboseMode").toLowerCase();
					if (verbose.equals("true")) {
						this.jrbVerbose.setSelected(true);
					} else {
						this.jrbVerbose.setSelected(false);
					}
				} else {
					customProps.setProperty("aspectsPerf.verboseMode", "false");
					this.jrbVerbose.setSelected(false);
				}

				RandomAccessFile raf = new RandomAccessFile(f, "r");
				int len = (int) raf.length();
				byte[] tabBytes = new byte[len];
				raf.read(tabBytes);
				this.jtaProperties.setEditable(true);
				this.jtaProperties.setText(new String(tabBytes));
				this.jtaProperties.setEditable(false);
				fis.close();
				raf.close();

			} catch (FileNotFoundException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			} catch (IOException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}

			if (customProps.containsKey("aspectsPerf.default.dirInstall")) {
				this.jtfDirInstall.setText(customProps
						.getProperty("aspectsPerf.default.dirInstall"));
				dirInstall = customProps
						.getProperty("aspectsPerf.default.dirInstall");

			}
			if (customProps.containsKey("aspectsPerf.default.sep")) {
				this.jtfSep.setText(customProps.getProperty(
						"aspectsPerf.default.sep", ";"));
				sep = customProps.getProperty("aspectsPerf.default.sep", ";");

			}
			if (customProps.containsKey("aspectsPerf.default.dirLogs")) {
				this.jtfDirLogs.setText(customProps
						.getProperty("aspectsPerf.default.dirLogs"));
				this.dirLogs = customProps
						.getProperty("aspectsPerf.default.dirLogs");
			}
			System.out
					.println("customProps.getProperty(\"aspectsPerf.handleSignal\")="
							+ customProps
									.getProperty("aspectsPerf.handleSignal"));
			this.jcbSignal.setSelectedItem(customProps
					.getProperty("aspectsPerf.handleSignal"));
			this.currentSignal = customProps
					.getProperty("aspectsPerf.handleSignal");
			this.signal = this.currentSignal = customProps
					.getProperty("aspectsPerf.handleSignal");

		} else {
			// on cree un sqelette
			File f = new File(this.rootProject + File.separator
					+ "aspectsPerf.properties");
			customProps.clear();
			customProps.put("aspectsPerf.default.filelogs", "/tmp/aspectj.log");
			customProps.put("aspectsPerf.default.filegzip", "true");

			customProps.put("aspectsPerf.default.sep", this.sep);

			customProps.put("aspectsPerf.springAppli", "false");

			customProps.put("aspectsPerf.verboseMode", "false");
			customProps.put("aspectsPerf.debugMode", "false");
			customProps.put("aspectsPerf.handleSignal", this.currentSignal);
			FileOutputStream fos;
			try {
				fos = new FileOutputStream(f);
				customProps.store(fos, "Saved on "
						+ Calendar.getInstance().getTime().toString());

				fos.close();
				FileInputStream fis = new FileInputStream(f);
				customProps.load(fis);
				RandomAccessFile raf = new RandomAccessFile(f, "r");
				int len = (int) raf.length();
				byte[] tabBytes = new byte[len];
				raf.read(tabBytes);
				this.jtaProperties.setEditable(true);
				this.jtaProperties.setText(new String(tabBytes));
				this.jtaProperties.setEditable(false);
				fis.close();
				raf.close();

			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		}

		System.out.println("Chemin aop.xml=" + this.rootProject
				+ File.separator + "aop.xml");
		if (new File(this.rootProject + File.separator + "aop.xml").exists()) {

			try {
				File f = new File(this.rootProject + File.separator + "aop.xml");

				RandomAccessFile raf = new RandomAccessFile(f, "r");
				// On lit ligne a ligne jusqu a rencontrer la chaine "Foot Mode"
				String line = "";
				String textToShow = line = raf.readLine();
				boolean finTagAspects = false;
				while ((line = raf.readLine()) != null) {
					if (line.indexOf("</aspects>") >= 0) {
						line = "\n\n</aspects>\n\n";
						finTagAspects = true;
					}
					if (line.indexOf("Foot Mode") < 0 && line.length() > 0) {

						textToShow = new StringBuilder(textToShow).append("\n")
								.append(line).toString();

					}
					if (line.indexOf("Foot Mode") > 0) {
						if (!finTagAspects) {
							textToShow = new StringBuilder(textToShow).append(
									"\n\n</aspects>\n\n").toString();
						}

						break;
					}

				}
				// choix du foot
				String foot = "";
				System.out.println("fill  aop.xml, avant traitement foot");
				if (customProps.getProperty("aspectsPerf.debugMode")
						.toLowerCase().equals("true")) {
					foot = AspectsPackager.footAopXmlDebug;
				}
				System.out.println("fill  aop.xml, apres test debug");
				if (customProps.getProperty("aspectsPerf.debugMode")
						.toLowerCase().equals("false")
						&& customProps.getProperty("aspectsPerf.verboseMode")
								.toLowerCase().equals("true")) {
					foot = AspectsPackager.footAopXmlVerbose;
				}
				if (customProps.getProperty("aspectsPerf.debugMode")
						.toLowerCase().equals("false")
						&& customProps.getProperty("aspectsPerf.verboseMode")
								.toLowerCase().equals("false")) {
					foot = AspectsPackager.footAopXml;
				}
				System.out.println("fill  aop.xml, apres traitement foot");
				textToShow = new StringBuilder(textToShow).append("\n\n")
						.append(foot).append("\n").toString();
				this.jtaAopXml.setEditable(true);
				this.jtaAopXml.setText(textToShow);
				this.jtaAopXml.setEditable(false);
				raf.close();

				// liste des Aspects choisis

				DocumentBuilder constructeur;
				DocumentBuilderFactory fabrique = DocumentBuilderFactory
						.newInstance();

				try {
					constructeur = fabrique.newDocumentBuilder();
					Document document = constructeur.parse(f);
					// traitement Aspects concrets
					NodeList ndList = document.getElementsByTagName("aspect");
					int taille = ndList.getLength();
					for (int i = 0; i < taille; i++) {

						String strScope = "";

						String strRequires = "";
						String name = "";
						NamedNodeMap namedNodeList = ndList.item(i)
								.getAttributes();

						int len = namedNodeList.getLength();

						if (len == 1) {
							name = ((Attr) ndList.item(i).getAttributes()
									.item(0)).getValue();
						}
						if (len == 2) {
							if (((Attr) ndList.item(i).getAttributes().item(0))
									.getName().equals("name")) {
								name = ((Attr) ndList.item(i).getAttributes()
										.item(0)).getValue();
							}
							if (((Attr) ndList.item(i).getAttributes().item(1))
									.getName().equals("name")) {
								name = ((Attr) ndList.item(i).getAttributes()
										.item(1)).getValue();
							}

							if (((Attr) ndList.item(i).getAttributes().item(0))
									.getName().equals("scope")) {
								strScope = ((Attr) ndList.item(i)
										.getAttributes().item(0)).getValue();
							}
							if (((Attr) ndList.item(i).getAttributes().item(1))
									.getName().equals("scope")) {
								strScope = ((Attr) ndList.item(i)
										.getAttributes().item(1)).getValue();
							}

							if (((Attr) ndList.item(i).getAttributes().item(0))
									.getName().equals("requires")) {
								strRequires = ((Attr) ndList.item(i)
										.getAttributes().item(0)).getValue();
							}
							if (((Attr) ndList.item(i).getAttributes().item(1))
									.getName().equals("requires")) {
								strRequires = ((Attr) ndList.item(i)
										.getAttributes().item(1)).getValue();
							}
						}
						if (len == 3) {

							if (((Attr) ndList.item(i).getAttributes().item(0))
									.getName().equals("name")) {
								name = ((Attr) ndList.item(i).getAttributes()
										.item(0)).getValue();
							}
							if (((Attr) ndList.item(i).getAttributes().item(1))
									.getName().equals("name")) {
								name = ((Attr) ndList.item(i).getAttributes()
										.item(1)).getValue();
							}

							if (((Attr) ndList.item(i).getAttributes().item(2))
									.getName().equals("name")) {
								name = ((Attr) ndList.item(i).getAttributes()
										.item(2)).getValue();
							}

							if (((Attr) ndList.item(i).getAttributes().item(0))
									.getName().equals("scope")) {
								strScope = ((Attr) ndList.item(i)
										.getAttributes().item(0)).getValue();
							}
							if (((Attr) ndList.item(i).getAttributes().item(1))
									.getName().equals("scope")) {
								strScope = ((Attr) ndList.item(i)
										.getAttributes().item(1)).getValue();
							}

							if (((Attr) ndList.item(i).getAttributes().item(2))
									.getName().equals("scope")) {
								strScope = ((Attr) ndList.item(i)
										.getAttributes().item(2)).getValue();
							}

							if (((Attr) ndList.item(i).getAttributes().item(0))
									.getName().equals("requires")) {
								strRequires = ((Attr) ndList.item(i)
										.getAttributes().item(0)).getValue();
							}
							if (((Attr) ndList.item(i).getAttributes().item(1))
									.getName().equals("requires")) {
								strRequires = ((Attr) ndList.item(i)
										.getAttributes().item(1)).getValue();
							}

							if (((Attr) ndList.item(i).getAttributes().item(2))
									.getName().equals("requires")) {
								strRequires = ((Attr) ndList.item(i)
										.getAttributes().item(2)).getValue();
							}

						}

						InfoAspect iA = new InfoAspect(name, "", "",
								"concrete", "", strScope, strRequires,
								Color.BLACK);
						AspectsPerf.hmAspectsChosen.put(name, iA);
					}
					// traitement Aspects abstraits
					ndList = document.getElementsByTagName("concrete-aspect");
					taille = ndList.getLength();
					for (int i = 0; i < taille; i++) {
						NamedNodeMap lstAttr = ndList.item(i).getAttributes();
						int tailleBis = lstAttr.getLength();
						String name = "", expression = "", pointCut = "", extension = "";
						for (int j = 0; j < tailleBis; j++) {
							if (lstAttr.item(j).getNodeName().equals("name")) {
								name = ((Attr) lstAttr.item(j)).getValue();
							}
							if (lstAttr.item(j).getNodeName().equals("extends")) {
								extension = ((Attr) lstAttr.item(j)).getValue();
							}

						}
						NodeList ndListBis = ndList.item(i).getChildNodes();
						int tailleTer = ndListBis.getLength();
						for (int k = 0; k < tailleTer; k++) {
							if (ndListBis.item(k).getNodeName()
									.equals("pointcut")) {
								lstAttr = ndListBis.item(k).getAttributes();
								tailleBis = lstAttr.getLength();
								for (int kk = 0; kk < tailleBis; kk++) {
									if (lstAttr.item(kk).getNodeName()
											.equals("expression")) {
										expression = ((Attr) lstAttr.item(kk))
												.getValue();
									}
									if (lstAttr.item(kk).getNodeName()
											.equals("name")) {
										pointCut = ((Attr) lstAttr.item(kk))
												.getValue();
									}
								}
							}
						}

						InfoAspect iA = new InfoAspect(extension, extension,
								expression, "abstract", pointCut, "", "",
								Color.BLACK);
						hmAspectsChosen.put(extension, iA);
					}

				} catch (ParserConfigurationException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (SAXException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}

			} catch (FileNotFoundException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			} catch (IOException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		} else {
			// on cree un squelette
			File f = new File(this.rootProject + File.separator + "aop.xml");

			try {
				RandomAccessFile raf = new RandomAccessFile(f, "rw");
				raf.getChannel().truncate(0);

				String str = "";

				str = this.headAopxml + AspectsPackager.footAopXml;
				this.jtaAopXml.setEditable(true);
				this.jtaAopXml.setText(str);
				this.jtaAopXml.setEditable(false);
				raf.writeBytes(str);
				raf.close();
			} catch (FileNotFoundException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			} catch (IOException e3) {
				// TODO Auto-generated catch block
				e3.printStackTrace();
			}
		}

	}

	private void getJContentPane() {
		GridBagConstraints gridBagConstraints2 = new GridBagConstraints();
		// gridBagConstraints2.fill = GridBagConstraints.VERTICAL;
		gridBagConstraints2.fill = GridBagConstraints.NONE;
		gridBagConstraints2.insets = new Insets(40, 80, 25, 50);
		gridBagConstraints2.gridy = 1;

		gridBagConstraints2.gridx = 0;

		GridBagConstraints gridBagConstraints = new GridBagConstraints();
		gridBagConstraints.insets = new Insets(5, 5, 5, 5);
		gridBagConstraints.fill = GridBagConstraints.BOTH;
		gridBagConstraints.gridx = 0;
		gridBagConstraints.gridy = 0;
		gridBagConstraints.ipadx = 5;
		gridBagConstraints.ipady = 5;
		gridBagConstraints.gridwidth = 4;

		gridBagConstraints.weightx = 1.0;
		gridBagConstraints.weighty = 1.0;

		this.setLayout(new GridBagLayout());

		this.add(this.getJtpParamsPerfStats(), gridBagConstraints);

		JPanel panelButt = new JPanel();
		panelButt.setLayout(new GridBagLayout());

		panelButt.add(getJbOK(), gridBagConstraints2);
		gridBagConstraints2.gridx = 1;

		panelButt.add(getJbCancel(), gridBagConstraints2);
		gridBagConstraints2.gridx = 2;
		panelButt.add(this.getJbSaveConfiguration(), gridBagConstraints2);
		gridBagConstraints2.gridx = 3;
		panelButt.add(getJbOKFull(), gridBagConstraints2);
		gridBagConstraints.gridy = 1;
		gridBagConstraints.weighty = 0;
		this.add(panelButt, gridBagConstraints);

	}

	private JTabbedPane getJtpParamsPerfStats() {
		if (jtpParamsPerfStats == null) {
			try {
				jtpParamsPerfStats = new JTabbedPane();

				jtpParamsPerfStats.addTab("Aspects", null, getJScrollAspects(),
						null);
				jtpParamsPerfStats.addTab("Connections", null,
						getJScrollConnexions(), null);
				jtpParamsPerfStats.addTab("aop.xml", null, getJScrollAopXml(),
						null);
				jtpParamsPerfStats.addTab("aspectsPerf.properties", null,
						getJScrollPerfStatsProperties(), null);

				jtpParamsPerfStats.setAutoscrolls(true);
			} catch (java.lang.Throwable e) {
				// TODO: Something
			}
		}
		return jtpParamsPerfStats;
	}

	private JScrollPane getJScrollPerfStatsProperties() {
		if (this.jspProperties == null) {
			jspProperties = new JScrollPane(this.jtaProperties);

			jspProperties.setAutoscrolls(true);
		}
		return jspProperties;
	}

	private JScrollPane getJScrollAopXml() {
		if (this.jspAopXml == null) {
			jspAopXml = new JScrollPane(this.jtaAopXml);
			Toolkit tk = Toolkit.getDefaultToolkit();

			jspAopXml.setAutoscrolls(true);
		}
		return jspAopXml;
	}

	private JScrollPane getJScrollAspects() {
		if (jScrollAspects == null) {
			try {
				jScrollAspects = new JScrollPane();
				jScrollAspects.setViewportView(getJpAspects());
				Toolkit tk = Toolkit.getDefaultToolkit();
				Dimension dm = tk.getScreenSize();

				jScrollAspects.setAutoscrolls(true);

			} catch (java.lang.Throwable e) {
				// TODO: Something
			}
		}
		return jScrollAspects;

	}

	@SuppressWarnings("unchecked")
	private JPanel getJpAspects() {
		if (jpAspects == null) {
			try {
				jpAspects = new JPanel();
				GridBagLayout gbl = new GridBagLayout();
				jpAspects.setLayout(gbl);
				GridBagConstraints gbc = new GridBagConstraints();

				gbc.insets = new Insets(50, 80, 50, 80);
				gbc.weightx = 1.0;
				// gbc.fill = GridBagConstraints.BOTH;
				gbc.anchor = GridBagConstraints.CENTER;
				JLabel lbTitle = new JLabel("Packaging Aspects");
				lbTitle.setFont(new Font("Arial", Font.BOLD, 40));
				gbc.gridx = 0;
				gbc.gridy = 0;
				gbc.gridwidth = 4;
				jpAspects.add(lbTitle, gbc);

				gbc.insets = new Insets(15, 15, 15, 15);
				// Ligne radio bouton
				gbc.gridx = 0;
				gbc.gridy = 1;
				gbc.gridwidth = 1;
				gbc.anchor = GridBagConstraints.EAST;
				this.jrbSpring.setFont(new Font("Arial", Font.BOLD, 14));
				jpAspects.add(jrbSpring, gbc);

				gbc.gridx = 1;
				gbc.gridy = 1;
				gbc.gridwidth = 1;
				gbc.anchor = GridBagConstraints.WEST;
				this.jrbGzip.setFont(new Font("Arial", Font.BOLD, 14));
				jpAspects.add(jrbGzip, gbc);

				gbc.gridx = 0;
				gbc.gridy = 2;
				gbc.gridwidth = 1;
				gbc.anchor = GridBagConstraints.EAST;
				this.jrbDebug.setFont(new Font("Arial", Font.BOLD, 14));
				jpAspects.add(jrbDebug, gbc);

				gbc.gridx = 1;
				gbc.gridy = 2;
				gbc.gridwidth = 1;
				gbc.anchor = GridBagConstraints.WEST;
				this.jrbVerbose.setFont(new Font("Arial", Font.BOLD, 14));
				jpAspects.add(jrbVerbose, gbc);

				// Directory d installation
				gbc.gridx = 0;
				gbc.gridy = 3;
				gbc.anchor = GridBagConstraints.EAST;
				gbc.gridwidth = 1;
				JLabel jlDirInstall = new JLabel("Install Dir : ");
				jlDirInstall.setFont(new Font("Arial", Font.BOLD, 14));
				jpAspects.add(jlDirInstall, gbc);

				gbc.gridx = 1;
				gbc.gridy = 3;
				gbc.anchor = GridBagConstraints.WEST;
				gbc.gridwidth = 1;
				this.jtfDirInstall = new JTextField();
				jtfDirInstall.setFont(new Font("Arial", Font.BOLD, 12));
				jtfDirInstall.setPreferredSize(this.bigDmTfJcb);
				jpAspects.add(jtfDirInstall, gbc);

				// Directory des logs
				gbc.gridx = 0;
				gbc.gridy = 4;
				gbc.anchor = GridBagConstraints.EAST;
				gbc.gridwidth = 1;
				JLabel jlDirLogs = new JLabel("Logs Dir : ");
				jlDirLogs.setFont(new Font("Arial", Font.BOLD, 14));
				jpAspects.add(jlDirLogs, gbc);

				gbc.gridx = 1;
				gbc.gridy = 4;
				gbc.anchor = GridBagConstraints.WEST;
				gbc.gridwidth = 1;
				this.jtfDirLogs = new JTextField();
				jtfDirLogs.setFont(new Font("Arial", Font.BOLD, 12));
				jtfDirLogs.setPreferredSize(this.bigDmTfJcb);
				jpAspects.add(jtfDirLogs, gbc);

				// Gestion du Signal de regeneration des streams et Separateur
				// de champs csv
				gbc.gridx = 0;
				gbc.gridy = 5;
				gbc.anchor = GridBagConstraints.EAST;
				gbc.gridwidth = 4;

				this.jpIntSep.setLayout(new GridBagLayout());
				GridBagConstraints gbc0 = new GridBagConstraints();
				gbc0.gridx = 0;
				gbc0.gridy = 0;
				gbc0.insets = new Insets(35, 5, 5, 35);
				JLabel jlSignal = new JLabel("Signal to close stream : ");
				jlSignal.setFont(new Font("Arial", Font.BOLD, 14));
				this.jpIntSep.add(jlSignal, gbc0);
				gbc0.gridx = 1;
				gbc0.gridy = 0;

				gbc0.anchor = GridBagConstraints.WEST;
				jcbSignal = new JComboBox();
				jcbSignal.addItem("HUP");
				jcbSignal.addItem("NONE");
				jcbSignal.addItem("USR1");
				jcbSignal.addItem("USR2");
				jcbSignal.addItem("INT");
				// jcbSignal.setSelectedItem("HUP");
				jcbSignal.setFont(new Font("Arial", Font.BOLD, 12));
				jcbSignal.addItemListener(this);

				jpIntSep.add(jcbSignal, gbc0);

				gbc0.gridx = 2;
				gbc0.gridy = 0;

				JLabel jlSep = new JLabel("CSV Separator  : ");
				jlSep.setFont(new Font("Arial", Font.BOLD, 14));
				this.jpIntSep.add(jlSep, gbc0);

				gbc0.gridx = 3;
				gbc0.gridy = 0;
				this.jtfSep = new JTextField(";");
				this.jtfSep.setFont(new Font("Arial", Font.BOLD, 12));
				this.jtfSep.setPreferredSize(this.littleDmTf);
				this.jpIntSep.add(jtfSep, gbc0);
				gbc.insets = new Insets(15, 15, 15, 15);
				gbc.anchor = GridBagConstraints.CENTER;
				jpAspects.add(this.jpIntSep, gbc);

				gbc.gridwidth = 1;
				gbc.gridx = 0;
				gbc.gridy = 6;
				gbc.anchor = GridBagConstraints.EAST;
				gbc.gridwidth = 1;
				jrbAllAspects.setFont(new Font("Arial", Font.BOLD, 14));
				jpAspects.add(this.jrbAllAspects, gbc);
				gbc.gridx = 1;
				gbc.gridy = 6;
				gbc.anchor = GridBagConstraints.WEST;
				gbc.gridwidth = 1;
				// gbc.insets = new Insets(50, 5, 150, 5);
				jpAspects.add(jbAspects, gbc);

				jpAspects.setAutoscrolls(true);

			} catch (java.lang.Throwable e) {
				// TODO: Something
			}
		}
		return jpAspects;
	}

	private JScrollPane getJScrollConnexions() {
		if (jScrollConnexions == null) {
			try {
				jScrollConnexions = new JScrollPane();
				jScrollConnexions.setViewportView(getConnections());

			} catch (java.lang.Throwable e) {
				// TODO: Something
			}
		}
		return jScrollConnexions;
	}

	private JTable getConnections() {

		// jpCreate.setSize(new Dimension(900,400));
		// jpCreate.setPreferredSize(new Dimension(900,600));
		if (jTableConnections == null) {
			try {
				String[] columns = { "Ident", "ip Server", "ip port",
						"unix/win", "Login", "Password" };
				TableModel dataModel = new DefaultTableModel(columns, 20);
				jTableConnections = new JTable(dataModel);
				jTableConnections.setRowHeight(20);
				jTableConnections.getTableHeader().setFont(
						new Font("Arial", Font.BOLD, 14));
				jTableConnections.setFont(new Font("Arial", Font.BOLD, 12));
				jTableConnections
						.getColumnModel()
						.getColumn(3)
						.setCellEditor(
								new DefaultCellEditor(new JComboBox(
										new String[] { "unix", "windows" })));
				jTableConnections
						.getColumnModel()
						.getColumn(3)
						.setCellRenderer(
								new JComboBoxCellRenderer(new String[] {
										"unix", "windows" }));

				jTableConnections
						.getColumnModel()
						.getColumn(5)
						.setCellRenderer(
								new JPasswordFieldCellRenderer("Password"));
				jTableConnections
						.getColumnModel()
						.getColumn(5)
						.setCellEditor(
								new DefaultCellEditor(new JPasswordField()));
				Toolkit tk = Toolkit.getDefaultToolkit();
				Dimension dm = tk.getScreenSize();

				Dimension dimTable = new Dimension(dm.width - 40,
						dm.height - 50);
				jTableConnections.setPreferredSize(dimTable);

				TableColumnModel cMod = jTableConnections.getColumnModel();
				cMod.getColumn(0).setResizable(true);
				cMod.getColumn(1).setResizable(true);
				cMod.getColumn(2).setResizable(true);
				cMod.getColumn(3).setResizable(true);
				cMod.getColumn(4).setResizable(true);
				cMod.getColumn(5).setResizable(true);
				cMod.getColumn(0).setPreferredWidth(dimTable.width / 12);
				cMod.getColumn(1).setPreferredWidth(4 * dimTable.width / 12);
				cMod.getColumn(2).setPreferredWidth(dimTable.width / 12);
				cMod.getColumn(3).setPreferredWidth(2 * dimTable.width / 12);
				cMod.getColumn(4).setPreferredWidth(2 * dimTable.width / 12);
				cMod.getColumn(5).setPreferredWidth(2 * dimTable.width / 12);
				for (int i = 0; i < 20; i++) {
					this.jTableConnections.setValueAt("", i, 0);
					this.jTableConnections.setValueAt("unix", i, 3);
				}
				jTableConnections.addKeyListener(this);
			} catch (java.lang.Throwable e) {
				// TODO: Something
			}
		}
		return jTableConnections;
	}

	private JButton getJbOK() {
		if (jbOK == null) {
			try {
				jbOK = new JButton();
				jbOK.setText("Upload Minimal agent");
				jbOK.addActionListener(this);
			} catch (java.lang.Throwable e) {
				// TODO: Something
			}
		}
		return jbOK;
	}

	private JButton getJbOKFull() {
		if (jbOKFull == null) {
			try {
				jbOKFull = new JButton();
				jbOKFull.setText("Upload Full agent");
				jbOKFull.addActionListener(this);
			} catch (java.lang.Throwable e) {
				// TODO: Something
			}
		}
		return jbOKFull;
	}

	private JButton getJbCancel() {
		if (jbCancel == null) {
			try {
				jbCancel = new JButton();
				jbCancel.setPreferredSize(dmJb);
				jbCancel.setText("Cancel");
				jbCancel.addActionListener(this);
			} catch (java.lang.Throwable e) {
				// TODO: Something
			}
		}
		return jbCancel;
	}

	private JButton getJbSaveConfiguration() {
		if (jbSaveConfiguration == null) {
			try {
				jbSaveConfiguration = new JButton();
				jbSaveConfiguration.setPreferredSize(dmJb);
				jbSaveConfiguration.setText("Save Configuration");

				jbSaveConfiguration.addActionListener(this); // TODO
				// Auto-generated
				// Event
				// stub actionPerformed()

			} catch (java.lang.Throwable e) {
				// TODO: Something
			}
		}
		return jbSaveConfiguration;
	}

	public void actionPerformed(ActionEvent e) {
		if (e.getSource() instanceof JButton) {
			JButton jb = (JButton) e.getSource();
			if (jb == this.jbSaveConfiguration) {
				saveConfiguration();
			}

			if (jb == this.jbAspects) {
				String[] names = null;
				if (this.jrbAllAspects.isSelected()) {
					names = AspectsPackager.allAspectsProps
							.getProperty("names").split(";");
				} else {
					names = AspectsPackager.allAspectsProps.getProperty(
							"prefnames").split(";");
				}

				JDialog jd = new JDialog(aspectsPerfs);
				jd.setModal(true);
				Toolkit tk = Toolkit.getDefaultToolkit();
				Dimension dim = tk.getScreenSize();
				Dimension dmChooser = new Dimension(dim.width, 700);
				jd.setSize(dmChooser);
				jd.setPreferredSize(dmChooser);

				ArrayList<String> lst1 = new ArrayList<String>();
				ArrayList<String> lst2 = new ArrayList<String>();
				for (int i = 0, len = names.length; i < len; i++) {
					lst1.add(i, names[i]);
				}
				String prefix = "aspect";

				// detection des Aspects existants

				File xml = new File(this.rootProject + File.separator
						+ "aop.xml");

				DocumentBuilderFactory fabrique = DocumentBuilderFactory
						.newInstance();

				// création d'un constructeur de documents
				DocumentBuilder constructeur;
				boolean aspectsExists = false;
				try {
					constructeur = fabrique.newDocumentBuilder();

					Document document = constructeur.parse(xml);

					System.out
							.println("Suppression dans AOP seulementTraitement Aspect abstrait");
					// traitement de l aspect abstrait
					boolean trouve = false;
					// cas de l'aspect concret
					NodeList ndList = document
							.getElementsByTagName("concrete-aspect");
					for (int i = 0, len = ndList.getLength(); i < len; i++) {
						String name = ndList.item(i).getAttributes()
								.getNamedItem("extends").getNodeValue();
						aspectsExists = true;
						lst1.remove(name);
						lst2.add(name);

					}

					document = constructeur.parse(xml);
					ndList = document.getElementsByTagName("aspect");

					// cas de l'aspect concret
					for (int i = 0, len = ndList.getLength(); i < len; i++) {
						String name = ndList.item(i).getAttributes()
								.getNamedItem("name").getNodeValue();
						aspectsExists = true;
						lst1.remove(name);
						lst2.add(name);
					}

				} catch (ParserConfigurationException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				} catch (SAXException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				} catch (IOException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}

				jd.setContentPane(new jlp.perf.aspects.gui.MyPickList(
						"Aspects to choice", "Chosen Aspects", lst1, lst2));
				jd.setVisible(true);
				jd.pack();
				this.saveConfiguration();
			}
			if (jb == this.jbCancel) {
				// this.dispose();
			}
			if (jb == this.jbOK) {
				packageJarFilter();

				uploads();
			}
			if (jb == this.jbOKFull) {

				packageJar();
				uploads();
			}
		}

	}

	private void uploads() {
		boolean boolSpring = false;
		if (this.jrbSpring.isSelected()) {
			boolSpring = true;
		} else {
			boolSpring = false;
		}
		if (this.jrbGzip.isSelected()) {
			AspectsPerf.boolGzip = true;
		} else {
			AspectsPerf.boolGzip = false;
		}
		setVisible(false);

		// this.dispose();
		UploadsDialog.jtaContent = "";
		new UploadsDialog(this.aspectsPerfs, boolSpring, false);

	}

	private void packageJar() {
		saveConfiguration();
		String strSource = "";
		File source = null;
		String strTarget = "";
		if (!this.jrbSpring.isSelected()) {
			strSource = this.rootProject + File.separator
					+ "tmpmyaspectjweaver.jar";
			source = new File(this.rootProject + File.separator
					+ "tmpmyaspectjweaver.jar");

			// on copie de root
			File fbis = new File(System.getProperty("root") + File.separator
					+ "lib" + File.separator + "myaspectjweaver.jar");
			try {
				CopyFile.copy(fbis, source);
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

			strTarget = this.rootProject + File.separator
					+ "myaspectjweaver.jar";
		}

		if (this.jrbSpring.isSelected()) {
			strSource = this.rootProject + File.separator
					+ "tmpspringmyaspectjweaver.jar";
			source = new File(this.rootProject + File.separator
					+ "tmpspringmyaspectjweaver.jar");

			// on copie de root
			File fbis = new File(System.getProperty("root") + File.separator
					+ "lib" + File.separator + "springmyaspectjweaver.jar");
			try {
				CopyFile.copy(fbis, source);
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

			strTarget = this.rootProject + File.separator
					+ "springmyaspectjweaver.jar";
		}

		// recuperer les zipentry de myaspectjweaver.jar
		ZipFile zip;
		ZipOutputStream zos = null;
		FileOutputStream fos = null;
		try {
			zip = new ZipFile(strSource);
			Enumeration entries = zip.entries();
			byte[] buffer = new byte[2048];

			fos = new FileOutputStream(strTarget);
			zos = new ZipOutputStream(fos);

			while (entries.hasMoreElements()) {
				ZipEntry entry = (ZipEntry) entries.nextElement();
				InputStream is = zip.getInputStream(entry);

				ZipEntry entryBis = new ZipEntry(entry.getName());

				int taille = 0;
				if (!entry.getName().equals("META-INF/aop.xml")
						&& !entry.getName().equals(
								"META-INF/aspectsPerf.properties")

						&& entry.getSize() > 0) {
					zos.putNextEntry(entryBis);
					while ((taille = is.read(buffer)) > 0) {
						// System.out.println("taille buffer taille =" +
						// taille);
						zos.write(buffer, 0, taille);
					}
				}
				is.close();
				zos.closeEntry();
			}

			System.out
					.println("rajout des entry aop.xml aspectsPerf.properties");
			// rajout des entruy aop.xml et perfstats.properties

			ZipEntry entryBis = new ZipEntry("META-INF/aop.xml");
			zos.putNextEntry(entryBis);
			zos.write(this.jtaAopXml.getText().getBytes());
			zos.closeEntry();

			entryBis = new ZipEntry("META-INF/aspectsPerf.properties");
			zos.putNextEntry(entryBis);
			zos.write(this.jtaProperties.getText().getBytes());
			zos.closeEntry();

			zos.close();
			fos.close();

		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
			try {
				if (zos != null) {

					zos.close();

				}
				if (fos != null) {
					fos.close();
				}
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}

	}

	private void packageJarFilter() {
		saveConfiguration();
		String strSource = "";
		File source = null;
		String strTarget = "";

		if (!this.jrbSpring.isSelected()) {
			strSource = this.rootProject + File.separator
					+ "tmpmyaspectjweaver.jar";
			source = new File(this.rootProject + File.separator
					+ "tmpmyaspectjweaver.jar");

			// on copie de root
			File fbis = new File(System.getProperty("root") + File.separator
					+ "lib" + File.separator + "myaspectjweaver.jar");
			try {

				CopyFile.copy(fbis, source);

			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

			strTarget = this.rootProject + File.separator
					+ "myaspectjweaver.jar";
		}

		if (this.jrbSpring.isSelected()) {
			strSource = this.rootProject + File.separator
					+ "tmpspringmyaspectjweaver.jar";
			source = new File(this.rootProject + File.separator
					+ "tmpspringmyaspectjweaver.jar");

			// on copie de root
			File fbis = new File(System.getProperty("root") + File.separator
					+ "lib" + File.separator + "springmyaspectjweaver.jar");
			try {
				CopyFile.copy(fbis, source);
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

			strTarget = this.rootProject + File.separator
					+ "springmyaspectjweaver.jar";
		}

		// recuperer les zipentry de myaspectjweaver.jar
		ZipFile zip;
		ZipOutputStream zos = null;
		FileOutputStream fos = null;
		try {
			zip = new ZipFile(strSource);
			Enumeration entries = zip.entries();
			byte[] buffer = new byte[2048];

			fos = new FileOutputStream(strTarget);
			zos = new ZipOutputStream(fos);

			while (entries.hasMoreElements()) {
				ZipEntry entry = (ZipEntry) entries.nextElement();
				InputStream is = zip.getInputStream(entry);

				ZipEntry entryBis = new ZipEntry(entry.getName());

				int taille = 0;
				if (!entry.getName().equals("META-INF/aop.xml")
						&& !entry.getName().equals(
								"META-INF/aspectsPerf.properties")

						&& entry.getSize() > 0) {
					// tester si on doit rentrer l entree
					if (isNecessaryEntry(entry)) {
						zos.putNextEntry(entryBis);

						while ((taille = is.read(buffer)) > 0) {
							// System.out.println("taille buffer taille =" +
							// taille);
							zos.write(buffer, 0, taille);
						}
					}
				}
				is.close();
				zos.closeEntry();
			}

			System.out
					.println("rajout des entry aop.xml aspectsPerf.properties");
			// rajout des entruy aop.xml et perfstats.properties

			ZipEntry entryBis = new ZipEntry("META-INF/aop.xml");
			zos.putNextEntry(entryBis);
			zos.write(this.jtaAopXml.getText().getBytes());
			zos.closeEntry();

			entryBis = new ZipEntry("META-INF/aspectsPerf.properties");
			zos.putNextEntry(entryBis);
			zos.write(this.jtaProperties.getText().getBytes());
			zos.closeEntry();

			zos.close();
			fos.close();

		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
			try {
				if (zos != null) {

					zos.close();

				}
				if (fos != null) {
					fos.close();
				}
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}

	}

	private boolean isNecessaryEntry(ZipEntry entry) {
		boolean take = false;
		for (Pattern pat : patMandatoryFilters) {
			if (pat.matcher(entry.getName()).find()) {
				take = true;
				break;
			}
		}
		if (!take) {
			// On verifie si il fait partie des Aspects choisis
			for (String name : hmAspectsChosen.keySet()) {

				if (entry.getName().contains(name.replaceAll("\\.", "/"))) {
					take = true;
					System.out.println("nameAspect=" + name
							+ " ; entry.getname()=" + entry.getName());
					break;
				}
			}
		}

		return take;
	}

	private void removeAbstractAspectFromAopOnly() {
		// traitement de aop.xml
		// Traitement de aop.xml
		File xml = new File(this.rootProject + File.separator + "aop.xml");

		DocumentBuilderFactory fabrique = DocumentBuilderFactory.newInstance();

		// création d'un constructeur de documents
		DocumentBuilder constructeur;

		try {
			constructeur = fabrique.newDocumentBuilder();

			Document document = constructeur.parse(xml);

			System.out
					.println("Suppression dans AOP seulementTraitement Aspect abstrait");
			// traitement de l aspect abstrait
			boolean trouve = false;
			// cas de l'aspect concret
			NodeList ndList = document.getElementsByTagName("concrete-aspect");
			for (int i = 0, len = ndList.getLength(); i < len; i++) {
				String name = ndList.item(i).getAttributes()
						.getNamedItem("extends").getNodeValue();
				// if (name.equals((String) this.jcbAspects.getSelectedItem()))

				{
					trouve = true;
					System.out.println("Suppression de "
							+ name
							+ " attribut ="
							+ ndList.item(i).getAttributes()
									.getNamedItem("extends").getNodeValue());
					Node nd3 = document.getElementsByTagName("aspects").item(0);
					nd3.removeChild(ndList.item(i));

				}
				if (trouve) {
					break;
				}
			}

			Transformer transformer = TransformerFactory.newInstance()
					.newTransformer();
			transformer.setOutputProperty(OutputKeys.INDENT, "yes");

			FileWriter fw = new FileWriter(xml);
			// initialize StreamResult with File object to save to file
			StreamResult result = new StreamResult(fw);

			DOMSource source = new DOMSource(document);
			transformer.transform(source, result);

			fw.flush();
			fw.close();
			RandomAccessFile raf = new RandomAccessFile(xml, "rw");
			byte[] tabBytes = new byte[(int) raf.length()];
			raf.read(tabBytes);
			this.jtaAopXml.setEditable(true);
			this.jtaAopXml.setText(new String(tabBytes));
			this.jtaAopXml.setEditable(false);
			raf.close();

		} catch (ParserConfigurationException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SAXException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (TransformerException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	private void removeAspect() {
		// Traitement de perfStats.properties
		for (int i = 0, len = this.tabJlIntra.length; i < len; i++) {

			if (customProps.containsKey(tabJlIntra[i].getText())) {

				customProps.remove(tabJlIntra[i].getText());

			}

		}
		// Resaauver les properties
		File f = new File(this.rootProject + File.separator
				+ "aspectsPerf.properties");
		FileOutputStream fos;
		try {
			fos = new FileOutputStream(f);

			customProps.store(fos, "Saved on "
					+ Calendar.getInstance().getTime().toString());

			fos.close();

			RandomAccessFile raf = new RandomAccessFile(f, "r");
			int len = (int) raf.length();
			byte[] tabBytes = new byte[len];
			raf.readFully(tabBytes);
			this.jtaProperties.setEditable(true);
			this.jtaProperties.setText(new String(tabBytes));
			this.jtaProperties.setEditable(false);
			raf.close();
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		// traitement de aop.xml
		// Traitement de aop.xml
		File xml = new File(this.rootProject + File.separator + "aop.xml");

		DocumentBuilderFactory fabrique = DocumentBuilderFactory.newInstance();

		// création d'un constructeur de documents
		DocumentBuilder constructeur;

		try {
			constructeur = fabrique.newDocumentBuilder();

			Document document = constructeur.parse(xml);

			if (type.toLowerCase().equals("concrete")) {
				System.out.println("Traitement Aspect concret");
				NodeList ndList = document.getElementsByTagName("aspect");
				boolean trouve = false;
				// cas de l'aspect concret
				for (int i = 0, len = ndList.getLength(); i < len; i++) {
					String name = ndList.item(i).getAttributes()
							.getNamedItem("name").getNodeValue();
					// if (name.equals((String)
					// this.jcbAspects.getSelectedItem()))
					{
						trouve = true;

						System.out.println("Suppression de "
								+ name
								+ " attribut ="
								+ ndList.item(i).getAttributes()
										.getNamedItem("name").getNodeValue());

						Node nd3 = document.getElementsByTagName("aspects")
								.item(0);

						nd3.removeChild(ndList.item(i));

					}
					if (trouve) {
						break;
					}
				}

				Transformer transformer = TransformerFactory.newInstance()
						.newTransformer();
				transformer.setOutputProperty(OutputKeys.INDENT, "yes");

				FileWriter fw = new FileWriter(xml);
				// initialize StreamResult with File object to save to file
				StreamResult result = new StreamResult(fw);

				DOMSource source = new DOMSource(document);
				transformer.transform(source, result);

				fw.flush();
				fw.close();

			} else {
				System.out.println("Traitement Aspect abstrait");
				// traitement de l aspect abstrait
				boolean trouve = false;
				// cas de l'aspect concret
				NodeList ndList = document
						.getElementsByTagName("concrete-aspect");
				for (int i = 0, len = ndList.getLength(); i < len; i++) {
					String name = ndList.item(i).getAttributes()
							.getNamedItem("extends").getNodeValue();
					// if (name.equals((String)
					// this.jcbAspects.getSelectedItem()))
					{
						trouve = true;
						System.out
								.println("Suppression de "
										+ name
										+ " attribut ="
										+ ndList.item(i).getAttributes()
												.getNamedItem("extends")
												.getNodeValue());
						Node nd3 = document.getElementsByTagName("aspects")
								.item(0);
						nd3.removeChild(ndList.item(i));

					}
					if (trouve) {
						break;
					}
				}

				Transformer transformer = TransformerFactory.newInstance()
						.newTransformer();
				transformer.setOutputProperty(OutputKeys.INDENT, "yes");

				FileWriter fw = new FileWriter(xml);
				// initialize StreamResult with File object to save to file
				StreamResult result = new StreamResult(fw);

				DOMSource source = new DOMSource(document);
				transformer.transform(source, result);

				fw.flush();
				fw.close();

			}

		} catch (ParserConfigurationException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SAXException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (TransformerException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	private void addUpdateAspect() {

		// Traitement de perfStats.properties

		for (int i = 0, len = this.tabJlIntra.length; i < len; i++) {

			if (!tabJlIntra[i].getText().contains(".pointcut /")) {

				customProps.put(tabJlIntra[i].getText(),
						((JTextField) tabJlIntra[i].getLabelFor()).getText());
			}
			if (tabJlIntra[i].getText().endsWith(".type")) {
				type = ((JTextField) tabJlIntra[i].getLabelFor()).getText();
			}

		}
		// sauvegarde

		File f = new File(this.rootProject + File.separator
				+ "aspectsPerf.properties");
		FileOutputStream fos;
		try {
			fos = new FileOutputStream(f);

			customProps.store(fos, "Saved on "
					+ Calendar.getInstance().getTime().toString());

			fos.close();

			RandomAccessFile raf = new RandomAccessFile(f, "r");
			int len = (int) raf.length();
			byte[] tabBytes = new byte[len];
			raf.readFully(tabBytes);
			this.jtaProperties.setEditable(true);
			this.jtaProperties.setText(new String(tabBytes));
			this.jtaProperties.setEditable(false);
			raf.close();
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		// Traitement de aop.xml
		File xml = new File(this.rootProject + File.separator + "aop.xml");

		DocumentBuilderFactory fabrique = DocumentBuilderFactory.newInstance();

		// création d'un constructeur de documents
		DocumentBuilder constructeur;

		try {
			constructeur = fabrique.newDocumentBuilder();

			Document document = constructeur.parse(xml);

			if (type.toLowerCase().equals("concrete")) {
				System.out.println("Traitement Aspects concrete");
				NodeList ndList = document.getElementsByTagName("aspect");
				boolean trouve = false;
				// cas de l'aspect concret
				for (int i = 0, len = ndList.getLength(); i < len; i++) {
					String name = ndList.item(i).getAttributes()
							.getNamedItem("name").getNodeValue();
					// if (name.equals((String)
					// this.jcbAspects.getSelectedItem()))
					{
						trouve = true;
					}
					/*
					 * System.out.println("attribut =" +
					 * ndList.item(i).getAttributes().getNamedItem(
					 * "name").getNodeValue());
					 */
				}

				if (!trouve) {
					System.out
							.println("Traitement Aspects concrete ; ajout tags aspects aspect");
					// on ajoute
					NodeList nd = document.getElementsByTagName("aspects");
					Node nd1 = (Node) nd.item(0);
					Node newNode = document.createElement("aspect");

					NamedNodeMap aspectsAttributes = newNode.getAttributes();
					Attr name = document.createAttribute("name");
					// JLP TODO
					// name.setValue((String)
					// this.jcbAspects.getSelectedItem());

					aspectsAttributes.setNamedItem(name);
					nd1.appendChild(newNode);

				}
				Transformer transformer = TransformerFactory.newInstance()
						.newTransformer();
				transformer.setOutputProperty(OutputKeys.INDENT, "yes");

				FileWriter fw = new FileWriter(xml);
				// initialize StreamResult with File object to save to file
				StreamResult result = new StreamResult(fw);

				DOMSource source = new DOMSource(document);
				transformer.transform(source, result);

				fw.flush();
				fw.close();

			} else {

				// traitement de l aspect abstrait
				boolean trouve = false;
				// cas de l'aspect concret
				NodeList ndList = document
						.getElementsByTagName("concrete-aspect");

				int j = 0;
				for (int i = 0, len = ndList.getLength(); i < len; i++) {
					String name = ndList.item(i).getAttributes()
							.getNamedItem("extends").getNodeValue();
					// if (name.equals((String)
					// this.jcbAspects.getSelectedItem()))
					{
						trouve = true;
						j = i;
						System.out.println("Trouve j=" + j);
						System.out.println(" ndList.item(i).getNodeType() ="
								+ ndList.item(i).getNodeType());
						// break;
					}

					/*
					 * System.out.println("attribut =" +
					 * ndList.item(i).getAttributes().getNamedItem(
					 * "extends").getNodeValue());
					 */
					if (trouve)
						i = len;
				}

				if (!trouve) {
					// creation du node
					NodeList nd = document.getElementsByTagName("aspects");
					Node nd1 = (Node) nd.item(0);
					Node newNode = document.createElement("concrete-aspect");

					NamedNodeMap aspectsAttributes = newNode.getAttributes();
					Attr name = document.createAttribute("name");
					// JLP TODO
					// name.setValue((String) this.jcbAspects.getSelectedItem()+
					// "Impl");
					aspectsAttributes.setNamedItem(name);

					Attr impl = document.createAttribute("extends");
					// impl.setValue((String)
					// this.jcbAspects.getSelectedItem());
					// JLP TODO
					aspectsAttributes.setNamedItem(impl);

					nd1.appendChild(newNode);

					// Ajout du pointcut a concrete-aspects
					Node pointcut = document.createElement("pointcut");
					NamedNodeMap pointcutAttributes = pointcut.getAttributes();

					Attr namebis = document.createAttribute("name");
					namebis.setValue(this.strPointcut);
					pointcutAttributes.setNamedItem(namebis);

					Attr expression = document.createAttribute("expression");
					expression.setValue(this.jtaPointcut.getText());
					pointcutAttributes.setNamedItem(expression);

					newNode.appendChild(pointcut);

				} else {
					// trouve
					// On detruit dans AOP Seulement pour reconstruire.
					removeAbstractAspectFromAopOnly();
					saveConfiguration();
					xml = new File(this.rootProject + File.separator
							+ "aop.xml");

					fabrique = DocumentBuilderFactory.newInstance();

					// création d'un constructeur de documents
					constructeur = fabrique.newDocumentBuilder();

					document = constructeur.parse(xml);

					NodeList nd = document.getElementsByTagName("aspects");
					Node nd1 = (Node) nd.item(0);
					Node newNode = document.createElement("concrete-aspect");

					NamedNodeMap aspectsAttributes = newNode.getAttributes();
					Attr name = document.createAttribute("name");
					// JLP TODO
					// name.setValue((String) this.jcbAspects.getSelectedItem()
					// + "Impl");
					aspectsAttributes.setNamedItem(name);

					Attr impl = document.createAttribute("extends");
					// JLP TODO
					// impl.setValue((String)
					// this.jcbAspects.getSelectedItem());
					aspectsAttributes.setNamedItem(impl);

					nd1.appendChild(newNode);

					// Ajout du pointcut a concrete-aspects
					Node pointcut = document.createElement("pointcut");
					NamedNodeMap pointcutAttributes = pointcut.getAttributes();

					Attr namebis = document.createAttribute("name");
					namebis.setValue(this.strPointcut);
					pointcutAttributes.setNamedItem(namebis);

					Attr expression = document.createAttribute("expression");
					expression.setValue(this.jtaPointcut.getText());
					pointcutAttributes.setNamedItem(expression);

					newNode.appendChild(pointcut);

				}
				Transformer transformer = TransformerFactory.newInstance()
						.newTransformer();
				transformer.setOutputProperty(OutputKeys.INDENT, "yes");

				FileWriter fw = new FileWriter(xml);
				// initialize StreamResult with File object to save to file
				StreamResult result = new StreamResult(fw);

				DOMSource source = new DOMSource(document);
				transformer.transform(source, result);

				fw.flush();
				fw.close();

			}

		} catch (ParserConfigurationException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SAXException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (TransformerException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	public void saveConfigurationOld() {
	}

	public void saveConfiguration() {
		String foot = "";
		RandomAccessFile rafFoot = null;

		// Sauvegarde des fichiers perfstat.properties
		// sauvegarde des valeurs par défaut :

		customProps.put("aspectsPerf.default.filelogs", "/tmp/aspectj.log");
		customProps.put("aspectsPerf.default.filegzip", "true");
		customProps.put("aspectsPerf.default.dirLogs",
				this.jtfDirLogs.getText());
		customProps.put("aspectsPerf.default.sep", this.jtfSep.getText());

		if (this.jrbSpring.isSelected()) {
			customProps.put("aspectsPerf.springAppli", "true");
		} else {
			customProps.put("aspectsPerf.springAppli", "false");
		}
		if (this.jrbGzip.isSelected()) {
			customProps.put("aspectsPerf.default.filegzip", "true");
		} else {
			customProps.put("aspectsPerf.default.filegzip", "false");
		}
		if (this.jrbDebug.isSelected()) {
			customProps.put("aspectsPerf.debugMode", "true");
			try {
				rafFoot = new RandomAccessFile(System.getProperty("root")
						+ File.separator + "config" + File.separator
						+ "footAopXmlDebug.txt", "r");
			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} else {
			customProps.put("aspectsPerf.debugMode", "false");
		}
		if (this.jrbVerbose.isSelected()) {
			customProps.put("aspectsPerf.verboseMode", "true");
			try {
				rafFoot = new RandomAccessFile(System.getProperty("root")
						+ File.separator + "config" + File.separator
						+ "footAopXmlVerbose.txt", "r");
			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} else {
			customProps.put("aspectsPerf.verboseMode", "false");
		}
		if (!this.jrbDebug.isSelected() && !this.jrbVerbose.isSelected()) {
			try {
				rafFoot = new RandomAccessFile(System.getProperty("root")
						+ File.separator + "config" + File.separator
						+ "footAopXml.txt", "r");
			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		this.dirLogs = this.jtfDirLogs.getText();
		customProps.put("aspectsPerf.default.dirInstall",
				this.jtfDirInstall.getText());
		this.dirInstall = this.jtfDirInstall.getText();
		customProps.put("aspectsPerf.handleSignal", this.currentSignal);
		System.out.println("currentSignal =" + currentSignal);

		Properties tmpProps = new Properties();
		File f = new File(this.rootProject + File.separator
				+ "aspectsPerf.properties");

		FileOutputStream fos;
		try {
			fos = new FileOutputStream(f);
			customProps.store(fos, "Saved on "
					+ Calendar.getInstance().getTime().toString());
			fos.close();
			RandomAccessFile raf = new RandomAccessFile(f, "r");
			int len = (int) raf.length();
			byte[] tabBytes = new byte[len];
			raf.readFully(tabBytes);
			this.jtaProperties.setEditable(true);
			this.jtaProperties.setText(new String(tabBytes));
			raf.close();
			this.jtaProperties.setEditable(false);

		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		f = new File(this.rootProject + File.separator + "aop.xml");

		// On recree le fichier de toute piece a partir de InfoAspects

		RandomAccessFile raf;
		try {
			raf = new RandomAccessFile(f, "rw");
			raf.getChannel().truncate(0);
			raf.writeBytes("<?xml version=\"1.0\" encoding=\"ISO-8859-1\" standalone=\"no\"?>");
			raf.writeBytes("<aspectj>");
			raf.writeBytes("\n");
			raf.writeBytes("\n");
			raf.writeBytes("\t<aspects>");
			raf.writeBytes("\n");
			Set keys = AspectsPerf.hmAspectsChosen.keySet();
			Iterator<String> it = (Iterator<String>) keys.iterator();
			while (it.hasNext()) {
				String key = it.next();
				InfoAspect iA = AspectsPerf.hmAspectsChosen.get(key);
				if (iA.type.equals("abstract")) {
					raf.writeBytes("\t\t<concrete-aspect extends=\"" + key
							+ "\" name=\"" + key + "Impl\">");
					raf.writeBytes("\n");
					raf.writeBytes("\t\t\t<pointcut expression=\""
							+ iA.expression + "\" name=\"" + iA.pointCut
							+ "\"/>");
					raf.writeBytes("\n");
					raf.writeBytes("\t\t</concrete-aspect>");
					raf.writeBytes("\n");
				}
				if (iA.type.equals("concrete")) {
					raf.writeBytes("\t\t<aspect name=\"" + key + "\"");
					if (iA.scope.length() > 0) {
						raf.writeBytes(" scope=\"" + iA.scope + "\"");
					}
					if (iA.requires.length() > 0) {
						raf.writeBytes(" requires=\"" + iA.requires + "\"");
					}
					raf.writeBytes("/>");
					raf.writeBytes("\n");
				}
			}
			raf.writeBytes("\t</aspects>");
			raf.writeBytes("\n");
			long len = rafFoot.length();
			byte[] tabBytes = new byte[(int) len];
			rafFoot.readFully(tabBytes);
			raf.write(tabBytes);
			raf.close();
			rafFoot.close();
			raf = new RandomAccessFile(f, "rw");
			len = raf.length();
			tabBytes = new byte[(int) len];
			raf.readFully(tabBytes);
			this.jtaAopXml.setEditable(true);
			this.jtaAopXml.setText(new String(tabBytes));
			raf.close();
			this.jtaAopXml.setEditable(false);
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		String tmpDirInstall = dirInstall;
		String sep = "/";
		if (this.jTableConnections.getValueAt(0, 3).toString().equals("unix")) {
			sep = "/";
		} else {
			sep = "\\";
		}

		if (!tmpDirInstall.endsWith(sep)) {
			tmpDirInstall += sep;
		}
		String agent = "";
		if (this.jrbSpring.isSelected()) {
			agent = tmpDirInstall + sep + "springmyaspectjweaver.jar\"";
		}
		if (!this.jrbSpring.isSelected()) {
			agent = tmpDirInstall + sep + "myaspectjweaver.jar\"";
		}

		// Sauvegarde du fichier de connexion perfStats.xml

		String fullPathperfStatsXml = new StringBuilder(
				System.getProperty("workspace")).append(File.separator)
				.append(AspectsPackager.currentProject).append(File.separator)
				.append("aspectsPerf.xml").toString();

		System.out.println("Fichier à sauver : " + fullPathperfStatsXml);
		fos = null;
		try {
			fos = new FileOutputStream(fullPathperfStatsXml);
			FileChannel fChan = fos.getChannel();

			fChan.truncate(0);
			fos.write("<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n"
					.getBytes());
			fos.write("<aspectsPerf>\n".getBytes());

			fos.write("\t<Connections>\n".getBytes());
			for (int j = 0; j < 20; j++) {
				String str = "";
				if (null != jTableConnections.getValueAt(j, 0).toString()) {
					str = jTableConnections.getValueAt(j, 0).toString();

				}
				if (null != str && str.length() > 0) {
					System.out.println(" str =|" + str + "|");
					fos.write("\t\t<Connection>\n".getBytes());

					fos.write("\t\t\t<IdCnx>".getBytes());
					fos.write(this.jTableConnections.getValueAt(j, 0)
							.toString().getBytes());
					fos.write("</IdCnx>\n".getBytes());

					fos.write("\t\t\t<IpServer>".getBytes());
					fos.write(this.jTableConnections.getValueAt(j, 1)
							.toString().getBytes());
					fos.write("</IpServer>\n".getBytes());

					fos.write("\t\t\t<IpPort>".getBytes());
					fos.write(this.jTableConnections.getValueAt(j, 2)
							.toString().getBytes());
					fos.write("</IpPort>\n".getBytes());

					fos.write("\t\t\t<type>".getBytes());
					fos.write(this.jTableConnections.getValueAt(j, 3)
							.toString().getBytes());
					if (j == 0) {
						AspectsPerf.osType = this.jTableConnections.getValueAt(
								j, 3).toString();
					}
					fos.write("</type>\n".getBytes());

					fos.write("\t\t\t<Login>".getBytes());
					String login = this.jTableConnections.getValueAt(j, 4)
							.toString();
					if (login.contains("&")) {
						login = login.replaceAll("&", "&amp;");
					}
					fos.write(login.getBytes());
					fos.write("</Login>\n".getBytes());

					fos.write("\t\t\t<Password>".getBytes());
					String pass = this.jTableConnections.getValueAt(j, 5)
							.toString();
					if (pass.contains("&")) {
						pass = pass.replaceAll("&", "&amp;");
					}
					fos.write(pass.getBytes());
					fos.write("</Password>\n".getBytes());

					fos.write("\t\t</Connection>\n".getBytes());
				}
			}
			fos.write("\t</Connections>\n".getBytes());
			fos.write("</aspectsPerf>\n".getBytes());
			fos.close();

		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		fill();

	}

	@SuppressWarnings({ "unchecked", "unchecked" })
	public void itemStateChanged(ItemEvent e) {

		if (e.getSource() instanceof JRadioButton) {
			JRadioButton jrb = (JRadioButton) e.getSource();
			if (jrb == this.jrbGzip) {

				if (this.jrbGzip.isSelected()) {

					customProps.setProperty("aspectsPerf.default.filegzip",
							"true");
				} else {
					customProps.setProperty("aspectsPerf.default.filegzip",
							"false");
				}

			}
		}

		if (e.getSource() instanceof JComboBox) {

			JComboBox jcbtmp = (JComboBox) e.getSource();
			System.out.println(" JComboBox Signal = "
					+ ((String) jcbtmp.getSelectedItem()));
			currentSignal = (String) jcbtmp.getSelectedItem();
			AspectsPerf.customProps.put("aspectsPerf.handleSignal",
					currentSignal);
		}
	}

	public void keyTyped(KeyEvent e) {
		// TODO Auto-generated method stub

	}

	public void keyPressed(KeyEvent e) {
		if (e.getSource() instanceof JTable) {
			if (e.getKeyCode() == KeyEvent.VK_DELETE) {

				JTable jt = (JTable) e.getSource();

				DefaultTableModel tm = (DefaultTableModel) jt.getModel();

				int[] rows = jt.getSelectedRows();
				for (int i = rows.length; i > 0; i--) {
					tm.removeRow(rows[i - 1]);
				}
				// ajouter les lignes en fin de tables
				Object[] tabObject = new Object[jt.getColumnCount()];
				String str = "";
				tabObject[0] = str;
				tabObject[1] = str;
				tabObject[2] = str;
				tabObject[4] = str;
				tabObject[5] = str;
				tabObject[3] = "unix";
				for (int i = rows.length; i > 0; i--) {

					tm.addRow(tabObject);
				}
			}
		}

	}

	public void keyReleased(KeyEvent e) {
		// TODO Auto-generated method stub

	}
}
