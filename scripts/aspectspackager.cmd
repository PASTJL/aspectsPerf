SET root=D:\opt\aspectsPerf
SET workspace=D:\opt\aspectsPerf\workspace
SET CLASSPATH=%root%\aspectsPerf.jar
SET CLASSPATH=%CLASSPATH%;%root%\lib\aspectjweaver.jar

java  -Xms128M -Xmx128M -Droot=%root% -Dworkspace=%workspace% -classpath %CLASSPATH% jlp.perf.aspects.gui.AspectsPackager