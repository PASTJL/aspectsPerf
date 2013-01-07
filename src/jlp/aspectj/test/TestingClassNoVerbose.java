package jlp.aspectj.test;

import java.util.HashMap;

public class TestingClassNoVerbose implements Runnable {

	/**
	 * @param args
	 */

	private String name = "";
	public boolean running = true;
	private int limit = 1000000;

	Thread thread = new Thread(this);

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;

	}

	public TestingClassNoVerbose(String name, int limit) {
		this.name = name;
		this.limit = limit;
	}

	public TestingClassNoVerbose(String name) {
		this.name = name;
	}

	public TestingClassNoVerbose() {
		this("no_name");

	}

	public void myShortMethod() {
		// System.out.println(name +
		// ".myShortMethod : I will sleep for 100 ms");
		try {
			Thread.sleep(100);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public void myLongMethod() {
		// System.out.println(name + ".myLongMethod : I will sleep for 1s");
		try {

			Thread.sleep(1000);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	public void myStressingMethod(int limit) {
		HashMap<String, Integer> hm = new HashMap<String, Integer>();
		// System.out.println(name + ".myStressingMethod :  limit=" + limit);
		for (int i = 0; i < limit; i++) {
			hm.put(new Integer(i % 100).toString(), new Integer(i % 1000));
		}
		hm.clear();

	}

	public void run() {
		while (running) {

			myShortMethod();

			myStressingMethod(limit);
			myLongMethod();
		}
	}

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		TestingClassNoVerbose[] tabRunners = new TestingClassNoVerbose[Integer
				.parseInt(args[0])];
		for (int i = 0; i < tabRunners.length; i++) {
			tabRunners[i] = new TestingClassNoVerbose("thread_" + i,
					Integer.parseInt(args[1]));
			tabRunners[i].thread.start();

		}
	}

}
