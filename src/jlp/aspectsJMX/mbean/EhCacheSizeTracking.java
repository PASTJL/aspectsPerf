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

public class EhCacheSizeTracking implements EhCacheSizeTrackingMBean {

	
	public final  boolean isActivated() {
		return activated;
	}

	public final  void modActivated(boolean activated) {
		EhCacheSizeTracking.activated = activated;
	}

	public final  void reinitialise() {

		maxSizeInByteInMemory = -1;

		nbElementInMemory = 0;
		nbElementInDisk = 0;
		computeSizesInBytesEnabled = true;
		maxSizeInByteInMemory = -1;
		hitCount = 0;
		activated = true;
		boolTraceLog = true;

	}

	private long nbElementInMemory = 0;
	private long sizeInByteInMemory = -1;
	

	private long nbElementInDisk = 0;
	private long maxSizeInByteInMemory = -1;
	public long getMaxSizeInByteInMemory() {
		return maxSizeInByteInMemory;
	}

	private long maxNbElementInMemory=0;
	
	public long getMaxNbElementInMemory() {
		return maxNbElementInMemory;
	}

	

	private static boolean activated = true;
	private long hitCount = 0;
	private static boolean boolTraceLog = true;
	private static boolean computeSizesInBytesEnabled = true;
	
	public long getNbElementInMemory() {
		return nbElementInMemory;
	}

	public void modNbElementInMemory(long nbElementInMemory) {
		this.nbElementInMemory = nbElementInMemory;
	}

	public long getSizeInByteInMemory() {
		return sizeInByteInMemory;
	}

	public void modSizeInByteInMemory(long sizeInByteInMemory) {
		this.sizeInByteInMemory = sizeInByteInMemory;
	}

	public  long getNbElementInDisk() {
		return nbElementInDisk;
	}

	public  void modNbElementInDisk(long nbElementInDisk) {
		this.nbElementInDisk = nbElementInDisk;
	}

	

	public void modMaxSizeInByteInMemory(long maxSizeInByteInMemory) {
		this.maxSizeInByteInMemory = maxSizeInByteInMemory;
	}

	public  long getHitCount() {
		return hitCount;
	}

	public void modHitCount(long hitCount) {
		this.hitCount = hitCount;
	}

	public boolean isBoolTraceLog() {
		return EhCacheSizeTracking.boolTraceLog;
	}

		
	public  void modBoolTraceLog(boolean boolTraceLog) {
		EhCacheSizeTracking.boolTraceLog = boolTraceLog;
	}

	public  boolean isComputeSizesInBytesEnabled() {
		return computeSizesInBytesEnabled;
	}

	public void modComputeSizesInBytesEnabled(
			boolean computeSizesInBytesEnabled) {
		EhCacheSizeTracking.computeSizesInBytesEnabled = computeSizesInBytesEnabled;
	}

	
	public void modMaxNbElementInMemory(long maxNbElementInMemory) {
		this.maxNbElementInMemory=maxNbElementInMemory;
		
	}

	
	

	

}
