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
ExecStep $bin_path/vsim -64  -do "do {tb_simulate.do}" -l simulate.log
