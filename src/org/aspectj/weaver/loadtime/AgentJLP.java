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
package org.aspectj.weaver.loadtime;
import java.lang.instrument.ClassFileTransformer;
import java.lang.instrument.Instrumentation;

// Referenced classes of package org.aspectj.weaver.loadtime:
//            ClassPreProcessorAgentAdapter

public class AgentJLP
{

    public AgentJLP()
    {
    }
    
    public static void premain(String options, Instrumentation instrumentation)
    {
        if(s_instrumentation != null)
        {
            return;
        } else
        {
            s_instrumentation = instrumentation;
            s_instrumentation.addTransformer(s_transformer);
            return;
        }
    }
    public static void agentmain(String options, Instrumentation instrumentation)
    {
    	if(null!=instrumentation)
    	{
    		System.out.println("Instrumentation trouve");
    		
    	}
        if(s_instrumentation != null)
        {
            return;
        } else
        {
            s_instrumentation = instrumentation;
            s_instrumentation.addTransformer(s_transformer);
            return;
        }
    }
    public static Instrumentation getInstrumentation()
    {
        if(s_instrumentation == null)
            throw new UnsupportedOperationException("Java 5 was not started with preMain -javaagent for AspectJ");
        else
            return s_instrumentation;
    }

    private static Instrumentation s_instrumentation;
    private static ClassFileTransformer s_transformer = new ClassPreProcessorAgentAdapter();

}



