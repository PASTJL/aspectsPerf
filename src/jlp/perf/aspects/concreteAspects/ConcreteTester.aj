package jlp.perf.aspects.concreteAspects;



public aspect ConcreteTester {
	public  pointcut methods():execution(public * *..*.*(..));
	Object around() : methods()
	{
	Object ret = proceed();
	String str="Aspect ConcreteTester :"+thisJoinPointStaticPart.getSignature().getDeclaringTypeName()+"."+
			thisJoinPointStaticPart.getSignature().getName()+";"+thisJoinPointStaticPart
			.getSourceLocation().getLine();
	System.out.println(str);
	
	return ret;
	}


}
