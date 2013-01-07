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


import java.util.Calendar;
import java.util.Locale;
import java.util.Properties;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringWriter;
import java.lang.reflect.InvocationTargetException;

import java.nio.charset.Charset;



public abstract aspect AbstractMethodHttpRequestParameters {
	private static String fileTrace = "";

	private static jlp.perf.aspects.abstractAspects.Trace outMethodHttpRequestParameters;
	
	private static Properties props;
	private static String dirLogs,sep=";";
	private static String[] attributes;
	static {
		Locale.setDefault(Locale.ENGLISH);
		props = jlp.perf.aspects.abstractAspects.AspectsPerfProperties.aspectsPerfProperties;
		if(props.containsKey("aspectsPerf.default.sep"))
		{
			sep=props.
			getProperty("aspectsPerf.default.sep");
		}
		
		if(props.containsKey("aspectsPerf.default.dirLogs"))
		{
			dirLogs = props.
		getProperty("aspectsPerf.default.dirLogs");
			if(!dirLogs.endsWith(File.separator))
			{
				dirLogs+=File.separator;
			}
		}
		else
		{
			dirLogs = "";
		}
		if (props.containsKey("jlp.perf.aspects.abstractAspects.AbstractMethodHttpRequestParameters.filelogs")) {
			fileTrace =dirLogs+  props
					.getProperty("jlp.perf.aspects.abstractAspects.AbstractMethodHttpRequestParameters.filelogs");
		} else {
			fileTrace = props.getProperty("aspectsPerf.default.filelogs");
		}

		if (props.containsKey("jlp.perf.aspects.abstractAspects.AbstractMethodHttpRequestParameters.attributes"))
		{
			attributes=props.getProperty("jlp.perf.aspects.abstractAspects.AbstractMethodHttpRequestParameters.attributes").split(sep);
		}
		outMethodHttpRequestParameters = new Trace("####time"+sep+"Http Attribute"+sep+"Duration\n",fileTrace);
		//outDurationMethods
			//	.append(new StringBuilder(
				//		"####time;Class.methods with  Arguments;time in millisecondes\n")
					//	.toString());

		
	}

	public abstract pointcut methods();

	 Object around(): methods()	 {

		

			

			// Le premier argument est un HTTPServletRequest
			
			Object obj=thisJoinPoint.getArgs()[0];
			InputStream paramInputStream=null;
			String str=null;
			try {
			paramInputStream= (InputStream) obj.getClass().getMethod("getInputStream", (Class[]) null).invoke(obj, (Object[]) null);
			str = jlp.perf.aspects.abstractAspects.AbstractMethodHttpRequestParameters.stringFromIS(paramInputStream, Charset.forName("ISO-8859-1"));
			} catch (IllegalArgumentException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (SecurityException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IllegalAccessException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (InvocationTargetException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (NoSuchMethodException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
			
			long deb=System.currentTimeMillis();
			Object ret= proceed();
			long fin=System.currentTimeMillis();
			
			// Tritement faire pour extraire le verbe
			String verbe="null";
			for (int i=0,len=attributes.length;i<len;i++)
			{
				if(str.indexOf(attributes[i])>=0)
				{
					verbe=attributes[i];
					break;
				}
			}
			outMethodHttpRequestParameters
					.append(new StringBuilder(outMethodHttpRequestParameters.getSdf()
							.format(Calendar.getInstance().getTime())).append(
							sep)
							.append(
									verbe)
							.append(sep).append(
									(fin-deb))
							.append("\n").toString());
			
		
		return ret;

	}
	 public static final String stringFromIS(InputStream paramInputStream, Charset paramCharset)
	    throws IOException
	  {
	    InputStreamReader localInputStreamReader = new InputStreamReader(paramInputStream, paramCharset);
	    StringWriter localStringWriter = new StringWriter(1024);
	    char[] arrayOfChar = new char[1024];
	    int i = 0;
	    while ((i = localInputStreamReader.read(arrayOfChar)) >= 0)
	      localStringWriter.write(arrayOfChar, 0, i);
	    return localStringWriter.toString();
	  }
}
