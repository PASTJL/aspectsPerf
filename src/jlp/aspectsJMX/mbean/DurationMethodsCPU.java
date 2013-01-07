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

public final class DurationMethodsCPU implements DurationMethodsCPUMBean {

	private double aspectDurationCPUSysUserMax = 0;
	private double aspectDurationCPUSysUserMoy = 0;
	private double aspectDurationTimeMax = 0;
	private double aspectDurationTimeMoy = 0;
	private double aspectDurationCPUUserMoy = 0;
	private double aspectDurationCPUUserMax = 0;
	private double aspectDurationTimeCurrent = 0;
	private double aspectDurationCPUSysUserCurrent = 0;
	private double aspectDurationCPUUserCurrent = 0;
	private int aspectCounterExec = 0;
	private double aspectDurationTimeMini = 0;

	private static final String name = "DurationMethodsTimeCPUInMillisSeconds";

	public final void modAspectCounterExec(int count) {
		this.aspectCounterExec = count;
	}

	public final int getAspectCounterExec() {
		return aspectCounterExec;
	}

	public final double getAspectDurationCPUSysUserMax() {
		// TODO Auto-generated method stub
		return aspectDurationCPUSysUserMax;
	}

	public final double getAspectDurationCPUSysUserMoy() {
		// TODO Auto-generated method stub
		return this.aspectDurationCPUSysUserMoy;
	}

	public final double getAspectDurationTimeMax() {

		// TODO Auto-generated method stub
		return aspectDurationTimeMax;
	}

	public final double getAspectDurationTimeMini() {
		// TODO Auto-generated method stub
		return aspectDurationTimeMini;
	}

	public final double getAspectDurationTimeMoy() {
		// TODO Auto-generated method stub
		return aspectDurationTimeMoy;
	}

	public final String getName() {
		// TODO Auto-generated method stub
		return this.name;
	}

	public final void modAspectDurationCPUSysUserMoy(double durationCPUMoy) {
		this.aspectDurationCPUSysUserMoy = durationCPUMoy;

	}

	public final void modAspectDurationCPUSysUserMax(double durationCPUMax) {
		// TODO Auto-generated method stub
		this.aspectDurationCPUSysUserMax = durationCPUMax;
	}

	public final void modAspectDurationTimeMax(double durationTimeMax) {
		// TODO Auto-generated method stub
		this.aspectDurationTimeMax = durationTimeMax;
	}

	public final void modAspectDurationTimeMini(double limitTimeMini) {
		// TODO Auto-generated method stub
		this.aspectDurationTimeMini = limitTimeMini;
	}

	public final void modAspectDurationTimeMoy(double durationTimeMoy) {
		// TODO Auto-generated method stub
		this.aspectDurationTimeMoy = durationTimeMoy;
	}

	public final void modAspectDurationCPUUserMoy(double durationCPUUserMoy) {
		this.aspectDurationCPUUserMoy = durationCPUUserMoy;
	}

	public final double getAspectDurationCPUUserMoy() {
		return aspectDurationCPUUserMoy;

	}

	public final void modAspectDurationCPUUserMax(double durationCPUUserMax) {
		this.aspectDurationCPUUserMax = durationCPUUserMax;
	}

	public final double getAspectDurationCPUUserMax() {
		return aspectDurationCPUUserMax;
	}

	public final double getAspectDurationTimeCurrent() {
		return aspectDurationTimeCurrent;
	}

	public final void modAspectDurationTimeCurrent(double durationCurrent) {
		this.aspectDurationTimeCurrent = durationCurrent;
	}

	public final double getAspectDurationCPUSysUserCurrent() {
		return aspectDurationCPUSysUserCurrent;
	}

	public final void modAspectDurationCPUSysUserCurrent(
			double durationCPUSysUserCurrent) {
		this.aspectDurationCPUSysUserCurrent = durationCPUSysUserCurrent;
	}

	public final double getAspectDurationCPUUserCurrent() {
		return aspectDurationCPUUserCurrent;
	}

	public final void modAspectDurationCPUUserCurrent(double durationCPUSysUserCurrent) {
		this.aspectDurationCPUUserCurrent = durationCPUSysUserCurrent;
	}

	public final void reinitialise() {
		aspectDurationCPUSysUserMax = 0;
		aspectDurationCPUSysUserMoy = 0;
		aspectDurationTimeMax = 0;
		aspectDurationTimeMini = 0;
		aspectDurationTimeMoy = 0;
		aspectDurationCPUUserMoy = 0;
		aspectDurationCPUUserMax = 0;
		aspectDurationTimeCurrent = 0;
		aspectDurationCPUSysUserCurrent = 0;
		aspectDurationCPUUserCurrent = 0;
		aspectCounterExec = 0;
	}

}
