export JMETER_PLAN="Struts-MVC.jmx"
export JETTY_HOME="/Users/lombrozo/Workspace/Tools/jetty-distribution-9.4.51.v20230217"
export JETTY_BASE="/Users/lombrozo/Workspace/Tools/jetty-distribution-9.4.51.v20230217"
export APPLICATION_JAR="$JETTY_HOME/start.jar"
export PROFILER_AGENT="/Applications/YourKit-Java-Profiler-2022.9.app/Contents/Resources/bin/mac/libyjpagent.dylib"
export APPLICATION_STARTUP="cd $JETTY_HOME ; java -agentpath:$PROFILER_AGENT -jar $APPLICATION_JAR"
../jar-profiling.sh