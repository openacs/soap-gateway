ad_library {

    soap-gateway init library routines

    @author William Byrne (WilliamB@ByrneLitho.com)

}

# schedule a one time directory scan for service source files
ad_schedule_proc -thread t -once t 5 soap::server::lib::boot_libraries