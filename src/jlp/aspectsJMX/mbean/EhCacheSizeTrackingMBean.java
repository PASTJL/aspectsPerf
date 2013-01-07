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

public interface EhCacheSizeTrackingMBean {

	public void reinitialise();

	public long getNbElementInMemory();

	public void modNbElementInMemory(long nbElementInMemory);

	public void modSizeInByteInMemory(long sizeInByteInMemory);

	public long getNbElementInDisk();

	public void modNbElementInDisk(long nbElementInDisk);

	public boolean isBoolTraceLog();

	public void modMaxSizeInByteInMemory(long maxSizeInByteInMemory);

	public long getHitCount();

	public void modHitCount(long hitCount);

	public long getMaxNbElementInMemory();

	public void modComputeSizesInBytesEnabled(boolean computeSizesInBytesEnabled);

	public void modActivated(boolean activated);

	public void modMaxNbElementInMemory(long maxNbElementInMemory);

	public long getMaxSizeInByteInMemory();

	public long getSizeInByteInMemory();
	
	public  void modBoolTraceLog(boolean boolTraceLog) ;
}
