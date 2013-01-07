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
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.Toolkit;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Properties;
import java.util.TreeSet;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JPanel;
import javax.swing.JScrollBar;
import javax.swing.JScrollPane;
import javax.swing.ListSelectionModel;

public abstract class JLPPickList extends JPanel {

	public static ArrayList<String> globalList = new ArrayList<String>(); // @jve:decl-index=0:
	private static final long serialVersionUID = 1L;
	private JPanel jPanel = null;
	private JLabel jLabel = null;
	private JLabel jLabel1 = null;
	private JButton jBAdd = null;
	private JButton jBRemove = null;
	private JButton jButton11 = null;
	private JScrollPane jSAspectsToChoice = null;
	private JList jList1 = null;
	private JScrollPane jSAspectsChoosen = null;
	private JList jList2 = null;

	public static List<String> lst1 = new ArrayList<String>();; // @jve:decl-index=0:
	public static List<String> lst2 = new ArrayList<String>(); // @jve:decl-index=0:

	public static String valueSelectedList1 = ""; // @jve:decl-index=0:
	public static String valueSelectedList2 = ""; // @jve:decl-index=0:
	public String toChoice = "To choice";
	public String chosen = "Chosen";

	/**
	 * This is the default constructor
	 */
	public JLPPickList() {

	}

	private List<String> sortedList(List<String> list) {
		TreeSet<String> tset = new TreeSet<String>(list);

		list.clear();
		for (Iterator<String> it = tset.iterator(); it.hasNext();) {
			list.add(it.next());
		}
		return list;
	}

	/*
	 * public JLPPickList(String toChoice, String chosen) { super();
	 * initialize(toChoice, chosen);
	 * 
	 * this.toChoice = toChoice; this.chosen = chosen;
	 * 
	 * }
	 * 
	 * public JLPPickList(String toChoice, String chosen, ArrayList<String>
	 * lst1) { this(toChoice, chosen); this.lst1 = lst1;
	 * 
	 * globalList = (ArrayList<String>) sortedList(lst1);
	 * this.getJList1().setListData(globalList.toArray());
	 * 
	 * repaint(); }
	 */
	public JLPPickList(String toChoice, String chosen, ArrayList<String> lst1,
			ArrayList<String> lst2) {
		// TODO Auto-generated constructor stub
		initialize(toChoice, chosen);
		this.lst1 = lst1;
		this.lst2 = lst2;
		if (lst1.size() > 0) {
			this.lst1 = (ArrayList<String>) sortedList(lst1);

			this.getJList1().setListData(lst1.toArray());
		} else {
			this.lst1 = new ArrayList<String>();
			this.getJList1().setListData(lst1.toArray());
		}

		if (lst2.size() > 0) {
			this.lst2 = (ArrayList<String>) sortedList(lst2);
			this.getJList2().setListData(lst2.toArray());

		} else {
			this.lst2 = new ArrayList<String>();
			this.getJList2().setListData(lst2.toArray());
		}
		Toolkit tk = Toolkit.getDefaultToolkit();
		Dimension dmTk = tk.getScreenSize();
		this.setPreferredSize(new Dimension(dmTk.width, 700));
		this.setSize(new Dimension(dmTk.width, 700));
		this.setMinimumSize(new Dimension(dmTk.width, 700));
		this.setVisible(true);
		repaint();

	}

