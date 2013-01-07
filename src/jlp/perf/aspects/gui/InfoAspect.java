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

public class InfoAspect {
	public String fullName = "";
	public String expression = "";
	public String type = ""; // abstract/concrete
	public String pointCut = "";
	public String extensionOf = "";
	public String scope = "";
	public String requires="";
	public Color color=Color.RED;

	public InfoAspect(String fullName, String extensionOf, String expression,
			String type, String pointCut, String scope,String requires,Color color) {
		super();
		this.fullName = fullName;
		this.scope = scope;
		this.expression = expression;
		this.type = type;
		this.pointCut = pointCut;
		this.extensionOf = extensionOf;
		this.requires=requires;
		this.color=color;
	}

}
