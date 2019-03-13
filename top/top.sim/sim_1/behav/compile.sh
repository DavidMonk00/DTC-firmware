#!/bin/bash -f
bin_path="/opt/modeltech/bin"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep source ./tb_compile.do 2>&1 | tee -a compile.log
