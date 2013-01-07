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

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JMenuItem;

public class MyActionListener implements ActionListener {

	private AspectsPackager aspectsPackager;

	public MyActionListener(AspectsPackager aspectsPackager) {
		this.aspectsPackager = aspectsPackager;
	}

	public void actionPerformed(ActionEvent e) {
		// TODO Auto-generated method stub
		if (e.getSource() instanceof JMenuItem) {
			System.out.println(" e.getSource()).getName()"
					+ ((JMenuItem) e.getSource()).getName());
			// nettoyage du ContentPane et affichage du JTextArea
			if (((JMenuItem) e.getSource()).getName().equals("newProject")) {
				new CreateDialog(aspectsPackager);
				new AspectsPerf(aspectsPackager);
				aspectsPackager.repaint();

				
				aspectsPackager.getCloseProject().setEnabled(true);

			}
			if (((JMenuItem) e.getSource()).getName().equals("closeProject")) {
				aspectsPackager.setTitle(AspectsPackager.version
						+ " : No Project selected");
				aspectsPackager.removeAll();
				
				aspectsPackager.getCloseProject().setEnabled(false);

			}
			if (((JMenuItem) e.getSource()).getName().equals("openProject")) {

				new OpenDialog(aspectsPackager);
				new AspectsPerf(aspectsPackager);
				aspectsPackager.repaint();

				
				aspectsPackager.getCloseProject().setEnabled(true);
			}

		}

	}

}
