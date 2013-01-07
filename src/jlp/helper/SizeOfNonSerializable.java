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
package jlp.helper;

import java.lang.reflect.Array;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Modifier;
import java.util.Collection;
import java.util.Map;
import java.util.Set;

public class SizeOfNonSerializable {

	static final int SZ_REF = 4;

	public static int sizeof(boolean b) {
		return 1;
	}

	public static int sizeof(byte b) {
		return 1;
	}

	public static int sizeof(char c) {
		return 2;
	}

	public static int sizeof(short s) {
		return 2;
	}

	public static int sizeof(int i) {
		return 4;
	}

	public static int sizeof(long l) {
		return 8;
	}

	public static int sizeof(float f) {
		return 4;
	}

	public static int sizeof(double d) {
		return 8;
	}

	@SuppressWarnings("unchecked")
	private static int retainedSize_inst(Object obj, Class c) {

		// System.out.println("traiteme 0 de :"
		// + obj.getClass().getCanonicalName());

		if (obj instanceof CharSequence) {
			// System.out.println("traiteme 1 de :"
			// + obj.getClass().getCanonicalName());
			return ((CharSequence) obj).length() * 2;
		}

		if (obj instanceof Map) {
			// System.out.println("traiteme 3 de :"
			// + obj.getClass().getCanonicalName());
			// System.out.println("traitement MAP");
			int len = 0;
			try {
				len = (Integer) obj.getClass()
						.getMethod("size", (Class[]) null)
						.invoke(obj, (Object[]) null);

				int accu = 0;
				Set obj1 = (Set) obj.getClass()
						.getMethod("keySet", (Class[]) null)
						.invoke(obj, (Object[]) null);
				// System.out.println("set.size=" + obj1.size());
				Collection obj2 = (Collection) obj.getClass()
						.getMethod("values", (Class[]) null)
						.invoke(obj, (Object[]) null);
				// System.out.println("val.size=" + obj2.size());
				accu += retainedSize_arr(obj1.toArray(), obj1.toArray()
						.getClass());
				accu += retainedSize_arr(obj2.toArray(), obj2.toArray()
						.getClass());
				return accu;
			} catch (IllegalArgumentException e) {

			} catch (SecurityException e) {

			} catch (IllegalAccessException e) {

			} catch (InvocationTargetException e) {

			} catch (NoSuchMethodException e) {

			}
		}
		c = obj.getClass();
		// System.out.println("traiteme 4  de :"
		// + obj.getClass().getCanonicalName());
		Field flds[] = c.getDeclaredFields();
		// System.out.println("analyse Fields coucou 0 flds.length" +
		// flds.length);
		int sz = 0;

		for (int i = 0; i < flds.length; i++) {
			Field f = flds[i];
			// System.out.println("analyse Field len=" + flds.length);
			// System.out.println("analyse Field Type= "
			// + f.getType().getCanonicalName());
			if ((f.getModifiers() & Field.DECLARED) != 0) {
				try {

					sz += retainedSizeOf(f.get(obj));
				} catch (IllegalArgumentException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (IllegalAccessException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}

		}

		// if (c.getSuperclass() != null)
		// sz += retainedSize_inst(obj, c.getSuperclass());

		// Class cv[] = c.getInterfaces();
		// for (int i = 0; i < cv.length; i++)
		// sz += retainedSize_inst(obj, cv[i]);

		return sz;
	}

	private static int size_inst(Class c) {

		Field flds[] = c.getDeclaredFields();

		int sz = 0;

		for (int i = 0; i < flds.length; i++) {
			Field f = flds[i];
			if (!c.isInterface() && (f.getModifiers() & Modifier.STATIC) != 0)
				continue;
			sz += size_prim(f.getType());
		}

		if (c.getSuperclass() != null)
			sz += size_inst(c.getSuperclass());

		Class cv[] = c.getInterfaces();
		for (int i = 0; i < cv.length; i++)
			sz += size_inst(cv[i]);

		return sz;
	}

	private static int size_prim(Class t) {

		if (t == Boolean.TYPE)
			return 1;
		else if (t == Byte.TYPE)
			return 1;
		else if (t == Character.TYPE)
			return 2;
		else if (t == Short.TYPE)
			return 2;
		else if (t == Integer.TYPE)
			return 4;
		else if (t == Long.TYPE)
			return 8;
		else if (t == Float.TYPE)
			return 4;
		else if (t == Double.TYPE)
			return 8;
		else if (t == Void.TYPE)
			return 0;
		else
			return SZ_REF;
	}

	private static int size_arr(Object obj, Class c) {
		Class ct = c.getComponentType();
		int len = Array.getLength(obj);

		if (ct.isPrimitive()) {
			// System.out.println("Comme primitive " + ct.getCanonicalName());
			return len * size_prim(ct);
		} else {
			// System.out.println("Comme non primitive " +
			// ct.getCanonicalName());
			int sz = 0;
			for (int i = 0; i < len; i++) {
				sz += SZ_REF;
				Object obj2 = Array.get(obj, i);
				if (obj2 == null)
					continue;
				Class c2 = obj2.getClass();
				if (!c2.isArray())
					continue;
				sz += size_arr(obj2, c2);
			}
			return sz;
		}
	}

	private static int retainedSize_arr(Object obj, Class c) {
		Class ct = c.getComponentType();
		int len = Array.getLength(obj);

		if (ct.isPrimitive()) {
			// System.out.println("Comme primitive " + ct.getCanonicalName());
			return len * size_prim(ct);
		} else {
			// System.out.println("Comme non primitive " +
			// ct.getCanonicalName());
			int sz = 0;
			for (int i = 0; i < len; i++) {
				sz += SZ_REF;
				Object obj2 = Array.get(obj, i);
				if (obj2 == null)
					continue;
				Class c2 = obj2.getClass();
				if (!c2.isArray()) {
					sz += retainedSizeOf(obj2);
				}

			}
			return sz;
		}
	}

	public static int sizeof(Object obj) {
		if (obj == null)
			return 0;

		Class c = obj.getClass();
		// System.out.println("Class.name=" + c.getCanonicalName());

		if (c.isArray()) {
			// System.out.println("Class.name=" + c.getCanonicalName()
			// + " traite comme un tableau");
			return size_arr(obj, c);
		} else {
			// System.out.println("Class.name=" + c.getCanonicalName()
			// + " traite comme une instance");
			return size_inst(c);
		}
	}

	public static int retainedSizeOf(Object obj) {
		if (obj == null)
			return 0;

		// System.out.println("retainedSizeOf Class.name="
		// + obj.getClass().getCanonicalName());
		Object obj2 = null;
		if (obj instanceof java.util.List) {
			try {
				// System.out.println("Passage dans List");
				obj2 = obj.getClass().getMethod("toArray", (Class[]) null)
						.invoke(obj, (Object[]) null);
				obj = obj2;
				// System.out.println("obj2 Class ="
				// + obj2.getClass().getCanonicalName());
				// if (null == obj2) {
				// System.out.println("Aie obj2 is null");
				// }
				// if (null == obj) {
				// System.out.println("Aie obj is null");
				// }
			} catch (IllegalArgumentException e) {
				System.out
						.println("IllegalArgumentException " + e.getMessage());

			} catch (SecurityException e) {
				System.out.println("SecurityException " + e.getMessage());
			} catch (IllegalAccessException e) {
				System.out.println("IllegalAccessException " + e.getMessage());

			} catch (InvocationTargetException e) {
				System.out.println("InvocationTargetException "
						+ e.getMessage());

			} catch (NoSuchMethodException e) {
				System.out.println("NoSuchMethodException " + e.getMessage());

			}

		}

		Class c = obj.getClass();
		if (c.isArray()) {
			// System.out.println("Class.name=" + c.getCanonicalName()
			// + " traite comme un tableau");
			return retainedSize_arr(obj, c);
		} else {
			// System.out.println("Class.name=" + c.getCanonicalName()
			// + " traite comme une instance");
			return retainedSize_inst(obj, c);
		}
	}

	static void err(String s) {
		System.err.println("*** " + s + " ***");
	}

}
