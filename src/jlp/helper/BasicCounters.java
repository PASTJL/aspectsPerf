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
package jlp.helper;



public class BasicCounters {
	
	private int sizeTab;
	
	private double[] tabDoubles;
	
	public int getSizeTab() {
		return sizeTab;
	}
	public void setSizeTab(int sizeTab) {
		this.sizeTab = sizeTab;
	}
	public double[] getTabDoubles() {
		return tabDoubles;
	}
	public void TabDoubles(double[] tabDoubles) {
		this.tabDoubles = tabDoubles;
	}
	public BasicCounters(int sizeTab) {
		super();
		
		this.sizeTab=sizeTab;
		tabDoubles=new double[sizeTab];
		for (int i=0;i<sizeTab;i++)
		tabDoubles[i]=0;;
		
	}
	
	
}
