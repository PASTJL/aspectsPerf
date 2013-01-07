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
package jlp.aspectj.test;

public class MyBean2 {
	private String bean2Param1 = "bean2Param1";
	private int bean2int1 = 1;

	public String getBean2Param1() {
		return bean2Param1;
	}

	public void setBean2Param1(String bean2Param1) {
		this.bean2Param1 = bean2Param1;
	}

	public int getBean2int1() {
		return bean2int1;
	}

	public void setBean2int1(int bean2int1) {
		this.bean2int1 = bean2int1;
	}
}
