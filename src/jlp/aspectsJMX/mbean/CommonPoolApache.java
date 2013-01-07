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
package jlp.aspectsJMX.mbean;

public class CommonPoolApache implements CommonPoolApacheMBean {

	public final String getName() {
		// TODO Auto-generated method stub
		return this.name;
	}

	public final  boolean isActivated() {
		return activated;
	}

	public final  void modActivated(boolean activated) {
		this.activated = activated;
	}

	public final  void reinitialise() {

		aspectBorrowedExamined = 0;

		aspectBorrowedMoy = 0;
		aspectBorrowedMax = 0;
		name = "CommonPoolorrowedObject";
		aspectBorrowedFrequency = 1;
		aspectCurrentBorrowed = 0;
		activated = true;

	}

	private int aspectBorrowedExamined = 0;

	private double aspectBorrowedMoy = 0;
	private double aspectBorrowedMax = 0;
	private String name = "AspectsConcrete:type=concreteCommonPoolApache";
	private long aspectBorrowedFrequency = 1;
	private double aspectCurrentBorrowed = 0;
	private boolean activated = true;
	private int aspectCurrentPoolSize = 0;
	private int aspectCurrentIdle = 0;
	private long aspectTimeBetweenEvictionRunsMillis = 0;

	public final  int getAspectBorrowedExamined() {

		return aspectBorrowedExamined;
	}

	public  final long getAspectBorrowedFrequency() {

		return aspectBorrowedFrequency;
	}

	public final  double getAspectBorrowedMax() {

		return aspectBorrowedMax;
	}

	public final  double getAspectBorrowedMoy() {

		return aspectBorrowedMoy;
	}

	public final  double getAspectCurrentBorrowed() {

		return aspectCurrentBorrowed;
	}

	public final  void modAspectBorrowedExamined(int examined) {

		this.aspectBorrowedExamined = examined;
	}

	public final  void modAspectBorrowedFrequency(long freq) {
		this.aspectBorrowedFrequency = freq;

	}

	public  final void modAspectBorrowedMax(double borrowedMax) {

		this.aspectBorrowedMax = borrowedMax;
	}

	public final  void modAspectBorrowedMoy(double borrowMoy) {
		this.aspectBorrowedMoy = borrowMoy;

	}

	public final  void modAspectCurrentBorrowed(double currentActive) {
		this.aspectCurrentBorrowed = currentActive;

	}

	public final  int getAspectCurrentIdle() {
		return aspectCurrentIdle;

	}

	public final  int getAspectCurrentPoolSize() {

		return aspectCurrentPoolSize;
	}

	public final  long getAspectTimeBetweenEvictionRunsMillis() {
		return aspectTimeBetweenEvictionRunsMillis;

	}

	public final  void modAspectCurrentIdle(int idle) {
		this.aspectCurrentIdle = idle;

	}

	public  final void modAspectCurrentPoolSize(int poolSize) {
		this.aspectCurrentPoolSize = poolSize;

	}

	public final  void modAspectTimeBetweenEvictionRunsMillis(
			long timeBetweenEvictionRunsMillis) {
		this.aspectTimeBetweenEvictionRunsMillis = timeBetweenEvictionRunsMillis;

	}

}
