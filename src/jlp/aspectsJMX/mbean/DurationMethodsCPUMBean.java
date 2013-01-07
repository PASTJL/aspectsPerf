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

public interface DurationMethodsCPUMBean {
	public String getName();

	public double getAspectDurationTimeMoy();

	public void modAspectDurationTimeMoy(double durationTimeMoy);

	public double getAspectDurationTimeMax();

	public void modAspectDurationTimeMax(double durationTimeMax);

	public void modAspectDurationTimeMini(double durationMini);

	public double getAspectDurationTimeMini();

	public double getAspectDurationCPUSysUserMoy();

	public void modAspectDurationCPUSysUserMoy(double durationCPUMoy);

	public double getAspectDurationCPUSysUserMax();

	public void modAspectDurationCPUSysUserMax(double durationCPUMax);

	public void modAspectDurationCPUUserMoy(double durationCPUUserMoy);

	public double getAspectDurationCPUUserMoy();

	public void modAspectDurationCPUUserMax(double durationCPUUserMax);

	public double getAspectDurationCPUUserMax();

	public double getAspectDurationTimeCurrent();

	public void modAspectDurationTimeCurrent(double durationCurrent);

	public double getAspectDurationCPUSysUserCurrent();

	public void modAspectDurationCPUSysUserCurrent(
			double durationCPUSysUserCurrent);

	public double getAspectDurationCPUUserCurrent();

	public void modAspectDurationCPUUserCurrent(double durationCPUSysUserCurrent);

	public void modAspectCounterExec(int count);

	public int getAspectCounterExec();

	public void reinitialise();

}
