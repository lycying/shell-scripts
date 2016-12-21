#!/bin/bash
: ${1?"Usage: '$0 \$pid' should supply a PID"}

PID=$1
DUMP_DATE=`date +%Y%m%d%H%M%S`
DUMP_DIR=`hostname`"-"$DUMP_DATE

if [ ! -d $DUMP_DIR ]; then
	mkdir $DUMP_DIR
fi

echo -e "Dumping $PID to the $DUMP_DIR...\c"

jstack $PID > $DUMP_DIR/jstack-$PID.dump 2>&1
echo -e ".\c"
jinfo $PID > $DUMP_DIR/jinfo-$PID.dump 2>&1
echo -e ".\c"
jstat -gcutil $PID > $DUMP_DIR/jstat-gcutil-$PID.dump 2>&1
echo -e ".\c"
jstat -gccapacity $PID > $DUMP_DIR/jstat-gccapacity-$PID.dump 2>&1
echo -e ".\c"
jmap $PID > $DUMP_DIR/jmap-$PID.dump 2>&1
echo -e ".\c"
jmap -heap $PID > $DUMP_DIR/jmap-heap-$PID.dump 2>&1
echo -e ".\c"
jmap -histo $PID > $DUMP_DIR/jmap-histo-$PID.dump 2>&1
echo -e ".\c"

if [ -r /usr/sbin/lsof ]; then
/usr/sbin/lsof -p $PID > $DUMP_DIR/lsof-$PID.dump
echo -e ".\c"
fi
if [ -r /bin/netstat ]; then
/bin/netstat -antp > $DUMP_DIR/netstat.dump 2>&1
echo -e ".\c"
fi
if [ -r /usr/bin/iostat ]; then
/usr/bin/iostat > $DUMP_DIR/iostat.dump 2>&1
echo -e ".\c"
fi
if [ -r /usr/bin/mpstat ]; then
/usr/bin/mpstat > $DUMP_DIR/mpstat.dump 2>&1
echo -e ".\c"
fi
if [ -r /usr/bin/vmstat ]; then
/usr/bin/vmstat > $DUMP_DIR/vmstat.dump 2>&1
echo -e ".\c"
fi
if [ -r /usr/bin/free ]; then
/usr/bin/free -t > $DUMP_DIR/free.dump 2>&1
echo -e ".\c"
fi
if [ -r /usr/bin/sar ]; then
/usr/bin/sar > $DUMP_DIR/sar.dump 2>&1
echo -e ".\c"
fi
if [ -r /usr/bin/uptime ]; then
/usr/bin/uptime > $DUMP_DIR/uptime.dump 2>&1
echo -e ".\c"
fi

echo "OK!"
echo "DUMP: $DUMP_DIR"
