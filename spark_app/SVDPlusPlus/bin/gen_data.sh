#!/bin/bash
bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
DIR=`cd $bin/../; pwd`
. "${DIR}/../bin/config.sh"
. "${DIR}/bin/config.sh"

echo "========== preparing ${APP} data =========="

# paths check
${HADOOP_HOME}/bin/hadoop fs -rm -r ${INPUT_HDFS}

# generate data


JAR="${DIR}/../common/DataGen/target/scala-2.10/datagen_2.10-1.0.jar"
CLASS="src.main.scala.GraphDataGen"

OPTION="${INPUT_HDFS} ${numV} ${numPar} ${mu} ${sigma}"

START_TIME=`timestamp`
START_TS=`ssh ${master} "date +%F-%T"`

#${HADOOP_HOME}/bin/hadoop fs -copyFromLocal ${SPARK_HOME}/graphx/data/followers.txt ${INPUT_HDFS}
#${HADOOP_HOME}/bin/hadoop fs -copyFromLocal ${SPARK_HOME}/graphx/data/users.txt ${INPUT_HDFS}

#exec ${SPARK_HOME}/bin/spark-submit --class $CLASS --master ${APP_MASTER} ${YARN_OPT} ${SPARK_OPT}  $JAR ${OPTION} 2>&1|tee ${BENCH_NUM}/${APP}_gendata_${START_TS}.dat


${HADOOP_HOME}/bin/hdfs dfs -mkdir ${APP_DIR}
${HADOOP_HOME}/bin/hdfs dfs -mkdir ${INPUT_HDFS}
#srcf=/mnt/nfs_dir/sperf/data_set/web-Google.txt
srcf=/home/hduser/SparkBench/few-edges.txt
#srcf=/home/hduser/SparkBench/
${HADOOP_HOME}/bin/hdfs dfs -copyFromLocal $srcf ${INPUT_HDFS}



END_TIME=`timestamp`

SIZE=`$HADOOP_HOME/bin/hadoop fs -du -s ${INPUT_HDFS} | awk '{ print $1 }'`

gen_report "${APP}_gendata" ${START_TIME} ${END_TIME} ${SIZE} ${START_TS} >> ${BENCH_REPORT}
print_config ${BENCH_REPORT}
exit 0


# ===unused ==compress check 
if [ ${COMPRESS_GLOBAL} -eq 1 ]; then
    COMPRESS_OPT="-compress true \
        -compressCodec $COMPRESS_CODEC \
        -compressType BLOCK "
else
    COMPRESS_OPT="-compress false"
fi
