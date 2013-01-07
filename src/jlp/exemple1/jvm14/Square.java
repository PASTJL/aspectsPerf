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

public class Square extends TwoDShape {
    protected double s;    // side
    public Square(double x, double y, double s) {
        super(x, y);
        //System.out.println("Square Constructor V1.4");
       Main.addNumberSquare(1);
        this.s = s;
    }
    public Square(double x, double y) { this(  x,   y, 1.0); }
    public Square(double s)           { this(0.0, 0.0,   s);
  //  System.out.println("Creation Cercle dans square");
    	new Circle(4);
    	 Main.addNumberCircle(-1);
    	 }
    public Square()                   { this(0.0, 0.0, 1.0); }
    public double perimeter() {
        return 4 * s;
    }
    public double area(int k, String toto, Double dd, String[] tab) {
    //	System.out.println("calcul area du Square : sleep de 545 ms");
    	try {
			Thread.sleep(545);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return s*s;
    }
    public String toString() {
        return ("Square side = " + String.valueOf(s) + super.toString());
    }
	
	public double area() {
		//System.out.println("calcul area du Square : sleep de 30 ms");
    	try {
			Thread.sleep(30);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		// TODO Auto-generated method stub
		return s*s;
	}
}

