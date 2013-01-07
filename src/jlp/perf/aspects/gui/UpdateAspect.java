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
import java.awt.event.WindowEvent;
import java.awt.event.WindowListener;
import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import java.util.Map.Entry;
import java.util.Properties;
import java.util.Set;

import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JDialog;
import javax.swing.JEditorPane;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JRadioButton;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

public class UpdateAspect extends JDialog implements ActionListener,
		WindowListener, ChangeListener, ItemListener {
	public boolean boolFilled = true;

	private MyPickList myPickList = null;
	Properties ownProperties = new Properties();
	private String aspectName = null;

	String currentTemplate = "";

	public String getAspectName() {
		return aspectName;
	}

	public void setAspectName(String aspectName) {
		this.aspectName = aspectName;
	}

	JPanel contentPane = new JPanel();
	JEditorPane jtaComment = new JEditorPane("text/html", "I don't know");
	JTextArea jtaExpessionAbstract = new JTextArea("", 10, 60);
	JTextField jtfFileLogs = new JTextField("defaultAspectLogs");
	JTextField jtfPointCut;
	JTextField jtfType = new JTextField();
	JTextField jtfScope;
	JTextField jtfRequires;
	JButton jbCancel = new JButton("Cancel");
	JButton jbQuitSave = new JButton("Quit and Save");
	JButton jbTemplate = new JButton("Save as template");

	JTextField[] tabJTextField;
	public List<JTextField> lstCstTf = new ArrayList<JTextField>();
	String[] tabProps;
	Dimension dimTextField = new Dimension(400, 30);
	// New JLP
	JRadioButton jrbLocal = new JRadioButton("Local templates ?");
	JComboBox jcbTemplate = new JComboBox();
	public String currentProject = "";

	public UpdateAspect(MyPickList myPickList, String aspect) {
		// TODO Auto-generated constructor stub
		super();
		this.setTitle(aspect);
		this.myPickList = myPickList;
		this.setModal(true);
		aspectName = aspect;
		currentProject = AspectsPerf.currentProject;
		fill();
		MyPickList.boolFilled = true;
		this.jbCancel.addActionListener(this);
		this.jbQuitSave.addActionListener(this);
		this.jbTemplate.addActionListener(this);
		this.addWindowListener(this);
		this.pack();
		Toolkit tk = Toolkit.getDefaultToolkit();
		Dimension dmTk = tk.getScreenSize();

		this.setPreferredSize(new Dimension(dmTk.width, 700));
		// this.setSize(new Dimension(dmTk.width, 700));
		this.setMinimumSize(new Dimension(dmTk.width / 2, 700));
		this.setResizable(true);
		this.setVisible(true);

		this.pack();
		this.repaint();

	}

	private void fill() {
		// TODO Auto-generated method stub

		this.lstCstTf.clear();
		this.setContentPane(contentPane);
		contentPane.setLayout(new GridBagLayout());
		GridBagConstraints gbc = new GridBagConstraints();
		// New JLP
		gbc.insets = new Insets(10, 20, 5, 20);

		gbc.anchor = GridBagConstraints.CENTER;

		gbc.gridwidth = 2;

		// positionnement de 2 comboBox template Local /template general

		jcbTemplate.setMinimumSize(new Dimension(500, 20));
		jcbTemplate.setPreferredSize(new Dimension(500, 20));
		gbc.gridx = 0;
		gbc.gridy = 0;
		jrbLocal.setSelected(true);
		jrbLocal.setFont(new Font("Arial", Font.BOLD, 16));
		contentPane.add(jrbLocal, gbc);
		gbc.gridy = 1;
		gbc.insets = new Insets(5, 20, 10, 20);
		jcbTemplate.setFont(new Font("Arial", Font.BOLD, 16));
		contentPane.add(jcbTemplate, gbc);
		fillComboBox();
		// Initiale properties for the Aspects
		Enumeration<Object> keys = AspectsPackager.allAspectsProps.keys();
		gbc.gridwidth = 1;
		gbc.insets = new Insets(10, 20, 10, 20);
		gbc.weightx = 1.0;
		gbc.fill = GridBagConstraints.BOTH;
		jrbLocal.addChangeListener(this);
		// New JLP
		while (keys.hasMoreElements()) {
			String key = (String) keys.nextElement();
			int index = 0;
			if ((index = key.indexOf(aspectName)) >= 0) {
				if (index == 0
						&& aspectName.equals(key.substring(0,
								key.lastIndexOf(".")))) {
					// on prend
					ownProperties.put(key,
							AspectsPackager.allAspectsProps.get(key));
					System.out.println("key=" + key + " ; aspectName="
							+ aspectName);
				}
			}
			if (index > 0 && aspectName.equals(key.substring(index))) {
				// on prend aussi
				ownProperties
						.put(key, AspectsPackager.allAspectsProps.get(key));
				System.out
						.println("key=" + key + " ; aspectName=" + aspectName);

			}
		}

		if (ownProperties.containsKey("comment." + aspectName)) {
			gbc.gridx = 0;
			gbc.gridy = 2;

			JLabel jb1 = new JLabel("What does I Do ?");
			jb1.setFont(new Font("Arial", Font.BOLD, 16));
			contentPane.add(jb1, gbc);
			jtaComment.setFont(new Font("Arial", Font.BOLD, 12));

			jtaComment.setText(ownProperties.getProperty("comment."
					+ aspectName));
			gbc.gridx = 1;
			jtaComment.setEditable(false);
			contentPane.add(jtaComment, gbc);
		}

		if (ownProperties.containsKey(aspectName + ".filelogs")) {
			System.out.println(" filelogs existe");
			gbc.gridx = 0;
			gbc.gridy = 3;
			JLabel jb1 = new JLabel("File of Logs");
			jb1.setFont(new Font("Arial", Font.BOLD, 16));
			contentPane.add(jb1, gbc);
			jtfFileLogs.setFont(new Font("Arial", Font.BOLD, 12));
			jtfFileLogs.setPreferredSize(this.dimTextField);
			jtfFileLogs.setSize(this.dimTextField);
			jtfFileLogs.setMinimumSize(this.dimTextField);
			jtfFileLogs.setName("filelogs");
			jtfFileLogs.setText(AspectsPerf.customProps.getProperty(aspectName
					+ ".filelogs",
					aspectName.substring(aspectName.lastIndexOf(".") + 1)
							+ ".log"));
			gbc.gridx = 1;
			this.lstCstTf.add(jtfFileLogs);
			contentPane.add(jtfFileLogs, gbc);
		}
		if (ownProperties.containsKey(aspectName + ".type")) {

			gbc.gridx = 0;
			gbc.gridy = 4;
			JLabel jb1 = new JLabel("Type of Aspects");
			jb1.setFont(new Font("Arial", Font.BOLD, 16));
			contentPane.add(jb1, gbc);
			jtfType.setText(ownProperties.getProperty(aspectName + ".type"));
			gbc.gridx = 1;
			jtfType.setFont(new Font("Arial", Font.BOLD, 12));
			jtfType.setPreferredSize(this.dimTextField);
			jtfType.setSize(this.dimTextField);
			jtfType.setMinimumSize(this.dimTextField);
			jtfType.setEditable(false);
			jtfType.setName("type");
			this.lstCstTf.add(jtfType);
			contentPane.add(jtfType, gbc);
		}
		if (!ownProperties.getProperty(aspectName + ".type").equals("concrete")) {
			// Abstract Aspect need extension

			gbc.gridx = 0;
			gbc.gridy = 5;
			JLabel jb1 = new JLabel("Name Of pointCut");
			jb1.setFont(new Font("Arial", Font.BOLD, 16));
			contentPane.add(jb1, gbc);
			jtfPointCut = new JTextField(ownProperties.getProperty(aspectName
					+ ".pointcut"));

			gbc.gridx = 1;
			jtfPointCut.setFont(new Font("Arial", Font.BOLD, 12));
			jtfPointCut.setPreferredSize(this.dimTextField);
			jtfPointCut.setSize(this.dimTextField);
			jtfPointCut.setMinimumSize(this.dimTextField);
			jtfPointCut.setEditable(false);
			jtfPointCut.setName("pointcut");
			this.lstCstTf.add(jtfPointCut);
			contentPane.add(jtfPointCut, gbc);
			gbc.gridx = 0;
			gbc.gridy = 6;
			jb1 = new JLabel("Expression for Abstract Aspect");
			jb1.setFont(new Font("Arial", Font.BOLD, 16));
			contentPane.add(jb1, gbc);
			jtaExpessionAbstract.setLineWrap(true);
			if (AspectsPerf.hmAspectsChosen.containsKey(aspectName)) {
				jtaExpessionAbstract.setText(AspectsPerf.hmAspectsChosen
						.get(aspectName).expression);
			} else {
				jtaExpessionAbstract.setText("");

			}
			jtaExpessionAbstract.setFont(new Font("Arial", Font.BOLD, 12));
			gbc.gridx = 1;
			contentPane.add(jtaExpessionAbstract, gbc);

		} else {
			// Concrete Aspect
			gbc.gridx = 0;
			gbc.gridy = 5;
			JLabel jb1 = new JLabel("Optionnal \"scope\"");
			jb1.setFont(new Font("Arial", Font.BOLD, 16));
			contentPane.add(jb1, gbc);
			jtfScope = new JTextField();
			jtfScope.setName("scope");
			this.lstCstTf.add(jtfScope);
			if (AspectsPerf.hmAspectsChosen.containsKey(aspectName)) {
				jtfScope.setText(AspectsPerf.hmAspectsChosen.get(aspectName).scope);
			} else {
				jtfScope.setText("");
			}
			gbc.gridx = 1;
			jtfScope.setFont(new Font("Arial", Font.BOLD, 12));
			jtfScope.setPreferredSize(this.dimTextField);
			jtfScope.setSize(this.dimTextField);
			jtfScope.setMinimumSize(this.dimTextField);
			contentPane.add(jtfScope, gbc);

			gbc.gridx = 0;
			gbc.gridy = 6;
			jb1 = new JLabel("Optionnal \"requires\"");
			jb1.setFont(new Font("Arial", Font.BOLD, 16));
			contentPane.add(jb1, gbc);
			jtfRequires = new JTextField();
			if (AspectsPerf.hmAspectsChosen.containsKey(aspectName)) {
				jtfRequires
						.setText(AspectsPerf.hmAspectsChosen.get(aspectName).requires);
			} else {
				jtfRequires.setText("");
			}
			gbc.gridx = 1;
			jtfRequires.setName("requires");
			jtfRequires.setFont(new Font("Arial", Font.BOLD, 12));
			jtfRequires.setPreferredSize(this.dimTextField);
			jtfRequires.setSize(this.dimTextField);
			jtfRequires.setMinimumSize(this.dimTextField);
			this.lstCstTf.add(jtfRequires);
			contentPane.add(jtfRequires, gbc);

		}

		Enumeration otherOwnProps = ownProperties.keys();
		int nbElement = 0;
		while (otherOwnProps.hasMoreElements()) {
			String key = (String) otherOwnProps.nextElement();
			if (!key.contains(".filelogs") && !key.contains("comment.")
					&& !key.contains(".pointcut")) {
				nbElement++;

			}

		}
		this.tabProps = new String[nbElement];
		this.tabJTextField = new JTextField[nbElement];
		otherOwnProps = ownProperties.keys();
		int i = 0;
		while (otherOwnProps.hasMoreElements()) {
			String key = (String) otherOwnProps.nextElement();
			if (!key.contains(".filelogs") && !key.contains("comment.")
					&& !key.contains(".type") && !key.contains(".pointcut")) {
				// on traite
				gbc.gridx = 0;
				gbc.gridy += 1;
				String tmpStr = (String) ownProperties.getProperty(key);
				System.out.println("UpdateAspect key=" + key + " ; ");
				String strJl = tmpStr.substring(tmpStr.lastIndexOf(".") + 1);
				System.out.println("UpdateAspect key=" + key + " ; name props="
						+ strJl);
				JLabel jb1 = new JLabel(strJl);
				jb1.setFont(new Font("Arial", Font.BOLD, 16));
				contentPane.add(jb1, gbc);
				gbc.gridx = 1;
				String str = AspectsPerf.customProps.getProperty(
						ownProperties.getProperty(key), "");
				this.tabJTextField[i] = new JTextField(str);

				this.tabJTextField[i].setFont(new Font("Arial", Font.BOLD, 12));
				this.tabJTextField[i].setPreferredSize(this.dimTextField);
				this.tabJTextField[i].setSize(this.dimTextField);
				this.tabJTextField[i].setMinimumSize(this.dimTextField);
				contentPane.add(this.tabJTextField[i], gbc);
				tabProps[i] = ownProperties.getProperty(key);
				tabJTextField[i].setName(strJl);
				this.lstCstTf.add(tabJTextField[i]);
				i++;
			}
		}

		gbc.fill = GridBagConstraints.HORIZONTAL;
		gbc.gridx = 0;
		gbc.gridy += 1;
		gbc.gridwidth = 2;
		JPanel jp = new JPanel();

		jp.setLayout(new GridBagLayout());
		contentPane.add(jp, gbc);
		GridBagConstraints gbc2 = new GridBagConstraints();
		gbc2.fill = GridBagConstraints.NONE;
		gbc2.weightx = 1.0;
		gbc2.gridx = 0;
		gbc2.gridy = 0;
		jbCancel.setFont(new Font("Arial", Font.BOLD, 16));
		jp.add(jbCancel, gbc2);
		gbc2.gridx = 1;
		jbTemplate.setFont(new Font("Arial", Font.BOLD, 16));
		jp.add(jbTemplate, gbc2);
		gbc2.gridx = 2;
		jbQuitSave.setFont(new Font("Arial", Font.BOLD, 16));
		jp.add(jbQuitSave, gbc2);
		this.jcbTemplate.addItemListener(this);

	}

	private final void fillComboBox() {
		// nettoyage()
		jcbTemplate.removeAllItems();
		// On recherche les templates en fonction de laspect choisi et de l etat
		// du radio button du template
		if (this.jrbLocal.isSelected()) {
			// recherche dans local.
			String repLocTempl = System.getProperty("workspace")
					+ File.separator + AspectsPerf.currentProject
					+ File.separator + "templates" + File.separator
					+ "aspectPerf";
			if (!new File(repLocTempl).exists()) {
				// on cree le repertoire
				new File(repLocTempl).mkdirs();
			}
			System.out.println("aspectName=" + aspectName);
			// Lister les fichiers dont le nom commence par le nom de l aspect
			File[] tabFile = new File(repLocTempl).listFiles(new FileFilter() {
				public boolean accept(File pathName) {
					if (pathName.getName().startsWith(aspectName + "+_+")) {
						return true;
					}
					return false;
				}
			});
			if (null != tabFile && tabFile.length > 0) {
				// garnir la combobox
				// Premier index "Select A Template"
				this.jcbTemplate.insertItemAt("Select a local template", 0);

				for (int i = 0; i < tabFile.length; i++) {
					System.out.println("FileName=" + tabFile[i].getName());

					this.jcbTemplate.insertItemAt(
							tabFile[i].getName().split("\\+_\\+")[1]
									.split("\\.")[0], i + 1);
				}
			} else {
				// garnir la combobox avec No Template Available
				this.jcbTemplate.insertItemAt("No Template Available", 0);
			}
		} else {
			// recherche dans general
			String repLocGen = System.getProperty("root") + File.separator
					+ "templates" + File.separator + "aspectPerf";
			if (!new File(repLocGen).exists()) {
				// on cree le repertoire
				new File(repLocGen).mkdirs();
			}

			System.out.println("aspectName=" + aspectName);
			// Lister les fichiers dont le nom commence par le nom de l aspect
			File[] tabFile = new File(repLocGen).listFiles(new FileFilter() {
				public boolean accept(File pathName) {
					if (pathName.getName().startsWith(aspectName + "+_+")) {
						return true;
					}
					return false;
				}
			});
			if (null != tabFile && tabFile.length > 0) {
				// garnir la combobox
				// Premier index "Select A Template"
				this.jcbTemplate.insertItemAt("Select a general template", 0);
				for (int i = 0; i < tabFile.length; i++) {
					this.jcbTemplate.insertItemAt(
							tabFile[i].getName().split("\\+_\\+")[1]
									.split("\\.")[0], i + 1);
				}
			} else {
				// garnir la combobox avec No Template Available
				this.jcbTemplate.insertItemAt("No available template", 0);
			}
		}
		jcbTemplate.setSelectedIndex(0);
	}

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private JTextField findTfByName(String name) {

		for (JTextField tf : this.lstCstTf) {
			if (tf.getName().equals(name))
				return tf;
		}

		return null;
	}

	public void actionPerformed(ActionEvent e) {
		System.out.println("yes !!!");
		if (e.getSource() instanceof JButton) {
			JButton jbTmp = (JButton) e.getSource();
			if (jbTmp == jbCancel) {
				System.out.println("Cancel");
				this.dispose();
			}

			if (jbTmp == jbQuitSave) {
				InfoAspect iA = AspectsPerf.hmAspectsChosen.get(aspectName);
				if (null != tabJTextField) {
					for (int i = 0; i < tabJTextField.length; i++) {
						if (null != tabJTextField[i]
								&& (null == tabJTextField[i].getText() || tabJTextField[i]
										.getText().length() < 1)) {
							MyPickList.boolFilled = false;
						}

					}
				}
				if (!ownProperties.getProperty(aspectName + ".type").equals(
						"concrete")
						&& jtaExpessionAbstract.getText().length() < 1) {
					MyPickList.boolFilled = false;
					AspectsPerf.customProps.put(aspectName + ".type",
							ownProperties.getProperty(aspectName + ".type"));
					iA.expression = jtaExpessionAbstract.getText();
				}

				if (ownProperties.containsKey(aspectName + ".filelogs")) {
					AspectsPerf.customProps.put(aspectName + ".filelogs",
							this.jtfFileLogs.getText());
				}
				if (ownProperties.containsKey(aspectName + ".type")) {
					AspectsPerf.customProps.put(aspectName + ".type",
							this.jtfType.getText());
				}

				if (jtfType.getText().equals("abstract")) {
					// cas Aspect Abstrait
					iA.pointCut = this.jtfPointCut.getText();
					iA.expression = this.jtaExpessionAbstract.getText();
					AspectsPerf.customProps.put(aspectName + ".expression",
							iA.expression);
					iA.extensionOf = aspectName + "Impl";
					iA.type = "abstract";

				}

				if (jtfType.getText().equals("concrete")) {
					// cas Aspect Concret
					iA.type = "concrete";

					if (this.jtfRequires.getText().length() > 0)
						iA.requires = this.jtfRequires.getText();
					if (this.jtfScope.getText().length() > 0)
						iA.requires = this.jtfScope.getText();
				}
				// TODO JLP

				if (MyPickList.boolFilled) {
					iA.color = Color.black;
				} else {
					iA.color = Color.red;
				}

				if (null != tabJTextField) {
					for (int i = 0; i < tabJTextField.length; i++) {
						if (null != tabJTextField[i]
								&& null != tabJTextField[i].getText()
								&& tabJTextField[i].getText().length() > 0) {

							AspectsPerf.customProps.put(this.tabProps[i],
									tabJTextField[i].getText());
						}

					}
				}

				AspectsPerf.hmAspectsChosen.put(aspectName, iA);
				// myPickList.getJList2().setCellRenderer(
				// new MyListCellRenderer(JLPPickList.valueSelectedList1,
				// boolFilled));
				this.dispose();
			}
			if (jbTmp == jbTemplate) {

				InfoAspect iA = AspectsPerf.hmAspectsChosen.get(aspectName);
				if (null != tabJTextField) {
					for (int i = 0; i < tabJTextField.length; i++) {
						if (null != tabJTextField[i]
								&& (null == tabJTextField[i].getText() || tabJTextField[i]
										.getText().length() < 1)) {
							MyPickList.boolFilled = false;
						}

					}
				}
				if (!ownProperties.getProperty(aspectName + ".type").equals(
						"concrete")
						&& jtaExpessionAbstract.getText().length() < 1) {
					MyPickList.boolFilled = false;
					AspectsPerf.customProps.put(aspectName + ".type",
							ownProperties.getProperty(aspectName + ".type"));
					iA.expression = jtaExpessionAbstract.getText();
				}

				if (ownProperties.containsKey(aspectName + ".filelogs")) {
					AspectsPerf.customProps.put(aspectName + ".filelogs",
							this.jtfFileLogs.getText());
				}
				if (ownProperties.containsKey(aspectName + ".type")) {
					AspectsPerf.customProps.put(aspectName + ".type",
							this.jtfType.getText());
				}

				if (jtfType.getText().equals("abstract")) {
					// cas Aspect Abstrait
					iA.pointCut = this.jtfPointCut.getText();
					iA.expression = this.jtaExpessionAbstract.getText();
					AspectsPerf.customProps.put(aspectName + ".expression",
							iA.expression);
					AspectsPerf.customProps.put(aspectName + ".pointcut",
							iA.pointCut);
					iA.extensionOf = aspectName + "Impl";
					iA.type = "abstract";

				}

				if (jtfType.getText().equals("concrete")) {
					// cas Aspect Concret
					iA.type = "concrete";

					if (this.jtfRequires.getText().length() > 0)
						iA.requires = this.jtfRequires.getText();
					if (this.jtfScope.getText().length() > 0)
						iA.requires = this.jtfScope.getText();
				}
				// TODO JLP

				if (MyPickList.boolFilled) {
					iA.color = Color.black;
				} else {
					iA.color = Color.red;
				}

				if (null != tabJTextField) {
					for (int i = 0; i < tabJTextField.length; i++) {
						if (null != tabJTextField[i]
								&& null != tabJTextField[i].getText()
								&& tabJTextField[i].getText().length() > 0) {

							AspectsPerf.customProps.put(this.tabProps[i],
									tabJTextField[i].getText());
						}

					}
				}

				AspectsPerf.hmAspectsChosen.put(aspectName, iA);
				// myPickList.getJList2().setCellRenderer(
				// new MyListCellRenderer(JLPPickList.valueSelectedList1,
				// boolFilled));

				new MyDialogTemplate(this);
				this.fillComboBox();
			}
		}

	}

	public void windowOpened(WindowEvent e) {
		// TODO Auto-generated method stub

	}

	public void windowClosing(WindowEvent e) {
		// TODO Auto-generated method stub
		System.out.println("Window is closing");
		InfoAspect iA = AspectsPerf.hmAspectsChosen.get(aspectName);
		if (null != tabJTextField) {
			for (int i = 0; i < tabJTextField.length; i++) {
				if (null != tabJTextField[i]
						&& (null == tabJTextField[i].getText() || tabJTextField[i]
								.getText().length() < 1)) {
					MyPickList.boolFilled = false;
				}

			}
		}
		if (!ownProperties.getProperty(aspectName + ".type").equals("concrete")
				&& jtaExpessionAbstract.getText().length() < 1) {
			MyPickList.boolFilled = false;
		}
		if (MyPickList.boolFilled) {
			iA.color = Color.black;
		} else {
			iA.color = Color.red;
		}

		AspectsPerf.hmAspectsChosen.put(aspectName, iA);

	}

	public void windowClosed(WindowEvent e) {
		// TODO Auto-generated method stub

	}

	public void windowIconified(WindowEvent e) {
		// TODO Auto-generated method stub

	}

	public void windowDeiconified(WindowEvent e) {
		// TODO Auto-generated method stub

	}

	public void windowActivated(WindowEvent e) {
		// TODO Auto-generated method stub

	}

	public void windowDeactivated(WindowEvent e) {
		// TODO Auto-generated method stub

	}

	public void stateChanged(ChangeEvent e) {
		if (e.getSource() instanceof JRadioButton) {
			JRadioButton jrb = (JRadioButton) e.getSource();
			if (jrb == jrbLocal) {
				System.out
						.println("Changing jrbLocal:" + jrbLocal.isSelected());
				fillComboBox();
			}
		}

	}

	public void itemStateChanged(ItemEvent e) {
		// TODO Auto-generated method stub

		if (e.getSource() instanceof JComboBox
				&& e.getStateChange() == ItemEvent.SELECTED) {

			JComboBox jcb = (JComboBox) e.getSource();

			// this.currentTemplate=jcb.getSelectedItem().toString();
			System.out.println("ItemChoosed ="
					+ jcb.getSelectedItem().toString());
			chargerTemplate(jcb.getSelectedItem().toString());
		}
	}

	private void chargerTemplate(String template) {

		if (template.contains("Select a general template")
				|| template.contains("Select a local template")
				|| template.contains("No available template")) {
			return;
		}
		// Trouver le nom du fichier
		String rootTemplate = "";
		if (this.jrbLocal.isSelected()) {
			rootTemplate = System.getProperty("workspace") + File.separator
					+ this.currentProject + File.separator + "templates"
					+ File.separator + "aspectPerf" + File.separator;

		} else {
			rootTemplate = System.getProperty("root") + File.separator
					+ "templates" + File.separator + "aspectPerf"
					+ File.separator;

		}
		Properties tmpProps = new Properties();
		try {
			FileInputStream fis = new FileInputStream(new File(rootTemplate
					+ this.aspectName + "+_+" + template + ".properties"));
			tmpProps.load(fis);
			fis.close();
			for (Entry<Object, Object> entry : (Set<Entry<Object, Object>>) tmpProps
					.entrySet()) {
				if (((String) entry.getKey()).startsWith(aspectName)) {
					// On remplit le composant correspondant a partir du nom
					// traitement particulier de comment
					String nameComponent = ((String) entry.getKey())
							.substring(((String) entry.getKey())
									.lastIndexOf(".") + 1);
					if (nameComponent.equals("expression")) {
						this.jtaExpessionAbstract.setText(((String) entry
								.getValue()));
					} else {
						// on recupere le nom et on remplit le
						// JtextFieldCorrespondant

						System.out.println("JtextField a traiter="
								+ nameComponent);
						JTextField jtf = this.findTfByName(nameComponent);
						if (jtf.isEditable()) {
							jtf.setText(((String) entry.getValue()));
						} else {
							jtf.setEditable(true);
							jtf.setText(((String) entry.getValue()));
							jtf.setEditable(false);
						}

					}
				}

			}
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		// traiter les proprietes

	}

}
