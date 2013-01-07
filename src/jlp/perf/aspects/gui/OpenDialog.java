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
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;

import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;



public class OpenDialog  extends JDialog implements ActionListener{

	private AspectsPackager aspectsPackager;
	private static final long serialVersionUID = 1L;

	private JPanel jContentPane;

	private JLabel openProjetLb;

	private JLabel nameProjectLb1;

	private JButton okButton1;

	private JButton cancelButton1;

	private JComboBox projectsJcb = null;

	public OpenDialog(AspectsPackager aspectsPackager) {
		super(aspectsPackager);
		this.aspectsPackager=aspectsPackager;
		setModal(true);
		
		jContentPane = null;
		openProjetLb = null;
		nameProjectLb1 = null;
		okButton1 = null;
		cancelButton1 = null;
		initialize();
		pack();
		Toolkit toolkit = Toolkit.getDefaultToolkit();
		setLocation((toolkit.getScreenSize().width - getWidth()) / 2, (toolkit
				.getScreenSize().height - getHeight()) / 2);
		setVisible(true);
	}
	
	private void initialize() {
		setSize(300, 200);
		this.setTitle("Open Project");
		setContentPane(getJContentPane());
	}

	private JPanel getJContentPane() {
		if (jContentPane == null) {
			GridBagConstraints gridBagConstraints11 = new GridBagConstraints();
			gridBagConstraints11.fill = GridBagConstraints.VERTICAL;
			gridBagConstraints11.gridx = 1;
			gridBagConstraints11.gridy = 1;
			gridBagConstraints11.ipadx = 1;
			gridBagConstraints11.ipady = 6;
			gridBagConstraints11.weightx = 1.0;
			gridBagConstraints11.insets = new Insets(13, 3, 13, 12);
			GridBagConstraints gridBagConstraints4 = new GridBagConstraints();
			gridBagConstraints4.insets = new Insets(14, 12, 50, 33);
			gridBagConstraints4.gridy = 2;
			gridBagConstraints4.ipadx = 20;
			gridBagConstraints4.ipady = -1;
			gridBagConstraints4.gridwidth = 2;
			gridBagConstraints4.gridx = 1;
			GridBagConstraints gridBagConstraints3 = new GridBagConstraints();
			gridBagConstraints3.insets = new Insets(14, 42, 50, 43);
			gridBagConstraints3.gridy = 2;
			gridBagConstraints3.ipadx = 20;
			gridBagConstraints3.ipady = -1;
			gridBagConstraints3.gridx = 0;
			GridBagConstraints gridBagConstraints1 = new GridBagConstraints();
			gridBagConstraints1.insets = new Insets(14, 5, 13, 2);
			gridBagConstraints1.gridy = 1;
			gridBagConstraints1.ipadx = 7;
			gridBagConstraints1.ipady = 8;
			gridBagConstraints1.gridx = 0;
			GridBagConstraints gridBagConstraints = new GridBagConstraints();
			gridBagConstraints.insets = new Insets(7, 67, 12, 85);
			gridBagConstraints.gridx = 0;
			gridBagConstraints.gridy = 0;
			gridBagConstraints.ipadx = 22;
			gridBagConstraints.ipady = -5;
			gridBagConstraints.gridwidth = 2;
			nameProjectLb1 = new JLabel();
			nameProjectLb1.setText("Name of the  Project ");
			nameProjectLb1.setFont(new Font("Arial", Font.BOLD, 14));
			openProjetLb = new JLabel();
			openProjetLb.setText("Open Project");
			openProjetLb.setFont(new Font("Arial", Font.BOLD, 14));
			jContentPane = new JPanel();
			jContentPane.setLayout(new GridBagLayout());
			jContentPane.add(openProjetLb, gridBagConstraints);
			jContentPane.add(nameProjectLb1, gridBagConstraints1);
			jContentPane.add(getOkButton1(), gridBagConstraints3);
			jContentPane.add(getCancelButton1(), gridBagConstraints4);
			jContentPane.add(getProjectsJcb(), gridBagConstraints11);
		}
		return jContentPane;
	}

	private JButton getOkButton1() {
		if (okButton1 == null) {
			okButton1 = new JButton();
			okButton1.setText("OK");
			okButton1.setFont(new Font("Arial", Font.BOLD, 14));
			okButton1.setName("ok1");
			okButton1.addActionListener(this);
		}
		return okButton1;
	}

	private JButton getCancelButton1() {
		if (cancelButton1 == null) {
			cancelButton1 = new JButton();
			cancelButton1.setText("Cancel");
			cancelButton1.setFont(new Font("Arial", Font.BOLD, 14));
			cancelButton1.setPreferredSize(new Dimension(150, 27));
			cancelButton1.setName("cancel1");
			cancelButton1.addActionListener(this);
		}
		return cancelButton1;
	}

	public void actionPerformed(ActionEvent actionevent) {
		if (actionevent.getSource() instanceof JButton) {
			if (((JButton) actionevent.getSource()).getName().equals("cancel1"))
				aspectsPackager.currentProject="";
			aspectsPackager.setTitle(
					aspectsPackager.version+" : No Project selected");
			aspectsPackager.getContentPane().removeAll();
			
			aspectsPackager.getCloseProject().setEnabled(false);

			
			dispose();
			if (((JButton) actionevent.getSource()).getName().equals("ok1")) {
				String project = getProjectsJcb().getSelectedItem().toString();
				if (project.length() < 1) {
					JOptionPane.showMessageDialog(null,
							"You MUST choose a project !!!", "Alert", 0);
					return;
				}
				/*
				 * JOptionPane.showMessageDialog(null, "You have choose project : " +
				 * project, "Information", 1);
				 */
				aspectsPackager
						.setTitle(aspectsPackager.version+
								" : Selected Project  => "
										+ project);
				AspectsPackager.currentProject=project;
				
				aspectsPackager.getCloseProject().setEnabled(true);
				
				dispose();
			}
		}
	}
	private JComboBox getProjectsJcb() {
		if (projectsJcb == null) {
			projectsJcb = new JComboBox();
			try {
				projectsJcb.setSize(100, 20);
				File f = new File(System.getProperty("workspace"));
				File tab[] = f.listFiles();
				int len = tab.length;
				for (int i = 0; i < len; i++) {
					if (tab[i].isDirectory())
						projectsJcb.addItem((String) tab[i].getName());
				}
			} catch (java.lang.Throwable e) {
				// TODO: Something
			}
		}
		return projectsJcb;
	}

}
