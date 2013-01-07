package jlp.perf.aspects.abstractAspects;

public abstract aspect AbstractTester {
	
	
	public abstract pointcut methods();
	Object around() : methods()
	{
		
	
	String str="Aspect AbstractTester :"+thisJoinPointStaticPart.getSignature().getDeclaringTypeName()+"."+
			thisJoinPointStaticPart.getSignature().getName()+";"+thisJoinPointStaticPart
			.getSourceLocation().getLine();
	System.out.println(str);
	Object ret = proceed();
	return ret;
		
	}

}