	/**
	 * This method initializes this
	 * 
	 * @return void
	 */
	private void initialize(String toChoice, String chosen) {

		GridBagConstraints gridBagConstraints9 = new GridBagConstraints();
		// gridBagConstraints9.fill = GridBagConstraints.BOTH;
		gridBagConstraints9.anchor = GridBagConstraints.CENTER;
		gridBagConstraints9.gridheight = 1;
		gridBagConstraints9.gridx = 0;
		gridBagConstraints9.gridy = 4;
		gridBagConstraints9.ipadx = 14;
		gridBagConstraints9.ipady = 10;
		gridBagConstraints9.gridwidth = 3;
		gridBagConstraints9.insets = new Insets(10, 10, 10, 10);
		JLabel jb = new JLabel(
				"If names of Aspects, in the right list, are in red color, you must update their configurations by right clicking on it. Right click also to edit the configuration.");
		jb.setFont(new Font("Arial", Font.BOLD, 16));

		GridBagConstraints gridBagConstraints8 = new GridBagConstraints();
		gridBagConstraints8.fill = GridBagConstraints.BOTH;
		gridBagConstraints8.gridheight = 3;
		gridBagConstraints8.gridx = 2;
		gridBagConstraints8.gridy = 1;
		gridBagConstraints8.ipadx = 14;
		gridBagConstraints8.ipady = 10;
		gridBagConstraints8.weightx = 1.0;
		gridBagConstraints8.weighty = 1.0;
		gridBagConstraints8.insets = new Insets(10, 10, 10, 10);
		GridBagConstraints gridBagConstraints7 = new GridBagConstraints();
		gridBagConstraints7.fill = GridBagConstraints.BOTH;
		gridBagConstraints7.gridheight = 3;
		gridBagConstraints7.gridx = 0;
		gridBagConstraints7.gridy = 1;
		gridBagConstraints7.ipadx = 14;
		gridBagConstraints7.ipady = 10;
		gridBagConstraints7.weightx = 1.0;
		gridBagConstraints7.weighty = 1.0;
		gridBagConstraints7.insets = new Insets(10, 10, 10, 10);
		GridBagConstraints gridBagConstraints6 = new GridBagConstraints();
		gridBagConstraints6.insets = new Insets(10, 10, 10, 10);
		gridBagConstraints6.gridy = 3;
		gridBagConstraints6.ipadx = 80;
		gridBagConstraints6.ipady = 7;
		gridBagConstraints6.gridx = 1;
		gridBagConstraints6.weightx = 1.0;
		gridBagConstraints6.weighty = 1.0;
		GridBagConstraints gridBagConstraints5 = new GridBagConstraints();
		gridBagConstraints5.insets = new Insets(10, 10, 10, 10);
		gridBagConstraints5.gridy = 2;
		gridBagConstraints5.ipadx = 80;
		gridBagConstraints5.ipady = 7;
		gridBagConstraints5.gridx = 1;
		gridBagConstraints5.weightx = 1.0;
		gridBagConstraints5.weighty = 1.0;
		GridBagConstraints gridBagConstraints4 = new GridBagConstraints();
		gridBagConstraints4.insets = new Insets(10, 10, 10, 10);
		gridBagConstraints4.gridy = 1;
		gridBagConstraints4.ipadx = 80;
		gridBagConstraints4.ipady = 7;
		gridBagConstraints4.gridx = 1;
		gridBagConstraints4.weightx = 1.0;
		gridBagConstraints4.weighty = 1.0;
		GridBagConstraints gridBagConstraints3 = new GridBagConstraints();
		gridBagConstraints3.insets = new Insets(10, 10, 10, 10);
		gridBagConstraints3.gridy = 0;
		gridBagConstraints3.ipadx = 80;
		gridBagConstraints3.ipady = 12;
		gridBagConstraints3.gridx = 2;
		GridBagConstraints gridBagConstraints2 = new GridBagConstraints();
		gridBagConstraints2.insets = new Insets(10, 10, 10, 10);
		gridBagConstraints2.gridy = 0;
		gridBagConstraints2.ipadx = 80;
		gridBagConstraints2.ipady = 12;
		gridBagConstraints2.gridx = 0;
		GridBagConstraints gridBagConstraints1 = new GridBagConstraints();

		gridBagConstraints1.gridx = 1;
		gridBagConstraints1.gridy = 1;

		jLabel1 = new JLabel();
		jLabel1.setFont(new Font("Arial", Font.BOLD, 14));
		jLabel1.setText(chosen);
		jLabel = new JLabel();
		jLabel.setFont(new Font("Arial", Font.BOLD, 14));
		jLabel.setText(toChoice);

		this.setLayout(new GridBagLayout());
		this.add(getJPanel(), gridBagConstraints1);
		this.add(jLabel, gridBagConstraints2);
		this.add(jLabel1, gridBagConstraints3);
		this.add(getJBAdd(), gridBagConstraints4);
		this.add(getJBRemove(), gridBagConstraints5);
		this.add(getJButton11(), gridBagConstraints6);
		this.add(getJSAspectsToChoice(), gridBagConstraints7);
		this.add(getJSAspectsChoosen(), gridBagConstraints8);
		this.add(jb, gridBagConstraints9);

	}

	/**
	 * This method initializes jPanel
	 * 
	 * @return javax.swing.JPanel
	 */
	private JPanel getJPanel() {
		if (jPanel == null) {
			jPanel = new JPanel();

			// jPanel.setLayout(new GridBagLayout());
			// Toolkit tk = Toolkit.getDefaultToolkit();
			// Dimension dim = tk.getScreenSize();
			// Dimension dmChooser = new Dimension(dim.width - 100,
			// dim.height - 100);
			// jPanel.setSize(dmChooser);
			// jPanel.setPreferredSize(dmChooser);
		}
		return jPanel;
	}

