set -x
set -e
#Init all required variables
JMETER_PATH="/Users/lombrozo/Workspace/Tools/apache-jmeter-5.5/bin"
JMETER_PLAN="Apache Derby.jmx"
PROFILER_API="/Applications/YourKit-Java-Profiler-2022.9.app/Contents/Resources/lib/yjp-controller-api-redist.jar"
PROFILER_AGENT="/Applications/YourKit-Java-Profiler-2022.9.app/Contents/Resources/bin/mac/libyjpagent.dylib"
PROFILER_SNAPSHOTS="/Users/lombrozo/Snapshots"
APPLICATION_JAR="/Users/lombrozo/Workspace/Tools/db-derby-10.16.1.1-bin/lib/derbyrun.jar server start"
# In order to attach java agent use the next command for Mac
# -agentpath:<profiler directory>/bin/mac/libyjpagent.dylib
# To check commands for other OSs, please, visit https://www.yourkit.com/docs/java/help/agent.jsp
# In my case <profiler directory> is /Applications/YourKit-Java-Profiler-2022.9.app/Contents/Resources/bin/mac/libyjpagent.dylib
#Start derby
java -agentpath:$PROFILER_AGENT -jar $APPLICATION_JAR &
APP_PID=$!
# Wait until startup
sleep 5
# Add load through JMeter
# In my case JMeter path /Users/lombrozo/Workspace/Tools/apache-jmeter-5.5/bin
# The full documentation about JMeter cli you can find right here:
# https://jmeter.apache.org/usermanual/get-started.html#non_gui
$JMETER_PATH/jmeter -n -t "$JMETER_PLAN" &
JMETER_PID=$!
# Warmup
sleep 5
#Profile an application
java -jar $PROFILER_API status
java -jar $PROFILER_API clear-cpu-data
java -jar $PROFILER_API clear-alloc-data
java -jar $PROFILER_API clear-monitor-data
java -jar $PROFILER_API clear-charts
java -jar $PROFILER_API start-tracing
echo "Profiling is started successfully"
sleep 60
java -jar $PROFILER_API capture-performance-snapshot
java -jar $PROFILER_API stop-cpu-profiling
echo  "Profiling is stopped successfully"
#Convert results
#Find latest snapshot
SNAPSHOT_FILE=$(find "$PROFILER_SNAPSHOTS" -type f -exec stat -f '%m %R' {} + | sort -n | tail -1 | awk '{print $2}')
#Convert snapshot to csv
java -jar -Dexport.method.list.cpu -Dexport.csv /Applications/YourKit-Java-Profiler-2022.9.app/Contents/Resources/lib/yourkit.jar -export "$SNAPSHOT_FILE" .
#Stop load testing
$JMETER_PATH/stoptest.sh
kill $JMETER_PID
#Stop application
kill $APP_PID
