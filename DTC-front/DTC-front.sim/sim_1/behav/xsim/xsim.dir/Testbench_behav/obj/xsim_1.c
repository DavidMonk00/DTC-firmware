/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2013 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/


#include "iki.h"
#include <string.h>
#include <math.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2013 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/


#include "iki.h"
#include <string.h>
#include <math.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
typedef void (*funcp)(char *, char *);
extern void execute_15(char*, char *);
extern void execute_16(char*, char *);
extern void execute_21(char*, char *);
extern void execute_23(char*, char *);
extern void execute_26(char*, char *);
extern void execute_48(char*, char *);
extern void execute_28(char*, char *);
extern void execute_30(char*, char *);
extern void execute_32(char*, char *);
extern void execute_34(char*, char *);
extern void execute_36(char*, char *);
extern void execute_38(char*, char *);
extern void execute_40(char*, char *);
extern void execute_42(char*, char *);
extern void execute_44(char*, char *);
extern void execute_46(char*, char *);
extern void transaction_0(char*, char*, unsigned, unsigned, unsigned);
extern void vhdl_transfunc_eventcallback(char*, char*, unsigned, unsigned, unsigned, char *);
funcp funcTab[18] = {(funcp)execute_15, (funcp)execute_16, (funcp)execute_21, (funcp)execute_23, (funcp)execute_26, (funcp)execute_48, (funcp)execute_28, (funcp)execute_30, (funcp)execute_32, (funcp)execute_34, (funcp)execute_36, (funcp)execute_38, (funcp)execute_40, (funcp)execute_42, (funcp)execute_44, (funcp)execute_46, (funcp)transaction_0, (funcp)vhdl_transfunc_eventcallback};
const int NumRelocateId= 18;

void relocate(char *dp)
{
	iki_relocate(dp, "xsim.dir/Testbench_behav/xsim.reloc",  (void **)funcTab, 18);
	iki_vhdl_file_variable_register(dp + 15720);
	iki_vhdl_file_variable_register(dp + 15776);
	iki_vhdl_file_variable_register(dp + 18144);


	/*Populate the transaction function pointer field in the whole net structure */
}

void sensitize(char *dp)
{
	iki_sensitize(dp, "xsim.dir/Testbench_behav/xsim.reloc");
}

void simulate(char *dp)
{
		iki_schedule_processes_at_time_zero(dp, "xsim.dir/Testbench_behav/xsim.reloc");
	// Initialize Verilog nets in mixed simulation, for the cases when the value at time 0 should be propagated from the mixed language Vhdl net
	iki_execute_processes();

	// Schedule resolution functions for the multiply driven Verilog nets that have strength
	// Schedule transaction functions for the singly driven Verilog nets that have strength

}
#include "iki_bridge.h"
void relocate(char *);

void sensitize(char *);

void simulate(char *);

extern SYSTEMCLIB_IMP_DLLSPEC void local_register_implicit_channel(int, char*);
extern void implicit_HDL_SCinstatiate();

extern SYSTEMCLIB_IMP_DLLSPEC int xsim_argc_copy ;
extern SYSTEMCLIB_IMP_DLLSPEC char** xsim_argv_copy ;

int main(int argc, char **argv)
{
    iki_heap_initialize("ms", "isimmm", 0, 2147483648) ;
    iki_set_sv_type_file_path_name("xsim.dir/Testbench_behav/xsim.svtype");
    iki_set_crvs_dump_file_path_name("xsim.dir/Testbench_behav/xsim.crvsdump");
    void* design_handle = iki_create_design("xsim.dir/Testbench_behav/xsim.mem", (void *)relocate, (void *)sensitize, (void *)simulate, 0, isimBridge_getWdbWriter(), 0, argc, argv);
     iki_set_rc_trial_count(100);
    (void) design_handle;
    return iki_simulate_design();
}
