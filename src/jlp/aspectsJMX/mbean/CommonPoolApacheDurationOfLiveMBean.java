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

public interface CommonPoolApacheDurationOfLiveMBean {
	public String getName();

	public long getAspectCurrentDuration();

	public void modAspectCurrentDuration(long currentDuration);

	public void modAspectBorrowedFrequency(long freq);

	public long getAspectBorrowedFrequency();

	public int getAspectExamined();

	public void modAspectExamined(int examined);

	public void modAspectDurationMoy(double borrowMoy);

	public double getAspectDurationMoy();

	public boolean isSizeSerializationActivated();

	public void modSizeSerializationActivated(boolean activated);

	public void reinitialise();

	public void modAspectDurationMax(long durationMax);

	public long getAspectDurationMax();

	public double getAspectSizeObject();

	public void modAspectSizeObject(double newSize);

	public double getAspectSizeMax();

	public void modAspectSizeMax(double sizeMax);

}
