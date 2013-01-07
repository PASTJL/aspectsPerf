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
package jlp.aspectj.test;

import java.util.concurrent.atomic.AtomicInteger;

public class MyBean {
	private String string1 = "";
	private String name = "init_name";

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	private AtomicInteger atomicInteger = new AtomicInteger(45);
	private int intPrimitive = 0;
	private Integer intWrapped = 0;
	private long longPrimitive = 0;
	private Long longWrapped = 0L;
	private double doublePrimitive = 0.0;
	private Double doubleWrapped = 0.0d;
	private float floatPrimitive = 0f;
	private Float floatWrapped = 0f;
	private MyBean2 myBean2 = null;

	public MyBean(String name) {
		myBean2 = new MyBean2();
		myBean2.setBean2int1(4);
		string1 = name;
		this.name = name;
	}

	public int getBean2int1() {
		return myBean2.getBean2int1();
	}

	public void doSomeStuff() {
		System.out.println("I do some Stuff");
		this.incr();
	}

	private void incr() {
		intPrimitive += 1;
		intWrapped += 1;
		longPrimitive += 1;
		longWrapped += 1;
		doublePrimitive += 1;
		doubleWrapped += 1;
		floatPrimitive += 1;
		floatWrapped += 1;
		atomicInteger.getAndAdd(10);
		myBean2.setBean2int1(myBean2.getBean2int1() + 1);
	}

	public String getString1() {
		return string1;
	}

	public void setString1(String string1) {
		this.string1 = string1;
	}

	public int getIntPrimitive() {
		return intPrimitive;
	}

	public void setIntPrimitive(int intPrimitive) {
		this.intPrimitive = intPrimitive;
	}

	public Integer getIntWrapped() {
		return intWrapped;
	}

	public void setIntWrapped(Integer intWrapped) {
		this.intWrapped = intWrapped;
	}

	public long getLongPrimitive() {
		return longPrimitive;
	}

	public void setLongPrimitive(long longPrimitive) {
		this.longPrimitive = longPrimitive;
	}

	public Long getLongWrapped() {
		return longWrapped;
	}

	public void setLongWrapped(Long longWrapped) {
		this.longWrapped = longWrapped;
	}

	public double getDoublePrimitive() {
		return doublePrimitive;
	}

	public void setDoublePrimitive(double doublePrimitive) {
		this.doublePrimitive = doublePrimitive;
	}

	public Double getDoubleWrapped() {
		return doubleWrapped;
	}

	public void setDoubleWrapped(Double doubleWrapped) {
		this.doubleWrapped = doubleWrapped;
	}

	public float getFloatPrimitive() {
		return floatPrimitive;
	}

	public void setFloatPrimitive(float floatPrimitive) {
		this.floatPrimitive = floatPrimitive;
	}

	public Float getFloatWrapped() {
		return floatWrapped;
	}

	public void setFloatWrapped(Float floatWrapped) {
		this.floatWrapped = floatWrapped;
	}

	public MyBean2 getMyBean2() {
		return myBean2;
	}

	public void setMyBean2(MyBean2 myBean2) {
		this.myBean2 = myBean2;
	}

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub

	}

}
