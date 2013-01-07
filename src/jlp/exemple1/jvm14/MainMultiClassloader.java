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

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLClassLoader;

import java.text.SimpleDateFormat;
import java.util.Calendar;

public class MainMultiClassloader implements Runnable{
	public static long pause=1000;
	private SimpleDateFormat sdf = new SimpleDateFormat(
	"yyyy/MM/dd HH:mm:ss.SSS");
	static Thread[] myTabThreads=new Thread[20];
	public static int numberCircle=0;
	public static int numberSquare=0;
	 
	public static synchronized void addNumberCircle ( int add)
	{
		numberCircle = numberCircle + add;
	}
	public static synchronized void addNumberSquare( int add)
	{
		numberSquare = numberSquare + add;
	}
	public static void main(String[] args) {
		if ( args.length==1)
		{
			pause=Long.parseLong(args[0]);
		}
		MainMultiClassloader myMain=new MainMultiClassloader();
		for ( int i=0;i<20;i++)
		{
			myTabThreads[i]=new Thread(myMain);
			myTabThreads[i].start();
		}
		try {
			Thread.sleep(10000);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		//System.exit(0);
		
	}

	public void run() {
		// TODO Auto-generated method stub
		String[] tab = { "tutu", "rtata" };
		Circle[] tabCirc= new Circle[300];
		int j = 0;
		URLClassLoader[] tabClassloader = new URLClassLoader[300];
		//OtherClassLoader[] tabClassloader = new OtherClassLoader[300];
		//MyClassLoader[] tabClassloader = new MyClassLoader[300];
		while (true && j < 10000) {
			for (int i = 0; i < 300; i++) {
				
				//tabClassloader[i]=new MyClassLoader();
				try {
						tabClassloader[i]=new URLClassLoader(new URL[]{ new URL("file","localhost",System.getProperty("root"))});
						
					} catch (MalformedURLException e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
					}
					// A continuer JLP
					Circle cir2=null;
					try {
						Class<jlp.exemple1.jvm14.Circle> clCircle=(Class<jlp.exemple1.jvm14.Circle>) tabClassloader[i].loadClass("jlp.exemple1.jvm14.Circle");
						Constructor<jlp.exemple1.jvm14.Circle> constructor=clCircle.getConstructor(new Class[]{double.class,double.class} );
						Constructor<jlp.exemple1.jvm14.Circle> constructor2=clCircle.getConstructor(new Class[]{double.class});
						tabCirc[i]=(jlp.exemple1.jvm14.Circle)constructor.newInstance(new Object[]{3,4});
						cir2= constructor2.newInstance(new Object[]{3});
						} catch (ClassNotFoundException e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
					}
				//	tabCirc[i/2] = new Circle(3, 4);
						catch (SecurityException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						} catch (NoSuchMethodException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						} catch (IllegalArgumentException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						} catch (InstantiationException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						} catch (IllegalAccessException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						} catch (InvocationTargetException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
					 
					 tabCirc[i].perimeter();
					 tabCirc[i].area();
					/* try {
						
						cir2.envoieException();
					} catch (Exception e) {
						// TODO Auto-generated catch block
						 System.out.println("Circle : envoie exception");
						e.printStackTrace();
					}
					*/
				//this.addNumberCircle(-1);
				// On déréférence les objets et les classloader
				//tabCirc[i] =null;
				//cir2=null;
				//tabClassloader[i]=null;
				
					
			}
			for ( int k=1;k<tabClassloader.length;k++)
			{
				tabClassloader[k]=null;
			}
			
			try {
				
				
				Thread.sleep(pause);
				System.out.println("range = "+j+" / 10000");
				j++;
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		}
		
	}
}
