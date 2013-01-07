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

public class Circle extends TwoDShape {
    protected double r;
    public Circle(double x, double y, double r) {
        super(x, y);
        Main.addNumberCircle(1);
        //System.out.println("Circle Constructor V1.4");
        externalCircle();
        this.r = r;
    }
    public void showParameter(String str){};
    public void showParameter(String str,String str2){};
    public void externalCircle()
    {
    	System.out.println(" External public Call from Circle");
    	internalCircle();
    }
    
    public void internalCircle() {
		// TODO Auto-generated method stub
    	System.out.println(" Internal Private  Call from Circle");
	}
	public Circle(double x, double y) { this(  x,   y, 1.0); }
    public Circle(double r)           { this(0.0, 0.0,   r); }
    public Circle()                   { this(0.0, 0.0, 1.0); }
    public double perimeter() {
        return 2 * Math.PI * r;
    }
    
    public void envoieException() throws Exception
    {
    	System.out.println("envoieException method");
    	   	throw new MyException();
    }
    public double area()  {
    	try
    	{
    		Thread.sleep(0);
    	}
     catch (InterruptedException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
    	
        return Math.PI * r*r;
    }
    public String toString() {
        return ("Circle radius = " + String.valueOf(r) + super.toString());
    }
}

