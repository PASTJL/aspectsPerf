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

public interface CommonPoolApacheMBean {
	public String getName();

	public double getAspectCurrentBorrowed();

	public void modAspectCurrentBorrowed(double currentActive);

	public double getAspectBorrowedMax();

	public void modAspectBorrowedMax(double sizeMax);

	public void modAspectBorrowedFrequency(long freq);

	public long getAspectBorrowedFrequency();

	public int getAspectBorrowedExamined();

	public void modAspectBorrowedExamined(int sessExamined);

	public void modAspectCurrentPoolSize(int poolSize);

	public int getAspectCurrentPoolSize();

	public void modAspectCurrentIdle(int idle);

	public int getAspectCurrentIdle();

	public void modAspectTimeBetweenEvictionRunsMillis(
			long timeBetweenEvictionRunsMillis);

	public long getAspectTimeBetweenEvictionRunsMillis();

	public void modAspectBorrowedMoy(double borrowMoy);

	public double getAspectBorrowedMoy();

	public boolean isActivated();

	public void modActivated(boolean activated);

	public void reinitialise();

}
