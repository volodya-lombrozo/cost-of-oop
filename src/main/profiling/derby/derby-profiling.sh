set -x
set -e

# In order to attach java agent use the next command for Mac
# -agentpath:<profiler directory>/bin/mac/libyjpagent.dylib
# To check commands for other OSs, please, visit https://www.yourkit.com/docs/java/help/agent.jsp
# In my case <profiler directory> is /Applications/YourKit-Java-Profiler-2022.9.app/Contents/Resources/bin/mac/libyjpagent.dylib

#Start derby
java -agentpath:/Applications/YourKit-Java-Profiler-2022.9.app/Contents/Resources/bin/mac/libyjpagent.dylib -jar /Users/lombrozo/Workspace/Tools/db-derby-10.16.1.1-bin/lib/derbyrun.jar server start &
APP_PID=$!
# Wait until startup

sleep 5

# Add load through JMeter
# In my case JMeter path /Users/lombrozo/Workspace/Tools/apache-jmeter-5.5/bin
# The full documentation about JMeter cli you can find right here:
# https://jmeter.apache.org/usermanual/get-started.html#non_gui
/Users/lombrozo/Workspace/Tools/apache-jmeter-5.5/bin/jmeter -n -t "Apache Derby.jmx"

# Warmup

sleep 5

#Profile an application
PROFILER=/Applications/YourKit-Java-Profiler-2022.9.app/Contents/Resources/lib/yjp-controller-api-redist.jar
SNAPSHOTS=/Users/lombrozo/Snapshots
java -jar $PROFILER status

java -jar $PROFILER clear-cpu-data
java -jar $PROFILER clear-alloc-data
java -jar $PROFILER clear-monitor-data
java -jar $PROFILER clear-charts

java -jar $PROFILER start-alloc-object-counting
java -jar $PROFILER start-tracing
echo "Profiling is started successfully"
sleep 60
java -jar $PROFILER capture-performance-snapshot
java -jar $PROFILER capture-memory-snapshot
java -jar $PROFILER stop-alloc-recording
java -jar $PROFILER stop-cpu-profiling
ls -Artlh $SNAPSHOTS | tail -n 2
echo  "Profiling is stopped successfully"


#Stop load testing
/Users/lombrozo/Workspace/Tools/apache-jmeter-5.5/bin/stoptest.sh

#Stop application
kill $APP_PID
