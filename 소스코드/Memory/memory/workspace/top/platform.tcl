# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct C:\Users\Jeyun\Desktop\fpga\barami_project_2024\memory\workspace\top\platform.tcl
# 
# OR launch xsct and run below command.
# source C:\Users\Jeyun\Desktop\fpga\barami_project_2024\memory\workspace\top\platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {top}\
-hw {C:\Users\Jeyun\Desktop\fpga\barami_project_2024\memory\top.xsa}\
-out {C:/Users/Jeyun/Desktop/fpga/barami_project_2024/memory/workspace}

platform write
domain create -name {standalone_ps7_cortexa9_0} -display-name {standalone_ps7_cortexa9_0} -os {standalone} -proc {ps7_cortexa9_0} -runtime {cpp} -arch {32-bit} -support-app {peripheral_tests}
platform generate -domains 
platform active {top}
domain active {zynq_fsbl}
domain active {standalone_ps7_cortexa9_0}
platform generate -quick
