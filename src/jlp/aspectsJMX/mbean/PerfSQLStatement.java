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

public final class PerfSQLStatement implements PerfSQLStatementMBean {

	private int aspectSQLCounterExec = 0;
	private double aspectSQLDurationTimeCurrent = 0;
	private double aspectSQLDurationTimeMax = 0;
	private double aspectSQLDurationTimeMini = 0;
	private double aspectSQLDurationTimeMoy = 0;
	private double aspectSQLTotalDuration = 0;
	private static String name = "PerfSQLStatementInMillis";

	public final int getAspectSQLCounterExec() {
		// TODO Auto-generated method stub
		return aspectSQLCounterExec;
	}

	public final double getAspectSQLDurationTimeCurrent() {
		// TODO Auto-generated method stub
		return aspectSQLDurationTimeCurrent;
	}

	public final double getAspectSQLDurationTimeMax() {
		// TODO Auto-generated method stub
		return aspectSQLDurationTimeMax;
	}

	public final double getAspectSQLDurationTimeMini() {
		// TODO Auto-generated method stub
		return aspectSQLDurationTimeMini;
	}

	public final double getAspectSQLDurationTimeMoy() {
		// TODO Auto-generated method stub
		return aspectSQLDurationTimeMoy;
	}

	public final String getName() {
		// TODO Auto-generated method stub
		return name;
	}

	public final void modAspectSQLCounterExec(int count) {
		this.aspectSQLCounterExec = count;

	}

	public final void modAspectSQLDurationTimeCurrent(double durationCurrent) {
		// TODO Auto-generated method stub
		this.aspectSQLDurationTimeCurrent = durationCurrent;
	}

	public final void modAspectSQLDurationTimeMax(double durationTimeMax) {
		// TODO Auto-generated method stub
		this.aspectSQLDurationTimeMax = durationTimeMax;
	}

	public final void modAspectSQLDurationTimeMini(double durationMini) {
		// TODO Auto-generated method stub
		this.aspectSQLDurationTimeMini = durationMini;
	}

	public final void modAspectSQLDurationTimeMoy(double durationTimeMoy) {
		// TODO Auto-generated method stub
		this.aspectSQLDurationTimeMoy = durationTimeMoy;

	}

	public final void reinitialise() {
		// TODO Auto-generated method stub
		aspectSQLCounterExec = 0;
		aspectSQLDurationTimeCurrent = 0;
		aspectSQLDurationTimeMax = 0;
		aspectSQLDurationTimeMini = 0;
		aspectSQLDurationTimeMoy = 0;
		aspectSQLTotalDuration = 0;

	}

	public final double getAspectSQLTotalDuration() {
		// TODO Auto-generated method stub
		return aspectSQLTotalDuration;
	}

	public final void modAspectSQLTotalDuration(double total) {
		aspectSQLTotalDuration = total;

	}

}
