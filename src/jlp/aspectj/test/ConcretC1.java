package jlp.aspectj.test;

public class ConcretC1 extends AbstractC1 {

	static int count=0;

	public int getUsed2() {
		return count++;
		
	}

	
	public void unused() {
		// DoNothing
		
	}

}
