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
package jlp.perf.aspects.abstractAspects;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.Locale;
import java.util.Properties;

public class AspectsPerfProperties {
	public static Properties aspectsPerfProperties;
	static {
		System.out.println("Chargement fichier properties ");
		
		Locale.setDefault(Locale.ENGLISH);
		
		if (null != System.getProperty("rootAspectsPerf")
				&& System.getProperty("rootAspectsPerf").length() > 0) {
			try {
				aspectsPerfProperties = new Properties();
				aspectsPerfProperties.load(new FileInputStream(new File(System
						.getProperty("rootAspectsPerf")
						+ File.separator
						+ "META-INF"
						+ File.separator
						+ "aspectsPerf.properties")));
				System.out
						.println("Fichier aspectsPerfProperties = "
								+ (System.getProperty("rootAspectsPerf")
										+ File.separator + "META-INF"
										+ File.separator + "aspectsPerf.properties"));
			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				System.out.println("The file : "
						+ System.getProperty("rootAspectsPerf") + File.separator
						+ "META-INF" + File.separator + "aspectsPerf.properties"
						+ " doesn't exist");
				e.printStackTrace();

			} catch (IOException e) {
				System.out.println("IOException The file : "
						+ System.getProperty("rootAspectsPerf") + File.separator
						+ "META-INF" + File.separator + "aspectsPerf.properties"
						+ " doesn't exist");
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		else
		{
			// On cherche dans le jar de l'agent myaspectweaver.jar
			aspectsPerfProperties = new Properties();
			System.out.println("Chargement fichier properties dans le jar");
			InputStream in =AspectsPerfProperties.class.getResourceAsStream("/META-INF/aspectsPerf.properties");
			try {
				aspectsPerfProperties.load(in);
				in.close();
			} catch (IOException e) {
				System.out.println("Erreur ouvrtutr fichier properties");
				e.printStackTrace();
			}
		}

	}
}
