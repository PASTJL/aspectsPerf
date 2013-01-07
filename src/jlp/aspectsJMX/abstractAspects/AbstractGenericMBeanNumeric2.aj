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
package jlp.aspectsJMX.abstractAspects;

import java.lang.management.ManagementFactory;
import java.lang.management.ThreadMXBean;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.IdentityHashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;


import javax.management.InstanceAlreadyExistsException;
import javax.management.MBeanRegistrationException;
import javax.management.MBeanServer;
import javax.management.MalformedObjectNameException;
import javax.management.NotCompliantMBeanException;
import javax.management.ObjectName;
import javax.management.openmbean.CompositeDataSupport;
import javax.management.openmbean.CompositeType;
import javax.management.openmbean.OpenDataException;
import javax.management.openmbean.SimpleType;

import java.util.Locale;
import java.util.concurrent.locks.ReentrantLock;
import java.util.regex.Pattern;
import jlp.helper.Tuple2;
import jlp.helper.Tuple2Method;

import jlp.aspectsJMX.mbean.GenericBean;
import jlp.perf.aspects.abstractAspects.Version;

public abstract aspect AbstractGenericMBeanNumeric2 {

// Version for Java 1.5+
	private static Map<Object,GenericBean> hmBean = Collections
			.synchronizedMap(new IdentityHashMap<Object,GenericBean>());
	
	public static ReentrantLock lock=new ReentrantLock();
	// The GenericBean contains a field currentAge wich is the date of the last
	// visit or the counter of the last visit
	public static int counter = 0;
	private static int frequenceMeasure = 1;
	private static boolean isTimeFreq = false;
	public static boolean isGetThis = true;
	private static Properties props;
	static ThreadMXBean tMB = null;
	static MBeanServer mbs = null;
	

	static ArrayList<String> arrNotWeave = null;
	static ArrayList<String> arrWeave = null;
	static HashMap<String, ArrayList<Tuple2>> hmInternalAttribute = new HashMap<String, ArrayList<Tuple2>>();

	static HashMap<Class<?>, ArrayList<Method>> hmIninheritedMethods = new HashMap<Class<?>, ArrayList<Method>>();
	// External Attribute must be acceded by a method beginning by get or is.
	static HashMap<String, ArrayList<Tuple2>> hmExternalAttribute = new HashMap<String, ArrayList<Tuple2>>();

	// hmap key = fullname of the class value CompositeType
	static HashMap<String, CompositeType> hmClassCT = new HashMap<String, CompositeType>();
	static HashMap<String, Integer> hmDepthIntrospect = new HashMap<String, Integer>();
	static {
		System.out.println(Version.version);
		System.out
				.println("Static initialisation Aspect : jlp.aspectsJMX.abstractAspects.AbstractGenericMBeanNumeric2");
		tMB = ManagementFactory.getThreadMXBean();
		Locale.setDefault(Locale.ENGLISH);
		mbs = ManagementFactory.getPlatformMBeanServer();
		/*
		 * outDurationMethods .append(new StringBuffer(
		 * "####time;Class.methods;time in millisecondes\n") .toString());
		 */
		props = jlp.perf.aspects.abstractAspects.AspectsPerfProperties.aspectsPerfProperties;

		String strFreqLogs = props
				.getProperty(
						"jlp.aspectsJMX.abstractAspects.AbstractGenericMBeanNumeric2.frequenceMeasure",
						"1");
		if (strFreqLogs.contains("ms")) {
			isTimeFreq = true;
			frequenceMeasure = Integer.parseInt(strFreqLogs.substring(0,
					strFreqLogs.indexOf("m")).trim());
		} else {
			frequenceMeasure = Integer.parseInt(strFreqLogs.trim());
		}

		// arrClasses = new ArrayList<String>(lst);
		String strNotWeave = props
				.getProperty(
						"jlp.aspectsJMX.abstractAspects.AbstractGenericMBeanNumeric2.listNotWeave",
						"");
		if (strNotWeave.trim().length() > 0) {
			arrNotWeave = new ArrayList<String>(Arrays.asList(strNotWeave
					.split(";")));
		}
		String strWeave = props
				.getProperty(
						"jlp.aspectsJMX.abstractAspects.AbstractGenericMBeanNumeric2.listWeave",
						"");
		if (strWeave.trim().length() > 0) {
			arrWeave = new ArrayList<String>(Arrays.asList(strWeave.split(";")));
		}
		isGetThis = Boolean
				.parseBoolean(props
						.getProperty(
								"jlp.aspectsJMX.abstractAspects.AbstractGenericMBeanNumeric2.isGetThis",
								"true"));
		// Liste des classes a exporter ( elles sont separes par un ; dans le
		// fichier de props)
		// The property dephtInstrospect is like
		// (<FullNameClass|"All">:<depth>";")+
		String[] strDepth = props
				.getProperty(
						"jlp.aspectsJMX.abstractAspects.AbstractGenericMBeanNumeric2.depthIntrospect",
						"All:-1;").split(";");

		for (String depth : strDepth) {
			if (depth.split(":")[0].equals("All")) {
				hmDepthIntrospect.put("All", new Integer(depth.split(":")[1]));
			} else {
				hmDepthIntrospect.put(depth.split(":")[0],
						new Integer(depth.split(":")[1]));
			}

		}
		// lister les champs internes
		//hmBean.clear();
	}

	private final static  boolean isNumeric(String type){
		if(type.equals("int")||
				type.equals("java.lang.Integer")||
				type.equals("long")||
				type.equals("java.lang.Long")||
				type.equals("double")||
				type.equals("java.lang.Double")||
				type.equals("float")||
				type.equals("java.lang.Float")||
				type.equals("int")||
				type.equals("java.lang.Integer")||
				type.equals("short")||
				type.equals("java.lang.Short")||
				type.equals("byte")||
				type.equals("java.lang.Byte")		
				) return true;
		return false;
	}
	private static final synchronized void addClass(String nameClazz,
			ClassLoader cl) {
		Class<?> myClazz = null;
		try {
			myClazz = Class.forName(nameClazz, false, cl);
			Field[] tabFields = myClazz.getDeclaredFields();

			ArrayList<Tuple2> lstTup = new ArrayList<Tuple2>();
			for (Field field : tabFields) {
				if (!field.isSynthetic()) {
					// On applique le filtre d include et d exclude
					boolean take0 = false;
					String name = field.getName();
					if (arrWeave.size() == 0)
						take0 = true;
					for (String weave : arrWeave) {

						Pattern pat = Pattern.compile(weave);
						if (pat.matcher(nameClazz + "." + name).find()) {
							take0 = true;
						}
					}
					for (String notWeave : arrNotWeave) {
						Pattern pat = Pattern.compile(notWeave);
						if (pat.matcher(nameClazz + "." + name).find()) {
							take0 = false;
						}
					}
					if (take0) {
						// On mets dans hmInternalAttribute
						// on ne prend que les valeurs numeriques
						String typeField= field.getType()
								.getName();
						if( isNumeric(typeField)){
						lstTup.add(new Tuple2(field.getName(), field.getType()
								.getName()));
						}
					}
				}
			}
			hmInternalAttribute.put(nameClazz, lstTup);
			Method[] tabMethods = Class.forName(nameClazz, false, cl)
					.getDeclaredMethods();
			ArrayList<Tuple2> lstTupMeth = new ArrayList<Tuple2>();
			// trouver les methodes get et set hors getter et setter interne

			ArrayList<Tuple2> lstTupMethAlias = new ArrayList<Tuple2>();
			for (Method met : tabMethods) {
				String name = met.getName();
				if (!met.isSynthetic() && (met.getParameterTypes().length == 0)
						&& (name.startsWith("get") || name.startsWith("is"))) {
					// && ((null == arrNotWeave) || !arrNotWeave
					// .contains(clazz + "." + name))) {
					boolean take0 = false;

					if (arrWeave.size() == 0)
						take0 = true;
					for (String weave : arrWeave) {
						Pattern pat = Pattern.compile(weave);
						if (pat.matcher(nameClazz + "." + name).find()) {
							take0 = true;
						}
					}
					for (String notWeave : arrNotWeave) {
						Pattern pat = Pattern.compile(notWeave);
						if (pat.matcher(nameClazz + "." + name).find()) {
							take0 = false;
						}
					}
					if (take0) {
						String str2 = null;
						if (name.startsWith("get")) {
							str2 = name.substring(3);
						} else if (name.startsWith("is")) {
							str2 = name.substring(2);
						}
						boolean take = true;
						for (Tuple2 tup : lstTup) {
							if (tup.name.toLowerCase().equals(
									str2.toLowerCase())) {
								take = false;
							}
						}
						if (take) {
							String firstLetter = str2.substring(0, 1)
									.toLowerCase();
							String nameParam = firstLetter + str2.substring(1);
							if(isNumeric( met
									.getReturnType().getName())){
							lstTupMethAlias.add(new Tuple2(nameParam, met
									.getReturnType().getName()));
							lstTupMeth.add(new Tuple2(name, met.getReturnType()
									.getName()));
							}
						}
					}

				}
			}
			hmExternalAttribute.put(nameClazz, lstTupMeth);
			// Traitement des methodes des superClasses de profondeur
			// depthIntrospect

			// test depth =1
			List<Method> listLocIninheritedMethods = new ArrayList<Method>();
			System.out.println(" recherche get dans classes meres");
			Class<?> mySuperClazz = myClazz.getSuperclass();
			if (mySuperClazz.getName().equals("java.lang.Object")) {
				System.out.println("SuperClass is java.lang.Object ");
			} else {
				HashMap<Class<?>, Method[]> returnHm = new HashMap<Class<?>, Method[]>();
				if (hmDepthIntrospect.containsKey("All")) {
					System.out.println("Lancement avec All:"
							+ hmDepthIntrospect.get("All"));
					if (hmDepthIntrospect.get("All") >= 0) {
						listLocIninheritedMethods = getAllGetIneheritedMethods(
								mySuperClazz.getName(),
								new ArrayList<Method>(), cl,
								hmDepthIntrospect.get("All"));
					}
				} else {
					if (hmDepthIntrospect.get(nameClazz) >= 0) {
						listLocIninheritedMethods = getAllGetIneheritedMethods(
								mySuperClazz.getName(),
								new ArrayList<Method>(), cl,
								hmDepthIntrospect.get(nameClazz));
					}
				}
				System.out
						.println("After Call getAllGetIneheritedMethods listLocIninheritedMethods nb Methods retenues:"
								+ listLocIninheritedMethods.size());
			}
			ArrayList<Tuple2> lstTupMethAliasBis = new ArrayList<Tuple2>();
			ArrayList<Method> listLocIninheritedMethodsFiltered = new ArrayList<Method>();
			System.out.println("listLocIninheritedMethods.size()="
					+ listLocIninheritedMethods.size());
			if (listLocIninheritedMethods.size() != 0) {

				ArrayList<Tuple2Method> lstTupMethSuper = new ArrayList<Tuple2Method>();
				// trouver les methodes get et set hors getter et setter interne
				ArrayList<String> lstMethodNameAdded = new ArrayList<String>();
				for (Method met : listLocIninheritedMethods) {
					String name = met.getName();
					if (!met.isSynthetic()
							&& (met.getParameterTypes().length == 0)
							&& (name.startsWith("get") || name.startsWith("is"))) {
						// && ((null == arrNotWeave) || !arrNotWeave
						// .contains(clazz + "." + name))) {
						boolean take0 = false;

						if (arrWeave.size() == 0)
							take0 = true;
						for (String weave : arrWeave) {
							Pattern pat = Pattern.compile(weave);
							if (pat.matcher(nameClazz + "." + name).find()) {
								take0 = true;
							}
						}
						for (String notWeave : arrNotWeave) {
							Pattern pat = Pattern.compile(notWeave);
							if (pat.matcher(nameClazz + "." + name).find()) {
								take0 = false;
							}
						}
						if (take0) {
							String str2 = null;
							if (name.startsWith("get")) {
								str2 = name.substring(3);
							} else if (name.startsWith("is")) {
								str2 = name.substring(2);
							}
							boolean take = true;
							for (Tuple2 tup : lstTup) {
								if (tup.name.toLowerCase().equals(
										str2.toLowerCase())) {
									take = false;
								}
							}
							if (take) {
								String firstLetter = str2.substring(0, 1)
										.toLowerCase();
								String nameParam = firstLetter
										+ str2.substring(1);
								// traiter les doublons
								if (!lstMethodNameAdded.contains(met.getName())) {
									if(isNumeric(met.getReturnType()
													.getName())){
									lstMethodNameAdded.add(met.getName());
									listLocIninheritedMethodsFiltered.add(met);
									lstTupMethAliasBis.add(new Tuple2(
											nameParam, met.getReturnType()
													.getName()));
									lstTupMethSuper.add(new Tuple2Method(met,
											met.getReturnType().getName()));
									}
								}

							}
						}

					}

				}
				hmIninheritedMethods.put((Class<?>) myClazz,
						listLocIninheritedMethodsFiltered);
			}

			System.out.println("lstTupMethAliasBis.size()="
					+ lstTupMethAliasBis.size());

			// Fabrication du CompositeType
			ArrayList<Tuple2> allAttr = new ArrayList<Tuple2>();
			allAttr.addAll(lstTup);
			allAttr.addAll(lstTupMethAlias);

			allAttr.addAll(lstTupMethAliasBis);

			int sz = allAttr.size();
			System.out.println("nb ItemsNames=" + sz);
			String[] itemsName = new String[sz];
			String[] itemDescriptions = new String[sz];
			SimpleType<?>[] openTypes = new SimpleType[sz];

			int i = 0;
			for (Tuple2 tup : allAttr) {
				itemsName[i] = tup.name;
				itemDescriptions[i] = tup.name;
				if (tup.type.equals("java.lang.String")) {
					openTypes[i] = SimpleType.STRING;

				} else if (tup.type.equals("java.lang.Integer")
						|| tup.type.equals("int")) {
					openTypes[i] = SimpleType.INTEGER;

				} else if (tup.type.equals("java.lang.Double")
						|| tup.type.equals("double")) {
					openTypes[i] = SimpleType.DOUBLE;

				} else if (tup.type.equals("java.lang.Float")
						|| tup.type.equals("float")) {
					openTypes[i] = SimpleType.FLOAT;

				} else if (tup.type.equals("java.lang.Boolean")
						|| tup.type.equals("boolean")) {
					openTypes[i] = SimpleType.BOOLEAN;

				} else if (tup.type.equals("java.lang.Long")
						|| tup.type.equals("long")) {
					openTypes[i] = SimpleType.LONG;

				} else if (tup.type.equals("java.lang.Short")
						|| tup.type.equals("short")) {
					openTypes[i] = SimpleType.SHORT;

				}
				else if (tup.type.equals("java.lang.Byte")
						|| tup.type.equals("byte")) {
					openTypes[i] = SimpleType.BYTE;

				}
				else if (tup.type.equals("java.lang.Character")
						|| tup.type.equals("char")) {
					openTypes[i] = SimpleType.CHARACTER;

				}
				
				i++;
			}
			try {
				CompositeType cp = new CompositeType("mapValues",
						"Table of Values", itemsName, itemDescriptions,
						openTypes);
				hmClassCT.put(nameClazz, cp);
			} catch (OpenDataException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} catch (SecurityException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	public static final synchronized List<Method> getAllGetIneheritedMethods(
			String nameClazz, List<Method> lstMeth, ClassLoader cl, int depth) {
		// depth ==0 => Only for this super Class; depht ==1 => for this super
		// Class and super.super class and so on
		Class<?> clazz = null;
		ArrayList<Method> returnLst = new ArrayList<Method>();
		try {
			clazz = Class.forName(nameClazz, false, cl);
		} catch (ClassNotFoundException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}

		if (depth == 0) {
			if (!nameClazz.equals("java.lang.Object")) {
				Method[] tabMethods = null;
				try {
					tabMethods = clazz.getDeclaredMethods();
				} catch (SecurityException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}

				for (Method met1 : tabMethods) {
					if (!lstMeth.contains(met1))
						lstMeth.add(met1);
				}

				for (Method met : lstMeth) {
					// System.out.println("getAllGetIneheritedMethods Method="
					// + met.getName());
					String name = met.getName();
					if (!met.isSynthetic()
							&& (met.getParameterTypes().length == 0)
							&& (name.startsWith("get") || name.startsWith("is"))) {
						// && ((null == arrNotWeave) || !arrNotWeave
						// .contains(clazz + "." + name))) {
						boolean take0 = false;

						if (arrWeave.size() == 0)
							take0 = true;
						for (String weave : arrWeave) {
							Pattern pat = Pattern.compile(weave);
							if (pat.matcher(nameClazz + "." + name).find()) {
								take0 = true;
							}
						}
						for (String notWeave : arrNotWeave) {
							Pattern pat = Pattern.compile(notWeave);
							if (pat.matcher(nameClazz + "." + name).find()) {
								take0 = false;
							}
						}
						if (take0) {
							System.out
									.println("getAllGetIneheritedMethods Method retenue ="
											+ met.getName());
							returnLst.add((Method) met);

						}

					}
				}

			}
		} else {
			Class<?> superCl = clazz.getSuperclass();
			Method[] tabMethods = null;
			try {
				tabMethods = clazz.getDeclaredMethods();
			} catch (SecurityException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

			for (Method met1 : tabMethods) {
				if (!returnLst.contains(met1))
					returnLst.add(met1);
			}

			returnLst.addAll(getAllGetIneheritedMethods(superCl.getName(),
					returnLst, cl, depth - 1));
		}
		System.out.println("getAllGetIneheritedMethods nb Methods retenues:"
				+ returnLst.size());
		return returnLst;
	}

	// pointcut de type execution et pas de type call
	// Les methodes de l objet utilisees dans le corps de l advice doivent
	// absolument être exclues du weaving
	// pour eviter des boucles infinies.
	
	
	public abstract pointcut methods();

	// Object around(): classes()
	before(): methods()
	{
		// System.out.println("Rentree dans le weaving");
		Object currentObject = null;
		Class<?> clazz = null;
		if (isGetThis) {
			currentObject = thisJoinPoint.getThis();
			clazz = thisJoinPoint.getThis().getClass();
		} else {
			currentObject = thisJoinPoint.getTarget();
			clazz = thisJoinPoint.getTarget().getClass();
		}
		
		String nameClass = currentObject.getClass().getName();
		
		
		GenericBean genMBean =null;
		
		lock.lock();
		try
		 {
			
			if (hmBean.isEmpty() || !hmBean.containsKey(currentObject)) {
				//System.out.println("nameClass="+nameClass);
				if (!hmInternalAttribute.containsKey(nameClass)
						&& !hmExternalAttribute.containsKey(nameClass)) {
					// System.out.println("ajout class:" + nameClass);
					addClass(nameClass, clazz.getClassLoader());

					// on ajoute le MBEan et on l'enregistre
					int nbAttributes = 0;
					if (hmInternalAttribute.containsKey(nameClass)) {
						nbAttributes = hmInternalAttribute.get(nameClass)
								.size();
					}
					if (hmExternalAttribute.containsKey(nameClass)) {
						nbAttributes += hmExternalAttribute.get(nameClass)
								.size();
					}
					String shortName = nameClass;
					if (nameClass.contains(".")) {
						shortName = nameClass.substring(nameClass
								.lastIndexOf(".") + 1);
					}
					String name = null;
					try {

						try {
							Method meth = currentObject.getClass().getMethod(
									"getName");
							name = (String) currentObject.getClass()
									.getMethod("getName", (Class<?>[]) null)
									.invoke(currentObject, (Object[]) null);

						} catch (NoSuchMethodException e) {

							name = shortName + "_" + counter;
							counter++;

						}
					} catch (SecurityException e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
					} catch (IllegalArgumentException e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
					} catch (IllegalAccessException e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
					} catch (InvocationTargetException e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
					}
					genMBean= new GenericBean(name);
					
					ObjectName objName = null;
					try {
						objName = new ObjectName("GenericMBeanNumeric2:type="
								+ shortName + ",name=" + name);
					} catch (MalformedObjectNameException e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
					} catch (NullPointerException e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
					}

					try {
						mbs.registerMBean(genMBean, objName);
						hmBean.put(currentObject, genMBean);

					} catch (InstanceAlreadyExistsException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (MBeanRegistrationException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (NotCompliantMBeanException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}

				}

			}
		}
		finally{
			lock.unlock();
		}
		

		// recuperer le bean en synchronized

	

		// Verifie si on doit mettre a jour en fonction de la frequence
		
		genMBean = hmBean.get(currentObject);
		genMBean.setNumExecution(genMBean.getNumExecution() + 1);

		boolean boolExec = true;
		if (isTimeFreq) {
			Long lastTime = genMBean.getCurrentAge();
			if ((System.currentTimeMillis() - lastTime) > (long) frequenceMeasure) {
				genMBean.setCurrentAge(System.currentTimeMillis());
			} else {
				boolExec = false;
			}

		} else {
			Long lastTime = genMBean.getCurrentAge();
			if (lastTime >= (long) frequenceMeasure) {
				genMBean.setCurrentAge(1L);
			} else {
				genMBean.setCurrentAge(lastTime + 1);
				boolExec = false;
			}
		}

		if (boolExec) {
			// eviter une fuite dans l identityHashMap
			if (hmBean.size()> 20)
				{
				hmBean.clear();
				counter=0;
				return;
				}
			// On va mettre a jour le Mbean avec les donnees de l'Object
			// Internal attributes
			// on cree un HashMap Local
			HashMap<String, Object> localMapCD = new HashMap<String, Object>(
					hmClassCT.get(nameClass).keySet().size());
			ArrayList<Tuple2> lstTupAttr = hmInternalAttribute.get(nameClass);
			int cptInterne = 0;
			for (Tuple2 tup : lstTupAttr) {
				cptInterne++;
				// System.out.println("traitement param interne :"+cptInterne+" name="+tup.name);
				Field field = null;
				try {
					field = clazz.getDeclaredField(tup.name);

				} catch (SecurityException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (NoSuchFieldException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				field.setAccessible(true);
				try {

					if (tup.type.equals("int")
							|| tup.type.equals("java.lang.Integer")) {
						// On doit tester la valeur nulle
						try {
							localMapCD.put(tup.name,
									new Integer(field.getInt(currentObject)));
						} catch (NullPointerException e) {
							localMapCD.put(tup.name, new Integer(0));
						}
					} else if (tup.type.equals("long")
							|| tup.type.equals("java.lang.Long")) {
						try {
							localMapCD.put(tup.name,
									new Long(field.getLong(currentObject)));
						} catch (NullPointerException e) {
							localMapCD.put(tup.name, new Long(0l));
						}

					} else if (tup.type.equals("double")
							|| tup.type.equals("java.lang.Double")) {
						try {
							localMapCD.put(tup.name,
									new Double(field.getDouble(currentObject)));
						} catch (NullPointerException e) {
							localMapCD.put(tup.name, new Double(0d));
						}
					} else if (tup.type.equals("float")
							|| tup.type.equals("java.lang.Float")) {
						try {
							localMapCD.put(tup.name,
									new Float(field.getFloat(currentObject)));
						} catch (NullPointerException e) {
							localMapCD.put(tup.name, new Float(0f));
						}
					} 
					 else if (tup.type.equals("short")
								|| tup.type.equals("java.lang.Short")) {
							try {
								localMapCD.put(tup.name,
										new Short(field.getShort(currentObject)));
							} catch (NullPointerException e) {
								localMapCD.put(tup.name, new Short("0"));
							}
						}
					
					 else if (tup.type.equals("byte")
								|| tup.type.equals("java.lang.Byte")) {
							try {
								localMapCD.put(tup.name,
										new Byte(field.getByte(currentObject)));
							} catch (NullPointerException e) {
								localMapCD.put(tup.name, new Byte("0"));
							}
						}
					 else if (tup.type.equals("char")
								|| tup.type.equals("java.lang.Character")) {
							try {
								localMapCD.put(tup.name,
										new Character(field.getChar(currentObject)));
							} catch (NullPointerException e) {
								localMapCD.put(tup.name, new Character((char)0));
							}
						}

				} catch (IllegalArgumentException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (IllegalAccessException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
			// External attributes

			ArrayList<Tuple2> lstTupMeth = hmExternalAttribute.get(nameClass);

			int cptExterne = 0;
			for (Tuple2 tup : lstTupMeth) {
				cptExterne++;
				// System.out.println("traitement param externe :"+cptExterne+" name="+tup.name);
				Method meth = null;
				// Suppression du debut "get" ou "is", remplacement de la
				// premiere lettre par sa minuscule

				String nameParam = "";
				if (tup.name.startsWith("get")) {
					nameParam = tup.name.substring(3);
					String firstLetter = nameParam.substring(0, 1)
							.toLowerCase();
					nameParam = firstLetter + nameParam.substring(1);

				} else {
					nameParam = tup.name.substring(2);
					String firstLetter = nameParam.substring(0, 1)
							.toLowerCase();
					nameParam = firstLetter + nameParam.substring(1);
				}
				try {

					meth = clazz.getDeclaredMethod(tup.name);

				} catch (SecurityException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (NoSuchMethodException e) {
					e.printStackTrace();
				}
				meth.setAccessible(true);

				try {

					Object ret = meth.invoke(currentObject, (Object[]) null);
					if (null == ret) {
						localMapCD.put(nameParam, "");
					} else {
						String typeExt = ret.getClass().getName();
						if (typeExt.equals("java.lang.Integer")) {
							localMapCD.put(nameParam, (Integer) ret);
						} else if (typeExt.equals("java.lang.Long")) {
							localMapCD.put(nameParam, (Long) ret);
						} else if (typeExt.equals("java.lang.Double")) {
							localMapCD.put(nameParam, (Double) ret);
						} else if (typeExt.equals("java.lang.Float")) {
							localMapCD.put(nameParam, (Float) ret);

						} 
						else if (typeExt.equals("java.lang.Byte")) {
							localMapCD.put(nameParam, (Byte) ret);

						}
						else if (typeExt.equals("java.lang.Character")) {
							localMapCD.put(nameParam, (Character) ret);

						}
						else if (typeExt.equals("java.lang.Short")) {
							localMapCD.put(nameParam, (Short) ret);

						}
						
						

					}

				} catch (IllegalArgumentException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (InvocationTargetException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				} catch (IllegalAccessException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}

			}

			// Inherited Attribute

			ArrayList<Method> listMeths = hmIninheritedMethods
					.get(currentObject.getClass());
			// TODO

			if (null != listMeths) {
				for (Method meth : listMeths) {

					try {

						String nameMethod = meth.getName();
						String nameParam = "";
						if (nameMethod.startsWith("get")) {
							nameParam = nameMethod.substring(3);
							String firstLetter = nameParam.substring(0, 1)
									.toLowerCase();
							nameParam = firstLetter + nameParam.substring(1);

						} else {
							nameParam = nameMethod.substring(2);
							String firstLetter = nameParam.substring(0, 1)
									.toLowerCase();
							nameParam = firstLetter + nameParam.substring(1);
						}
						Object ret = meth
								.invoke(currentObject, (Object[]) null);
						if (null == ret) {
							localMapCD.put(nameParam, "");
						} else {
							String typeExt = ret.getClass().getName();
							if (typeExt.equals("java.lang.Integer")) {
								localMapCD.put(nameParam, (Integer) ret);
							} else if (typeExt.equals("java.lang.Long")) {
								localMapCD.put(nameParam, (Long) ret);
							} else if (typeExt.equals("java.lang.Double")) {
								localMapCD.put(nameParam, (Double) ret);
							} else if (typeExt.equals("java.lang.Float")) {
								localMapCD.put(nameParam, (Float) ret);

							} else if (typeExt.equals("java.lang.Boolean")) {
								localMapCD.put(nameParam, (Boolean) ret);

							} else {
								// use toString for other type
								localMapCD.put(nameParam, ret.toString());
							}
						}
					} catch (IllegalArgumentException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (InvocationTargetException e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
					} catch (IllegalAccessException e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
					}

				}
			}

			try {

				genMBean.setCompositeDataSupport(new CompositeDataSupport(
						hmClassCT.get(nameClass), localMapCD));
				

			} catch (OpenDataException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

			hmBean.put(currentObject, genMBean);
		}

		// return proceed();
	}

}
