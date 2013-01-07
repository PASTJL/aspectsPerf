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
package attachapi.launcher;
import java.io.IOException;

import com.sun.tools.attach.AgentInitializationException;
import com.sun.tools.attach.AgentLoadException;
import com.sun.tools.attach.AttachNotSupportedException;
import com.sun.tools.attach.VirtualMachine;

public class PerfStatsLaunch {
	public  VirtualMachine vm =null;
	public int pidVm=-1;
	 String agent ="";
	 
	public PerfStatsLaunch(int pidVm, String path) {
		super();
		this.pidVm = pidVm;
		this.agent=path;
		 try {
			 
			vm = VirtualMachine.attach(Integer.toString(pidVm));
		} catch (AttachNotSupportedException e) {
			// TODO Auto-generated catch block
			
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public void attachPerfStats()
	{
		try {
			System.out.println("loading agent : "+agent);
			vm.loadAgent(agent,null);
		} catch (AgentLoadException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (AgentInitializationException e) {
			// TODO Auto-generated catch block
			System.out.println("Echec Attach ");
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public void detachPerfStats() 
	{
		try {
			vm.detach();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
   

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		if(args.length!=3)
		{
			System.out.println("usage :\n"+
					"java -classpath <path to myaspectjweaver.jar>:<path to tools.jar> attachapi.launcher.PerfStats pidJVM fullpathToAgent duree surveillance\n");
			System.exit(1);
		}
		PerfStatsLaunch psl=new PerfStatsLaunch(Integer.parseInt(args[0]),args[1]);
		psl.attachPerfStats();
		
			try {
				Thread.sleep(Long.parseLong(args[2]));
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
			psl.detachPerfStats();	
		
		

	}

}
