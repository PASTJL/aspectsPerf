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
package jlp.exemple1.jvm14;

import java.io.*;

public class MyClassLoader extends ClassLoader {
	// Given a filename, read the entirety of that file from disk
	// and return it as a byte array.
	static String root;
	static
	{
	root=System.getProperty("root");
	}
	private byte[] getBytes(String filename) throws IOException {
		// Find out the length of the file
		System.out.println("filename avant = "+filename);
		filename=filename.replaceAll("\\.","\\\\");
		System.out.println("filename apres = "+filename);
		File file = new File(root+File.separator+filename+".class");
		long len = file.length();
		// Create an array that's just the right size for the file's
		// contents
		byte raw[] = new byte[(int) len];
		// Open the file
		FileInputStream fin = new FileInputStream(file);
		// Read all of it into the array; if we don't get all,
		// then it's an error.
		int r = fin.read(raw);
		if (r != len)
			throw new IOException("Can't read all, " + r + " != " + len);
		// Don't forget to close the file!
		fin.close();
		// And finally return the file contents as an array
		return raw;
	}

	// Spawn a process to compile the java source code file
	// specified in the 'javaFile' parameter. Return a true if
	// the compilation worked, false otherwise.
	 public Class findClass(String name) throws ClassNotFoundException {
		 System.out.println("MyClassLoader chargement de :"+ name);
         byte[] b = loadClassData(name);
         return defineClass(name, b, 0, b.length);
     }
     private byte[] loadClassData(String name) {
         // load the class data from the connection
    	 byte[] tabByte=null;
    	 try {
			return getBytes(name);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
     }

}
