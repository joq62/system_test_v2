%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(system_init_test).   
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
%% --------------------------------------------------------------------

%% External exports
-export([start/0]).



%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
start()->
    ?debugMsg("Start setup"),
    ?assertEqual(ok,setup()),
    ?debugMsg("stop setup"),

    ?debugMsg("Start syslog"),
    ?assertEqual(ok,syslog()),
    ?debugMsg("stop syslog"),

    ?debugMsg("Start dbase"),
    ?assertEqual(ok,dbase()),
    ?debugMsg("stop dbase"),

    ?debugMsg("Start status_machines"),
    ?assertEqual(ok,status_machines()),
    ?debugMsg("stop status_machines"),


 %   ?debugMsg("Start first_node"),
 %   ?assertEqual(ok,first_node()),
 %   ?debugMsg("stop first_node"),
    
 %   ?debugMsg("Start lock_test_1"),
 %   ?assertEqual(ok,lock_test_1()),
 %   ?debugMsg("stop lock_test_1"),
    
   
      %% End application tests
    ?debugMsg("Start cleanup"),
    ?assertEqual(ok,cleanup()),
    ?debugMsg("Stop cleanup"),

    ?debugMsg("------>"++atom_to_list(?MODULE)++" ENDED SUCCESSFUL ---------"),
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
status_machines()->
    ssh:start(),
    MachineStatus= machine:status(all),
    ?assertMatch([{running,[_,_,_]},{not_available,[]}],
		 MachineStatus),
    
     ?assertMatch(ok,machine:update_status(MachineStatus)),
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
syslog()->
    {ok,HostId}=net:gethostname(),
    SyslogNode=list_to_atom("syslog@"++HostId),
    ?assertMatch({ok,SyslogNode},slave:start(HostId,syslog,"-pa log/ebin -setcookie abc")),
    ?assertMatch(ok,rpc:call(SyslogNode,application,start,[syslog],5000)),
    ?assertMatch({pong,SyslogNode,syslog},rpc:call(SyslogNode,syslog,ping,[],1000)), 

    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
dbase()->
    DbaseEnvs=[{git_user,"joq62"},{git_pw,"20Qazxsw20"},{cl_dir,"cluster_config"},
	       {cl_file,"cluster_info.hrl"},{app_specs_dir,"app_specs"},
	       {service_specs_dir,"service_specs"},
	       {dbase_nodes,['dbase@c0','dbase@c1','dbase@c2']}
	      ],

    {ok,HostId}=net:gethostname(),
    DbaseNode=list_to_atom("dbase@"++HostId),
    ?assertMatch({ok,DbaseNode},slave:start(HostId,dbase,"-pa dbase/ebin -setcookie abc")),
    ?assertMatch([ok,ok,ok,ok,ok,ok,ok],[rpc:call(DbaseNode,application,set_env,[dbase,Par,Val],5000)||{Par,Val}<-DbaseEnvs]),
    ?assertMatch(ok,rpc:call(DbaseNode,application,start,[dbase],5000)),
    ?assertMatch({pong,DbaseNode,dbase},rpc:call(DbaseNode,dbase,ping,[],1000)), 
    ?assertMatch(ok,single_node(DbaseNode)),
    
    %% Syslog
   % ?assertMatch({atomic,ok},rpc:call(sd:dbase_node(),db_sd,create,[ServiceId,ServiceVsn,AppId,AppVsn,HostId,VmId,VmDir,Vm],2000)),
    ?assertMatch({atomic,ok},rpc:call(sd:dbase_node(),db_sd,create,["syslog","1.0.0",
								   "syslog_100_c2.app_spec","1.0.0",
								    "c2","syslog","log",syslog],2000)),
    
    
    
    ok.



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
-define(Cookie,"abc").

first_node()->
    % Start first part of the cluster on this host
    
    % 1. Check running hosts  
    ssh:start(),
    % 2. Check and update machine status
    StatusMachines=machine:status(all),
    misc_log:msg(log,
		 ["StatusMachines = ",StatusMachines],
		 node(),?MODULE,?LINE),
    ok=machine:update_status(StatusMachines),
    ?assertMatch( [{_,"joq62",_,_,_,running},
		   {_,"joq62",_,_,_,running},
		   {_,"joq62",_,_,_,running}],
		  db_server:read_all()),
    
    % start Syslog on all hosts :-)
    %% Glurk borde parameteriseras
    
    _SyslogsApps=["syslog_100_c1.app_spec","syslog_100_c2.app_spec",
		 "syslog_100_c0.app_spec"],
    StartResult=start_service:start("syslog_100_c0.app_spec"),
    misc_log:msg(log,
		  ["StartResult = ","syslog_100_c0.app_spec",StartResult],
		  node(),?MODULE,?LINE),
    [SyslogNodec0]=db_sd:get("syslog"),
    ?assertMatch({pong,SyslogNodec0,syslog},
		 rpc:call(SyslogNodec0,syslog,ping,[],2000)),
    
    % Start Dbase

    % Start Control


    % Exit 
    % Clone dbases 
    
    
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

single_node(Dbase0)->
    AppSpecs=rpc:call(Dbase0,db_app_spec,read_all,[],2000),
    AppSpecsId=[AppId||{AppId,_AppVsn,_Type,_Host,_VmId,_VmDir,_Cookie,_Services}<-AppSpecs],

    PassWd=rpc:call(Dbase0,db_passwd,read_all,[],2000),
    Servers=rpc:call(Dbase0,db_server,read_all,[],2000),
      
    ?assertMatch(["dbase_100_c2.app_spec","calc_c_100.app_spec",
		  "dbase_100_c0.app_spec","dbase_100_c1.app_spec",
		  "syslog_100_c1.app_spec","calc_a_100.app_spec",
		  "syslog_100_c2.app_spec","syslog_100_c0.app_spec",
		  "calc_b_100.app_spec"],
		 AppSpecsId),

    ?assertMatch([{"joq62","20Qazxsw20"}],
		 PassWd),
    ?assertMatch([{"c2","joq62","festum01","192.168.0.202",22,not_available},
		  {"c1","joq62","festum01","192.168.0.201",22,not_available},
		  {"c0","joq62","festum01","192.168.0.200",22,not_available}],
		 Servers),

    
     ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
setup()->
    
    
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------    

cleanup()->
  
  %  init:stop(),
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
lock_test_1()->
    %% db_lock timeout set to
%
    LockId=test_lock,
    LockTimeOut=3,   %% 3 Seconds
    ?assertMatch({atomic,ok},db_lock:create(LockId,LockTimeOut)),
    
     
    ?assertEqual(true,db_lock:is_open(LockId,LockTimeOut)),
    timer:sleep(1*1000),
    ?assertEqual(false,db_lock:is_open(LockId,LockTimeOut)),
    timer:sleep(3*1000),
    ?assertEqual(true,db_lock:is_open(LockId,LockTimeOut)),

    ?assertMatch({atomic,ok},db_lock:delete(LockId)),
    ok.
