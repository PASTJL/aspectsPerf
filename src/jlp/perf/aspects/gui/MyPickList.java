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
import java.awt.Toolkit;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;

import javax.swing.JList;

public class MyPickList extends jlp.perf.aspects.gui.JLPPickList implements
		MouseListener {

	/**
	 * 
	 */
	public String modifEnCours = "";
	private static final long serialVersionUID = 1L;
	public static boolean boolFilled = true;

	public MyPickList(String string, String string2, ArrayList<String> lst1,
			ArrayList<String> lst2) {
		super("Aspects to choice", "Chosen Aspects", lst1, lst2);
		this.getJList2().addMouseListener(this);
		Toolkit tk = Toolkit.getDefaultToolkit();
		Dimension dmTk = tk.getScreenSize();
		this.setPreferredSize(new Dimension(dmTk.width, 700));
		this.setSize(new Dimension(dmTk.width, 700));
		this.setMinimumSize(new Dimension(dmTk.width, 700));
		this.setVisible(true);
		this.repaint();
	}

	public void treatAdd(String valueSelectedList1) {

		System.out.println("treatAdd " + JLPPickList.valueSelectedList1);
		InfoAspect iA = new InfoAspect(valueSelectedList1, "", "", "", "", "",
				"", Color.RED);
		System.out.println("Mise en hash map de " + valueSelectedList1);
		AspectsPerf.hmAspectsChosen.put(valueSelectedList1, iA);

		this.getJList2().setCellRenderer(new MyListCellRenderer(false));

		this.getJList2().repaint();
		this.getJList1().repaint();

	}

	public void treatRemove(String valueSelectedList2) {
		System.out.println("treatRemove " + JLPPickList.valueSelectedList2);
		// suppimer l'info dans AspectsPerf.AspectsPerf.hmAspectsChosen
		AspectsPerf.hmAspectsChosen.remove(valueSelectedList2);
		// supprimer tooutes les valeurs dans AspectsPerf.customProps
		Enumeration en = AspectsPerf.customProps.keys();
		while (en.hasMoreElements()) {
			String key = (String) en.nextElement();
			if (key.indexOf(valueSelectedList2 + ".") >= 0) {
				// on supprime
				AspectsPerf.customProps.remove(key);
			}
		}

	}

	public void treatRemoveAll(List<String> list2) {
		for (int i = 0, len = list2.size(); i < len; i++)
			treatRemove(list2.get(i));

	}

	public void mouseClicked(MouseEvent e) {
		System.out.println("Mouse Event Origin ="
				+ e.getSource().getClass().getName());
		System.out.println(((JList) e.getSource()).getSelectedValue()
				.toString());

		if (e.getButton() != MouseEvent.BUTTON1) {
			MyPickList.boolFilled = false;
			modifEnCours = ((JList) e.getSource()).getSelectedValue()
					.toString();
			new UpdateAspect(this, modifEnCours);
			this.getJList2().setCellRenderer(
					new MyListCellRenderer(MyPickList.boolFilled));
		}

	}

	public void mousePressed(MouseEvent e) {

	}

	public void mouseReleased(MouseEvent e) {

	}

	public void mouseEntered(MouseEvent e) {

	}

	public void mouseExited(MouseEvent e) {

	}

}
