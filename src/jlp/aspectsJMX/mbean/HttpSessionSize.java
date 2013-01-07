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

public final class HttpSessionSize implements HttpSessionSizeMBean {

	public final String getName() {
		// TODO Auto-generated method stub
		return this.name;
	}

	public final double getAspectHttpSessSizeMax() {

		return aspectHttpSessSizeMax;
	}

	public final void modAspectHttpSessSizeMax(double sizeMax) {
		// TODO Auto-generated method stub
		this.aspectHttpSessSizeMax = sizeMax;
	}

	public final double getAspectHttpSessSizeMoy() {

		return aspectHttpSessSizeMoy;
	}

	public final void modAspectHttpSessSizeMoy(double sizeMoy) {
		// TODO Auto-generated method stub
		this.aspectHttpSessSizeMoy = sizeMoy;
	}

	public final long getAspectHttpSessFrequency() {
		return aspectHttpSessFrequency;
	}

	public final void modAspectHttpSessFrequency(long frequency) {
		this.aspectHttpSessFrequency = frequency;
	}

	public final int getAspectHttpSessExamined() {
		return aspectHttpSessExamined;
	}

	public final void modAspectHttpSessExamined(int sessExamined) {
		this.aspectHttpSessExamined = sessExamined;
	}

	public final int getAspectHttpSessTotal() {
		return aspectHttpSessTotal;
	}

	public final void modAspectHttpSessTotal(int sessTotal) {
		this.aspectHttpSessTotal = sessTotal;
	}

	public final double getAspectHttpSessSizeCurrent() {
		return aspectHttpSessSizeCurrent;
	}

	public final void modAspectHttpSessSizeCurrent(double httpSessSizeCurrent) {
		this.aspectHttpSessSizeCurrent = httpSessSizeCurrent;
	}

	public final boolean isSerializationActivated() {
		return serialization;
	}

	public final void modSerializationActivated(boolean activated) {
		this.serialization = activated;
	}

	public final double getScale() {
		return scale;
	}

	public final void changeScale(double newScale) {
		this.scale = newScale;
		switch ((int) newScale) {
		case 1:
			this.name = "HttpSessionSizeInOctets";
			break;
		case 1000:
			this.name = "HttpSessionSizeInKiloOctets";
			break;
		case 100000:
			this.name = "HttpSessionSizeInMegaOctets";
			break;
		default:
			this.name = "HttpSessionSizeUnknownUnit";
			break;
		}

	}

	public final void reinitialise() {

		aspectHttpSessExamined = 0;
		aspectHttpSessTotal = 0;
		aspectHttpSessSizeMoy = 0;
		aspectHttpSessSizeMax = 0;
		name = "AspectsConcrete:type=httpSessionSizeInOctets";
		aspectHttpSessFrequency = 1;
		aspectHttpSessSizeCurrent = 0;
		serialization = true;
		scale = 1;
		aspectNumberAttributes = 0;
	}

	public final void modAspectNumberAttributes(int nbObjects) {
		this.aspectNumberAttributes = nbObjects;
		;
	}

	public final int getAspectNumberAttributes() {
		return this.aspectNumberAttributes;
	}

	private int aspectHttpSessExamined = 0;
	private int aspectHttpSessTotal = 0;
	private double aspectHttpSessSizeMoy = 0;
	private double aspectHttpSessSizeMax = 0;
	private String name = "AspectsConcrete:type=httpSessionSizeInOctets";
	private long aspectHttpSessFrequency = 1;
	private double aspectHttpSessSizeCurrent = 0;
	private boolean serialization = true;
	private double scale = 1;
	private int aspectNumberAttributes = 0;

}
