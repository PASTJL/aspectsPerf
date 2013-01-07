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

import java.text.SimpleDateFormat;
import java.util.Calendar;

public class Main implements Runnable{
	public static long pause=1000;
	private SimpleDateFormat sdf = new SimpleDateFormat(
	"yyyy/MM/dd HH:mm:ss.SSS");
	static Thread[] myTabThreads=new Thread[20];
	public static int numberCircle=0;
	public static int numberSquare=0;
	public static synchronized void showParameters ( int add, String str1, String str2)
	{
		numberCircle = numberCircle + add;
	}
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
		if (args.length==2)
		{
			try {
				Thread.sleep(Long.parseLong(args[1]));
			} catch (NumberFormatException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		Main myMain=new Main();
		for ( int i=0;i<20;i++)
		{
			myTabThreads[i]=new Thread(myMain);
			myTabThreads[i].setName("ThreadJLP_"+i);
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
		Circle[] tabCirc= new Circle[10];
		int j = 0;
		
		while (true && j < 10000) {
			for (int i = 0; i < 20; i++) {
				if (i % 2 == 0) {
					if (null != tabCirc[i/2] ) 
					{
						this.addNumberCircle(-1);
					}
					tabCirc[i/2] = new Circle(3, 4);
					 
					 tabCirc[i/2].perimeter();
					 Circle cir2=new Circle(3);
					 try {
						cir2.externalCircle();
						cir2.showParameter("coucou0");
						cir2.showParameter("coucou0","coucou1");
						//cir2.envoieException();
						tabCirc[i/2]=null;
						cir2=null;
					} catch (Exception e) {
						// TODO Auto-generated catch block
						// System.out.println("Circle : envoie exception");
						e.printStackTrace();
					}
					showParameters(1,"toto1","toto2");
				this.addNumberCircle(-1);
				} else {
					Square sq = new Square(6);
					sq.area(8, "toto", new Double(45.6), tab);
					sq.area();
					this.addNumberSquare(-1);
				}
			}
			
			try {
				
				if (j%10==0)
				{
					for(int k=0;k<8;k++)
					{
						tabCirc[k]=null;
						
					}
					this.addNumberCircle(-8);
					System.out.println(sdf.format(
							Calendar.getInstance().getTime())+ "; circleAlive= "+Main.numberCircle+
							"; SquareAlive = "+Main.numberSquare);
				}
				Thread.sleep(pause);
				j++;
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		}
		
	}
}
