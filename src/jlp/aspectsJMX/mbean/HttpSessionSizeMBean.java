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

public interface HttpSessionSizeMBean {
	public String getName();

	public double getAspectHttpSessSizeMoy();

	public void modAspectHttpSessSizeMoy(double sizeMoy);

	public double getAspectHttpSessSizeMax();

	public void modAspectHttpSessSizeMax(double sizeMax);

	public void modAspectHttpSessFrequency(long freq);

	public long getAspectHttpSessFrequency();

	public int getAspectHttpSessExamined();

	public void modAspectHttpSessExamined(int sessExamined);

	public int getAspectHttpSessTotal();

	public void modAspectHttpSessTotal(int sessTotal);

	public void modAspectHttpSessSizeCurrent(double sizeCurrent);

	public double getAspectHttpSessSizeCurrent();

	public boolean isSerializationActivated();

	public void modSerializationActivated(boolean activated);

	public double getScale();

	public void changeScale(double newScale);

	public void reinitialise();

	public void modAspectNumberAttributes(int nbObjects);

	public int getAspectNumberAttributes();

}