	/**
	 * This method initializes jBAdd
	 * 
	 * @return javax.swing.JButton
	 */
	private JButton getJBAdd() {
		if (jBAdd == null) {
			jBAdd = new JButton();
			jBAdd.setText("Add > ");
			jBAdd.setFont(new Font("Arial", Font.BOLD, 14));
			jBAdd.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {

					lst1.remove(JLPPickList.valueSelectedList1);
					lst2.add(JLPPickList.valueSelectedList1);
					lst1 = sortedList(lst1);
					lst2 = sortedList(lst2);
					getJList1().setListData(lst1.toArray());
					getJList2().setListData(lst2.toArray());
					repaint();
					treatAdd(JLPPickList.valueSelectedList1);

				}
			});

		}

		return jBAdd;
	}

	public abstract void treatAdd(String valueSelectedList1);

	public abstract void treatRemove(String valueSelectedList2);

	public abstract void treatRemoveAll(List<String> list2);

	/**
	 * This method initializes jBRemove
	 * 
	 * @return javax.swing.JButton
	 */
	private JButton getJBRemove() {
		if (jBRemove == null) {
			jBRemove = new JButton();
			jBRemove.setText(" < Rem ");
			jBRemove.setFont(new Font("Arial", Font.BOLD, 14));
			jBRemove.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {

					lst1.add(JLPPickList.valueSelectedList2);
					lst2.remove(JLPPickList.valueSelectedList2);
					lst1 = JLPPickList.this.sortedList(lst1);
					lst2 = JLPPickList.this.sortedList(lst2);
					getJList1().setListData(lst1.toArray());
					getJList2().setListData(lst2.toArray());
					repaint();

					treatRemove(JLPPickList.valueSelectedList2);
				}
			});

		}
		return jBRemove;
	}

	/**
	 * This method initializes jButton11
	 * 
	 * @return javax.swing.JButton
	 */
	private JButton getJButton11() {
		if (jButton11 == null) {
			jButton11 = new JButton();
			jButton11.setText("<< Rem All");
			jButton11.setFont(new Font("Arial", Font.BOLD, 14));
			jButton11.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {

					lst1.addAll(JLPPickList.this.lst2);

					lst1 = sortedList(lst1);

					getJList1().setListData(lst1.toArray());

					treatRemoveAll(lst2);
					lst2.clear();
					getJList2().setListData(lst2.toArray());
					repaint();
				}
			});

		}
		return jButton11;
	}

	/**
	 * This method initializes jSAspectsToChoice
	 * 
	 * @return javax.swing.JScrollPane
	 */
	private JScrollPane getJSAspectsToChoice() {
		if (jSAspectsToChoice == null) {
			jSAspectsToChoice = new JScrollPane();
			jSAspectsToChoice.setViewportView(getJList1());
		}
		return jSAspectsToChoice;
	}

	/**
	 * This method initializes jList
	 * 
	 * @return javax.swing.JList
	 */
	protected JList getJList1() {
		if (jList1 == null) {
			jList1 = new JList();
			jList1.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
			jList1.addListSelectionListener(new javax.swing.event.ListSelectionListener() {
				public void valueChanged(

				javax.swing.event.ListSelectionEvent e) {
					JScrollBar jscb = JLPPickList.this.jSAspectsToChoice
							.getHorizontalScrollBar();
					int val = jscb.getMaximum();
					JLPPickList.this.jSAspectsToChoice.getHorizontalScrollBar()
							.setValue(val);
					if (null != ((JList) e.getSource()).getSelectedValue()) {
						JLPPickList.valueSelectedList1 = (String) ((JList) e
								.getSource()).getSelectedValue();
						System.out.println("jList1,getSelectedValue()="
								+ JLPPickList.valueSelectedList1);
					}

				}
			});

		}

		return jList1;
	}

	/**
	 * This method initializes jSAspectsChoosen
	 * 
	 * @return javax.swing.JScrollPane
	 */
	private JScrollPane getJSAspectsChoosen() {
		if (jSAspectsChoosen == null) {
			jSAspectsChoosen = new JScrollPane();
			jSAspectsChoosen.setViewportView(getJList2());
		}
		return jSAspectsChoosen;
	}

	/**
	 * This method initializes jList1
	 * 
	 * @return javax.swing.JList
	 */
	public JList getJList2() {
		if (jList2 == null) {
			jList2 = new JList();
			jList2.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
			jList2.addListSelectionListener(new javax.swing.event.ListSelectionListener() {
				public void valueChanged(javax.swing.event.ListSelectionEvent e) {

					JScrollBar jscb = JLPPickList.this.jSAspectsChoosen
							.getHorizontalScrollBar();
					int val = jscb.getMaximum();
					JLPPickList.this.jSAspectsChoosen.getHorizontalScrollBar()
							.setValue(val);
					if (null != ((JList) e.getSource()).getSelectedValue())
						JLPPickList.valueSelectedList2 = (String) ((JList) e
								.getSource()).getSelectedValue();

				}

			});
		}

		return jList2;
	}

	public static void main(String[] args) {
		Properties props = new Properties();
		System.out.println("avant props");
		File f = new File(System.getProperty("root") + File.separator
				+ "config" + File.separator + "aspects.properties");
		try {
			props.load(new FileInputStream(f));
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		System.out.println("apres props");
		String[] names = props.getProperty("names").split(";");

		JFrame jf = new JFrame();

		Toolkit tk = Toolkit.getDefaultToolkit();
		Dimension dim = tk.getScreenSize();
		Dimension dmChooser = new Dimension(dim.width, 700);
		jf.setSize(dmChooser);
		jf.setPreferredSize(dmChooser);

		ArrayList<String> lst1 = new ArrayList<String>();
		ArrayList<String> lst2 = new ArrayList<String>();
		for (int i = 0, len = names.length; i < len; i++) {
			lst1.add(i, names[i]);
		}
		String prefix = "aspect";

		jf.setContentPane(new jlp.perf.aspects.gui.MyPickList(
				"Aspects to choice", "Chosen Aspects", lst1, lst2));
		jf.setVisible(true);
		jf.pack();
	}

} // @jve:decl-index=0:visual-constraint="36,0"

