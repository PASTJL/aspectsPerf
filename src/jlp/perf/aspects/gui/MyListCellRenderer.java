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
import java.awt.Component;

import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.ListCellRenderer;

public class MyListCellRenderer extends JLabel implements ListCellRenderer {
	/**
		 * 
		 */
	private static final long serialVersionUID = 1L;
	private String selected;
	private boolean correct = false;

	public MyListCellRenderer( boolean bool) {
		setOpaque(false);
		
		correct = bool;
	}

	public Component getListCellRendererComponent(JList list, Object value,
			int index, boolean isSelected, boolean cellHasFocus) {
		// TODO Auto-generated method stub
		
		Color myColor = getForeground();
		
		if (isSelected) {
			if (correct) {
				
				InfoAspect iA=AspectsPerf.hmAspectsChosen.get(value.toString());
				iA.color=Color.BLACK;
				
				AspectsPerf.hmAspectsChosen.put(value.toString(),iA);;
				setForeground(Color.BLACK);
			} else

			{
				InfoAspect iA=AspectsPerf.hmAspectsChosen.get(value.toString());
				iA.color=Color.RED;
				
				AspectsPerf.hmAspectsChosen.put(value.toString(),iA);;
				
				setForeground(Color.RED);
				
			}
			System.out.println(" MyListCellRenderer.getListCellRendererComponent selected value.toString() :"+ value.toString());
			setText(value.toString());
			setOpaque(true);

		} else {
			System.out.println(" MyListCellRenderer.getListCellRendererComponent not selected value.toString() :"+ value.toString());
			InfoAspect iA=AspectsPerf.hmAspectsChosen.get(value.toString());
			if(null==iA)
			{
				System.out.println (" ia is null");
				
			}
			else
			{
				System.out.println("name ="+iA.fullName);
				Color col=iA.color;
				setForeground(col);
				setText(value.toString());
				setOpaque(false);
				
			}
			

		}
		return this;

	}

}
