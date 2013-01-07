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
package jlp.perf.aspects.abstractAspects;

// import jlp.exemple1.*;
import java.io.File;
import java.io.IOException;
import java.lang.ref.PhantomReference;
import java.lang.ref.ReferenceQueue;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Properties;

public abstract aspect  AbstractCounterPhRef {
	private static String fileTrace = "";
	private static jlp.perf.aspects.abstractAspects.Trace outCountPhRef;
	private static HashMap<String,Object> listClass = new HashMap<String,Object>();
	private static Properties props;
	private static Map<String,StructPhantomRefQueueRef> hmPhRefQ = null;
	private static int freqRefresh = 0;
	public static ReferenceQueue[] tabReq = null;
	public static StructPhantomRefQueueRef[] tabStruct = null;
	public static boolean garbage = true;
	private static String dirLogs,sep=";";
	static {
		Locale.setDefault(Locale.ENGLISH);
		props = jlp.perf.aspects.abstractAspects.AspectsPerfProperties.aspectsPerfProperties;
		if(props.containsKey("aspectsPerf.default.sep"))
		{
			sep=props.
			getProperty("aspectsPerf.default.sep");
		}
		
		if(props.containsKey("aspectsPerf.default.dirLogs"))
		{
			dirLogs = props.
		getProperty("aspectsPerf.default.dirLogs");
			if(!dirLogs.endsWith(File.separator))
			{
				dirLogs+=File.separator;
			}
		}
		else
		{
			dirLogs = "";
		}
		if (props.containsKey("jlp.perf.aspects.abstractAspects.AbstractCounterPhRef.filelogs")) {
			fileTrace =dirLogs+ props.getProperty("jlp.perf.aspects.abstractAspects.AbstractCounterPhRef.filelogs");
		} else {
			fileTrace = props.getProperty("aspectsPerf.default.filelogs");
		}

		freqRefresh = Integer.parseInt(props
				.getProperty("jlp.perf.aspects.abstractAspects.AbstractCounterPhRef.freqRefresh"));
		if (props.containsKey("jlp.perf.aspects.abstractAspects.AbstractCounterPhRef.garbage")) {
			if (props.get("jlp.perf.aspects.abstractAspects.AbstractCounterPhRef.garbage").equals("false")) {
				garbage = false;
			}
		}

		outCountPhRef = new Trace("####time"+sep+"Enqueued (dead) References"+sep+"Nb Alive Objects"+sep+"Name of Class\n",fileTrace);
		//outCountPhRef.append(new StringBuilder("####time;Enqueued (dead) References;Nb Alive Objects;Name of Class\n")	.toString());

		initialise();

	}

	private static void initialise() {
	
		hmPhRefQ = new HashMap<String,StructPhantomRefQueueRef>();
		// Hasmap nomdeclasse/instancesEnVies
	
			if (props.containsKey("jlp.perf.aspects.abstractAspects.AbstractCounterPhRef.class_list")) {
			String[] tabString=props.getProperty("jlp.perf.aspects.abstractAspects.AbstractCounterPhRef.class_list").split(";");
		for (int i=0, len=tabString.length;i<len;i++)
		{
			listClass.put(tabString[i],new Integer(0));
		}
				

		}
		int taille = listClass.size();
		System.out.println("taille = " + taille);
		tabReq = new ReferenceQueue[taille];
		tabStruct = new StructPhantomRefQueueRef[taille];
		for (int j = 1; j <= taille; j++) {
			tabReq[j - 1] = new ReferenceQueue<Object>();
			tabStruct[j - 1] = new StructPhantomRefQueueRef(tabReq[j - 1]);
			hmPhRefQ.put(props.getProperty("jlp.perf.aspects.abstractAspects.AbstractCounterPhRef.class_list"
					+ Integer.toString(j)), tabStruct[j - 1]);
			System.out.println("creation de jlp.perf.aspects.abstractAspects.AbstractCounterPhRef_list"
					+ j
					+ " = "
					+ props.getProperty("jlp.perf.aspects.abstractAspects.AbstractCounterPhRef.class_list"
							+ Integer.toString(j)));
		}

	}

	public abstract pointcut constructeur();

	private final synchronized int add(Object _ret,StructPhantomRefQueueRef sprqr, String key) {
		
		Integer integ = ((Integer) listClass.get((String) key));
		sprqr.addPhRef(_ret);
		integ = new Integer(integ.intValue() + 1);
		// on poll la referenceQueue correspontante pour voir si les objets existent
		int count = 0;

		if (sprqr.currentNbRefresh > freqRefresh) {

			if (garbage) {
				//System.out.println(" Garbaging from the Aspect");
				System.gc();
			}
			//StructPhantomRefQueueRef spqr=(StructPhantomRefQueueRef) hmPhRefQ.get((String) key);
			
			int ln = sprqr.alPhRef.size();
		
			PhantomReference<Object>[] tabRef=new PhantomReference[ln];
			int k = 0;
			// recuperer la reference quee
			/*ReferenceQueue refQ=sprqr.refQ;
			PhantomReference tmpRef=null;
			
				while((tmpRef=(PhantomReference) refQ.poll())!=null)
				{
					count++;
				//	tmpRef.clear();
					tmpRef=null;
					System.out.println(count + " : Dequeuing");
					
				}
			*/
			
			for (int j = 0; j < ln; j++) {
				if (((PhantomReference) sprqr.alPhRef.get(j)).isEnqueued()) {
					
					//System.out.println(k+ " : Dequeuing");
					count++;
					tabRef[k] = (PhantomReference) sprqr.alPhRef.get(j);
					
					//((PhantomReference) tabRef[k]).clear();
					
					//sprqr.alPhRef.remove((PhantomReference)tabRef[k]);
					//tabRef[k]=null;
					k++;
				}
			}
			// reconstitution de la liste des reference
			//System.out.println("\nNumber Object to remove :"+k+"\n");
			sprqr = sprqr.remove(tabRef);
			
			integ = new Integer(integ.intValue() - count);
			sprqr.refQ=null;
			sprqr.refQ= new ReferenceQueue();
			sprqr.currentNbRefresh = 0;
			// on remet a jour la structure
			hmPhRefQ.put(key, sprqr);
		} else {
			sprqr.currentNbRefresh++;
			hmPhRefQ.put(key, sprqr);
		}
		listClass.put((String) key, integ);
		
		return ( count );
//		//return count;

	}

	Object around() : constructeur()
		{
		Object ret = proceed();
		
		String key = (String) thisJoinPoint.getSignature()
				.getDeclaringTypeName();
		if (listClass.containsKey(key)) {
			//On reference l'objet a la queue de PhantomReference correspondante
			//System.out.println("Dans Aspect jp constructeur :"+key);
			//	System.out.println("hmPhReq.size = "+ hmPhRefQ.size());
			
			
			
			
			int tmpCurrentNbRefresh = ((StructPhantomRefQueueRef) hmPhRefQ
			.get(key)).currentNbRefresh;

			int nbRemoved = add(ret,(StructPhantomRefQueueRef) hmPhRefQ
					.get(key), thisJoinPoint.getSignature().getDeclaringTypeName());
			
			if (tmpCurrentNbRefresh > freqRefresh) {

				outCountPhRef.append(outCountPhRef.getSdf().format(
						Calendar.getInstance().getTime())
						+ sep
						+ nbRemoved
						+ sep
						+ listClass.get(key).toString()
						+ sep
						+ thisJoinPoint.getSignature().getDeclaringTypeName()
						+ "\n");

				try {
					outCountPhRef.getBuffOut().flush();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}

		}
		
		return ret;

	}

}

class StructPhantomRefQueueRef {
	public List alPhRef = new ArrayList();
	public ReferenceQueue refQ = null;
	public int currentNbRefresh = 0;

	public StructPhantomRefQueueRef(ReferenceQueue refQ) {

		this.refQ = refQ;
	}

	public StructPhantomRefQueueRef clear() {
		alPhRef.clear();
		return this;
	}

	public final synchronized void addPhRef(Object _ref) {
		int taille = alPhRef.size();
		boolean trouve = false;
		for (int i = 0; i < taille; i++) {
			// on cherche une place libre
			if (null == alPhRef.get(i)) {
			//	System.out.println ( "palce libre : "+i);
				alPhRef.set(i, new PhantomReference(_ref, this.refQ));
				trouve = true;
				break;
			}
		}
		if (!trouve) {
			// System.out.println (" on le met a la fin");
			alPhRef.add(new PhantomReference(_ref, this.refQ));
		}
		//System.out.println(" size of alPhRef = "+alPhRef.size());
	}

	public final synchronized StructPhantomRefQueueRef remove(Object[] refs) {
		int ln = refs.length;
		int destroyed=0;
		for (int kk = 0; kk < ln; kk++) {
			if (null!=refs[kk])
			{
			((PhantomReference) refs[kk]).clear();
			alPhRef.remove((PhantomReference) refs[kk]);
			destroyed++;
			}
			refs[kk]=null;
		}
		
		refs=null;
	//	System.out.println(destroyed+ " objects removed");
		return this;
	}
}
