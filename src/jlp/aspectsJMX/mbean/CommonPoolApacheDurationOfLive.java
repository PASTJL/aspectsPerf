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

public final class CommonPoolApacheDurationOfLive implements
		CommonPoolApacheDurationOfLiveMBean {

	public final String getName() {
		// TODO Auto-generated method stub
		return this.name;
	}

	public final boolean isSizeSerializationActivated() {
		return activated;
	}

	public final void modSizeSerializationActivated(boolean activated) {
		this.activated = activated;
	}

	public final void reinitialise() {

		activated = true;
		name = "AspectsConcrete:type=concreteCommonPoolApacheDurationOfLive";
		aspectBorrowedFrequency = 1;
		aspectCurrentDuration = 0;
		aspectDurationMax = 0;
		aspectDurationMoy = 0.0;
		aspectExamined = 0;
		aspectSizeObject = -1;
		aspectSizeMax = -1;
	}

	private String name = "AspectsConcrete:type=concreteCommonPoolApacheDurationOfLive";
	private long aspectBorrowedFrequency = 1;

	private boolean activated = true;
	private long aspectCurrentDuration = 0;
	private long aspectDurationMax = 0;
	private double aspectDurationMoy = 0.0;
	private int aspectExamined = 0;
	private double aspectSizeObject = -1;;
	private double aspectSizeMax = -1;

	public final long getAspectBorrowedFrequency() {

		return aspectBorrowedFrequency;
	}

	public final void modAspectBorrowedFrequency(long freq) {
		this.aspectBorrowedFrequency = freq;

	}

	public final long getAspectCurrentDuration() {

		return aspectCurrentDuration;
	}

	public final long getAspectDurationMax() {

		return aspectDurationMax;
	}

	public final double getAspectDurationMoy() {

		return aspectDurationMoy;
	}

	public final int getAspectExamined() {

		return aspectExamined;
	}

	public final void modAspectCurrentDuration(long currentDuration) {
		this.aspectCurrentDuration = currentDuration;

	}

	public final void modAspectDurationMax(long durationMax) {
		this.aspectDurationMax = durationMax;

	}

	public final void modAspectDurationMoy(double borrowMoy) {
		this.aspectDurationMoy = borrowMoy;

	}

	public final void modAspectExamined(int examined) {
		this.aspectExamined = examined;

	}

	public final double getAspectSizeObject() {

		return aspectSizeObject;
	}

	public final void modAspectSizeObject(double newSize) {
		this.aspectSizeObject = newSize;

	}

	public final double getAspectSizeMax() {
		// TODO Auto-generated method stub
		return aspectSizeMax;
	}

	public final void modAspectSizeMax(double sizeMax) {
		this.aspectSizeMax = sizeMax;

	}
}
