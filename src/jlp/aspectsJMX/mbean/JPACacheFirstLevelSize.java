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

public final class JPACacheFirstLevelSize implements JPACacheFirstLevelSizeMBean {

	private String name = "JPACacheFirstLevelSizeInOctets";
	private double newScale = 1;
	private int aspectJPACacheFirstLevelExamined = 0;
	private long aspectJPACacheFirstLevelFrequency = 1;
	private double aspectJPACacheFirstLevelSizeCurrent = 0;
	private double aspectJPACacheFirstLevelSizeMax = 0;
	private double aspectJPACacheFirstLevelSizeMoy = 0;
	private int aspectJPACacheFirstLevelTotal = 0;
	private int aspectNumberAttributes = 0;
	private double scale = 1;
	private boolean serializationActivated = true;

	public final String getName() {
		// TODO Auto-generated method stub
		return this.name;
	}

	public final void changeScale(double newScale) {
		this.newScale = newScale;

	}

	public final int getAspectJPACacheFirstLevelExamined() {

		// TODO Auto-generated method stub
		return aspectJPACacheFirstLevelExamined;
	}

	public final long getAspectJPACacheFirstLevelFrequency() {
		// TODO Auto-generated method stub
		return aspectJPACacheFirstLevelFrequency;
	}

	public final double getAspectJPACacheFirstLevelSizeCurrent() {
		// TODO Auto-generated method stub
		return aspectJPACacheFirstLevelSizeCurrent;
	}

	public final double getAspectJPACacheFirstLevelSizeMax() {
		// TODO Auto-generated method stub
		return aspectJPACacheFirstLevelSizeMax;
	}

	public final double getAspectJPACacheFirstLevelSizeMoy() {
		// TODO Auto-generated method stub
		return aspectJPACacheFirstLevelSizeMoy;
	}

	public final int getAspectJPACacheFirstLevelTotal() {
		// TODO Auto-generated method stub
		return aspectJPACacheFirstLevelTotal;
	}

	public final int getAspectNumberAttributes() {
		// TODO Auto-generated method stub
		return aspectNumberAttributes;
	}

	public final double getScale() {
		// TODO Auto-generated method stub
		return scale;
	}

	public final boolean isSerializationActivated() {
		// TODO Auto-generated method stub
		return serializationActivated;
	}

	public final void modSerializationActivated(boolean activated) {
		// TODO Auto-generated method stub
		this.serializationActivated = activated;
	}

	public final void modAspectJPACacheFirstLevelExamined(int sessExamined) {
		// TODO Auto-generated method stub
		this.aspectJPACacheFirstLevelExamined = sessExamined;
	}

	public final void modAspectJPACacheFirstLevelFrequency(long freq) {
		// TODO Auto-generated method stub
		this.aspectJPACacheFirstLevelFrequency = freq;
	}

	public final void modAspectJPACacheFirstLevelSizeCurrent(double sizeCurrent) {
		// TODO Auto-generated method stub
		this.aspectJPACacheFirstLevelSizeCurrent = sizeCurrent;
	}

	public final void modAspectJPACacheFirstLevelSizeMax(double sizeMax) {
		// TODO Auto-generated method stub
		this.aspectJPACacheFirstLevelSizeMax = sizeMax;
	}

	public final void modAspectJPACacheFirstLevelSizeMoy(double sizeMoy) {
		// TODO Auto-generated method stub
		this.aspectJPACacheFirstLevelSizeMoy = sizeMoy;
	}

	public final void modAspectJPACacheFirstLevelTotal(int sessTotal) {
		// TODO Auto-generated method stub
		this.aspectJPACacheFirstLevelTotal = sessTotal;
	}

	public final void modAspectNumberAttributes(int nbObjects) {
		// TODO Auto-generated method stub
		this.aspectNumberAttributes = nbObjects;
	}

	public final void reinitialise() {
		newScale = 1;
		aspectJPACacheFirstLevelExamined = 0;
		aspectJPACacheFirstLevelFrequency = 1;
		aspectJPACacheFirstLevelSizeCurrent = 0;
		aspectJPACacheFirstLevelSizeMax = 0;
		aspectJPACacheFirstLevelSizeMoy = 0;
		aspectJPACacheFirstLevelTotal = 0;
		aspectNumberAttributes = 0;
		scale = 1;
		serializationActivated = true;

	}

}
