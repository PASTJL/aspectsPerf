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
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JTextField;

public class CreateDialog extends JDialog implements ActionListener {
	private AspectsPackager aspectsPackager;
	private static final long serialVersionUID = 1L;

	private JPanel jContentPane;

	private JLabel creationProjetLb;

	private JLabel nameProjectLb;

	private JTextField nameProjectTf;

	private JButton okButton;

	private JButton cancelButton;

	public CreateDialog(AspectsPackager aspectsPackager) {
		this.aspectsPackager = aspectsPackager;
		setModal(true);
		jContentPane = null;
		creationProjetLb = null;
		nameProjectLb = null;
		nameProjectTf = null;
		okButton = null;
		cancelButton = null;
		initialize();
		setVisible(true);
		Toolkit toolkit = Toolkit.getDefaultToolkit();
		setLocation((toolkit.getScreenSize().width - getWidth()) / 2,
				(toolkit.getScreenSize().height - getHeight()) / 2);
	}

	private void initialize() {
		setSize(300, 200);
		this.setTitle("Creation Project");
		setContentPane(getJContentPane());
	}

	private JPanel getJContentPane() {
		if (jContentPane == null) {
			GridBagConstraints gridBagConstraints4 = new GridBagConstraints();
			gridBagConstraints4.insets = new Insets(14, 12, 50, 33);
			gridBagConstraints4.gridy = 2;
			gridBagConstraints4.ipadx = 20;
			gridBagConstraints4.ipady = -1;
			gridBagConstraints4.gridx = 1;
			GridBagConstraints gridBagConstraints3 = new GridBagConstraints();
			gridBagConstraints3.insets = new Insets(14, 42, 50, 43);
			gridBagConstraints3.gridy = 2;
			gridBagConstraints3.ipadx = 20;
			gridBagConstraints3.ipady = -1;
			gridBagConstraints3.gridx = 0;
			GridBagConstraints gridBagConstraints2 = new GridBagConstraints();
			gridBagConstraints2.fill = GridBagConstraints.VERTICAL;
			gridBagConstraints2.gridx = 1;
			gridBagConstraints2.gridy = 1;
			gridBagConstraints2.ipadx = 111;
			gridBagConstraints2.ipady = 6;
			gridBagConstraints2.weightx = 1.0;
			gridBagConstraints2.insets = new Insets(13, 3, 13, 12);
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
			nameProjectLb = new JLabel();
			nameProjectLb.setText("Name of the  Project ");
			nameProjectLb.setFont(new Font("Arial", Font.BOLD, 14));
			creationProjetLb = new JLabel();
			creationProjetLb.setText("Creation  Project");
			creationProjetLb.setFont(new Font("Arial", Font.BOLD, 14));
			jContentPane = new JPanel();
			jContentPane.setLayout(new GridBagLayout());
			jContentPane.add(creationProjetLb, gridBagConstraints);
			jContentPane.add(nameProjectLb, gridBagConstraints1);
			jContentPane.add(getNameProjectTf(), gridBagConstraints2);
			jContentPane.add(getOkButton(), gridBagConstraints3);
			jContentPane.add(getCancelButton(), gridBagConstraints4);
		}
		return jContentPane;
	}

	private JTextField getNameProjectTf() {
		if (nameProjectTf == null)
			nameProjectTf = new JTextField();
		return nameProjectTf;
	}

	private JButton getOkButton() {
		if (okButton == null) {
			okButton = new JButton();
			okButton.setText("OK");
			okButton.setFont(new Font("Arial", Font.BOLD, 14));
			okButton.setName("ok");
			okButton.addActionListener(this);
		}
		return okButton;
	}

	private JButton getCancelButton() {
		if (cancelButton == null) {
			cancelButton = new JButton();
			cancelButton.setText("Cancel");
			cancelButton.setFont(new Font("Arial", Font.BOLD, 14));
			cancelButton.setPreferredSize(new Dimension(150, 27));
			cancelButton.setName("cancel");
			cancelButton.addActionListener(this);
		}
		return cancelButton;
	}

	public void actionPerformed(ActionEvent e) {
		if (e.getSource() instanceof JButton) {
			if (((JButton) e.getSource()).getName().equals("cancel"))
				dispose();
			if (((JButton) e.getSource()).getName().equals("ok")) {
				String project = getNameProjectTf().getText();
				if (project.length() < 1) {
					JOptionPane.showMessageDialog(null,
							"You MUST fill the text field !!!", "Alert", 0);
					return;
				}
				String workspace = System.getProperty("workspace");
				if ((new File((new StringBuilder()).append(workspace)
						.append(File.separator).append(project).toString()))
						.exists()) {
					JOptionPane.showMessageDialog(null,
							"This project already exists !!!", "Alert", 0);
					return;
				}
				File file = new File((new StringBuilder()).append(workspace)
						.append(File.separator).append(project).toString());
				try {
					boolean flag = file.mkdir();
					if (!flag) {
						JOptionPane.showMessageDialog(null,
								"This project can't be create !!!", "Alert", 0);
					} else {

						JOptionPane
								.showMessageDialog(
										null,
										"This project has been successfull created !!!",
										"Information", 1);
						this.aspectsPackager.setTitle(aspectsPackager.version
								+ " : Selected Project  => " + project);
						AspectsPackager.currentProject = project;
						dispose();
					}
				} catch (SecurityException securityexception) {
					JOptionPane.showMessageDialog(
							null,
							(new StringBuilder())
									.append("This project can't be create !!!")
									.append(securityexception.getMessage())
									.toString(), "Alert", 0);
				}
			}
		}

	}

}
