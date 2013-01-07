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

public class AdresseAppli {
	public AdresseAppli(String idCon, String ipServeur, String portIP,
			String type, String user, String passwd) {
		super();
		this.idCon = idCon;
		this.ipServeur = ipServeur;
		this.portIP = portIP;
		this.type = type;
		this.user = user;
		this.passwd = passwd;
	}
	public String idCon;

	
	public String ipServeur;
	public String portIP;
	public String type;
	public String user;
	public String passwd;
	
}
