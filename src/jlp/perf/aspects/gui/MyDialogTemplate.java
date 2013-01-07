package jlp.perf.aspects.gui;

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
import java.io.File;
import java.io.FileFilter;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Map.Entry;
import java.util.Properties;
import java.util.Set;

import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JRadioButton;
import javax.swing.JTextField;

public class MyDialogTemplate extends JDialog implements ActionListener,
		ItemListener {

	private static final long serialVersionUID = 1L;

	private JPanel jContentPane;
	private boolean gen = false;
	private JLabel templateJl;
	private JLabel lbExistingTemplates;
	private JComboBox jcbExistingTemplates;

	private JRadioButton generalTemplateRb;

	private JTextField templateTf;

	private JButton okButton;

	private JButton cancelButton;
	UpdateAspect uAsp = null;

	public MyDialogTemplate(UpdateAspect uAsp) {
		// super(_mgld.getParser().getMyJFrame());
		this.uAsp = uAsp;
		setModal(true);
		this.setAlwaysOnTop(true);
		initialize();

		Toolkit toolkit = Toolkit.getDefaultToolkit();
		this.setSize(new Dimension(700, 350));
		setLocation((toolkit.getScreenSize().width - getWidth()) / 2,
				(toolkit.getScreenSize().height - getHeight()) / 2);
		setVisible(true);
		pack();
		gen = false;

	}

	private void initialize() {

		this.setTitle("Save Template");
		setContentPane(getJContentPane());
	}

	private JPanel getJContentPane() {
		if (jContentPane == null) {
			GridBagConstraints gridBagConstraints5 = new GridBagConstraints();
			gridBagConstraints5.insets = new Insets(14, 12, 50, 33);
			gridBagConstraints5.gridy = 1;
			gridBagConstraints5.ipadx = 20;
			gridBagConstraints5.ipady = -1;
			gridBagConstraints5.gridx = 0;

			GridBagConstraints gridBagConstraints6 = new GridBagConstraints();
			gridBagConstraints6.insets = new Insets(14, 12, 50, 33);
			gridBagConstraints6.gridy = 1;
			gridBagConstraints6.ipadx = 20;
			gridBagConstraints6.ipady = -1;
			gridBagConstraints6.gridx = 1;

			GridBagConstraints gridBagConstraints4 = new GridBagConstraints();
			gridBagConstraints4.insets = new Insets(14, 12, 50, 33);
			gridBagConstraints4.gridy = 3;
			gridBagConstraints4.ipadx = 20;
			gridBagConstraints4.ipady = -1;
			gridBagConstraints4.gridx = 1;
			GridBagConstraints gridBagConstraints3 = new GridBagConstraints();
			gridBagConstraints3.insets = new Insets(14, 42, 50, 43);
			gridBagConstraints3.gridy = 3;
			gridBagConstraints3.ipadx = 20;
			gridBagConstraints3.ipady = -1;
			gridBagConstraints3.gridx = 0;
			GridBagConstraints gridBagConstraints2 = new GridBagConstraints();
			gridBagConstraints2.fill = GridBagConstraints.VERTICAL;
			gridBagConstraints2.gridx = 1;
			gridBagConstraints2.gridy = 2;
			gridBagConstraints2.ipadx = 111;
			gridBagConstraints2.ipady = 6;
			gridBagConstraints2.weightx = 1.0;
			gridBagConstraints2.insets = new Insets(13, 3, 13, 12);
			GridBagConstraints gridBagConstraints1 = new GridBagConstraints();
			gridBagConstraints1.insets = new Insets(14, 5, 13, 2);
			gridBagConstraints1.gridy = 2;
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
			templateJl = new JLabel();
			templateJl.setText("Name of the  Template ");
			templateJl.setFont(new Font("Arial", Font.BOLD, 16));
			this.generalTemplateRb = new JRadioButton("General Template ?");
			this.generalTemplateRb.setSelected(false);
			this.lbExistingTemplates = new JLabel("Existing Templates");
			lbExistingTemplates.setFont(new Font("Arial", Font.BOLD, 16));
			this.jcbExistingTemplates = new JComboBox();
			jcbExistingTemplates.setFont(new Font("Arial", Font.BOLD, 14));
			jContentPane = new JPanel();
			jContentPane.setLayout(new GridBagLayout());
			jContentPane.add(generalTemplateRb, gridBagConstraints);
			generalTemplateRb.setSelected(false);
			jContentPane.add(getTemplateJl(), gridBagConstraints1);
			jContentPane.add(getTemplateTf(), gridBagConstraints2);
			jContentPane.add(getOkButton(), gridBagConstraints3);
			jContentPane.add(getCancelButton(), gridBagConstraints4);
			jContentPane.add(lbExistingTemplates, gridBagConstraints5);
			jContentPane.add(jcbExistingTemplates, gridBagConstraints6);
			generalTemplateRb.addActionListener(this);
			jcbExistingTemplates.addItemListener(this);
			filljcbExistingTemplates();
		}
		return jContentPane;
	}

	private void filljcbExistingTemplates() {
		// cas du template general
		String templates = "";
		if (gen) {

			templates = System.getProperty("root") + File.separator
					+ "templates" + File.separator + "aspectPerf"
					+ File.separator;
			this.lbExistingTemplates.setText("Existing General Templates");

		} else {
			templates = System.getProperty("workspace") + File.separator
					+ uAsp.currentProject + File.separator + "templates"
					+ File.separator + "aspectPerf" + File.separator;
			this.lbExistingTemplates.setText("Existing Local Templates");
		}

		File f = new File(templates);
		jcbExistingTemplates.removeAllItems();
		if (f.exists()) {
			File[] lstFiles = f.listFiles(new FileFilter() {
				public boolean accept(File pathName) {
					// System.out.println("pathName.getName()="+pathName.getName());
					System.out.println("uAsp.getAspectName()="
							+ uAsp.getAspectName());
					if (pathName.getName().startsWith(
							uAsp.getAspectName() + "+_+")) {
						return true;
					}
					return false;
				}

			});

			if (lstFiles.length == 0) {
				this.jcbExistingTemplates.addItem(new String("noTemplates"));
				this.jcbExistingTemplates.setSelectedIndex(0);

			} else {
				for (int i = 0; i < lstFiles.length; i++) {
					if (lstFiles[i].isFile()) {

						this.jcbExistingTemplates.addItem(lstFiles[i].getName()
								.split("\\+_\\+")[1].split("\\.")[0]);
					}
				}
			}
		} else {
			this.jcbExistingTemplates.addItem(new String("noTemplates"));
			this.jcbExistingTemplates.setSelectedIndex(0);
		}
		this.setPreferredSize(new Dimension(500, 350));
		// this.repaint();
	}

	private JTextField getTemplateTf() {
		if (templateTf == null)
			templateTf = new JTextField();
		templateTf.setPreferredSize(new Dimension(200, 20));
		templateTf.setFont(new Font("Arial", Font.BOLD, 14));
		return templateTf;
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
			if (((JButton) e.getSource()).getName().equals("cancel")) {

				dispose();
			}
			if (((JButton) e.getSource()).getName().equals("ok")) {
				if (gen) {
					// TODO Sauver le template general

					String dirGen = System.getProperty("root") + File.separator
							+ "templates" + File.separator + "aspectPerf";
					Properties tmpProps = new Properties();

					System.out.println("Lister CustomsProperties");
					Properties propsToSave = new Properties();
					for (Entry<Object, Object> entry : (Set<Entry<Object, Object>>) AspectsPerf.customProps
							.entrySet()) {
						System.out.println("CustomsProperties "
								+ (String) entry.getKey() + " => "
								+ (String) entry.getValue());
						// On elimine les proprietes des autres Aspects
						if (((String) entry.getKey()).startsWith(uAsp
								.getAspectName() + ".")) {
							propsToSave.put((String) entry.getKey(),
									(String) entry.getValue());
						}

					}
					System.out.println(uAsp.getAspectName() + ".expression =>"
							+ uAsp.jtaExpessionAbstract.getText());
					try {
						System.out.println("sauver dans :" + dirGen
								+ File.separator + uAsp.getAspectName() + "+_+"
								+ this.templateTf.getText() + ".properties");
						FileOutputStream fos = new FileOutputStream(new File(
								dirGen + File.separator + uAsp.getAspectName()
										+ "+_+" + this.templateTf.getText()
										+ ".properties"));

						propsToSave.store(fos, "");
						fos.close();
					} catch (FileNotFoundException e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
					} catch (IOException e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
					}

				} else {
					// TODO sauver le template local

					// TODO Sauver le template general

					String dirLoc = System.getProperty("workspace")
							+ File.separator + uAsp.currentProject
							+ File.separator + "templates" + File.separator
							+ "aspectPerf";
					Properties tmpProps = new Properties();

					System.out.println("Lister CustomsProperties");
					Properties propsToSave = new Properties();
					for (Entry<Object, Object> entry : (Set<Entry<Object, Object>>) AspectsPerf.customProps
							.entrySet()) {
						System.out.println("CustomsProperties "
								+ (String) entry.getKey() + " => "
								+ (String) entry.getValue());
						// On elimine les proprietes des autres Aspects
						if (((String) entry.getKey()).startsWith(uAsp
								.getAspectName() + ".")) {
							propsToSave.put((String) entry.getKey(),
									(String) entry.getValue());
						}

					}
					System.out.println(uAsp.getAspectName() + ".expression =>"
							+ uAsp.jtaExpessionAbstract.getText());
					try {
						System.out.println("sauver dans :" + dirLoc
								+ File.separator + uAsp.getAspectName() + "+_+"
								+ this.templateTf.getText() + ".properties");
						FileOutputStream fos = new FileOutputStream(new File(
								dirLoc + File.separator + uAsp.getAspectName()
										+ "+_+" + this.templateTf.getText()
										+ ".properties"));

						propsToSave.store(fos, "");
						fos.close();
					} catch (FileNotFoundException e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
					} catch (IOException e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
					}

				}

				dispose();
			}

			// TODO Auto-generated method stub

		}
		if (e.getSource() instanceof JRadioButton) {
			JRadioButton jrbtmp = (JRadioButton) e.getSource();
			if (jrbtmp.isSelected()) {
				gen = true;
			} else {
				gen = false;
			}
			filljcbExistingTemplates();
		}
	}

	public JLabel getTemplateJl() {
		return templateJl;
	}

	public void setTemplateJl(JLabel templateJl) {
		this.templateJl = templateJl;
	}

	public void itemStateChanged(ItemEvent e) {

		this.templateTf.setText((String) this.jcbExistingTemplates
				.getSelectedItem());

	}

}
