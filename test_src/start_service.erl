%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(start_service).   
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
%% --------------------------------------------------------------------

%% External exports
-export([start/1]).



%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
-define(Cookie,"abc").

start(AppSpec)->
    [AppInfo]=db_app_spec:read(AppSpec),
     misc_log:msg(log,
		  ["AppInfo = ",AppInfo],
		  node(),?MODULE,?LINE),

    {_AppSpecId,_AppVsn,_Type,Directives,EnvVars,Services}=AppInfo,
    {host,HostId}=lists:keyfind(host,1,Directives),
    {vm_id,VmId}=lists:keyfind(vm_id,1,Directives),
    {vm_dir,VmDir}=lists:keyfind(vm_dir,1,Directives),
    
    Node=list_to_atom(VmId++"@"++HostId),
    Result = case vm:create(HostId,VmId,VmDir,?Cookie) of
		 {ok,Node}->
		     %% Start Applications
		     misc_log:msg(log,
				  ["Node started  = ",Node],
				  node(),?MODULE,?LINE),

		     [rpc:call(Node,application,set_env,[Application,Par,Val],2000)||{Application,Par,Val}<-EnvVars],
		     CreateResult=[service:create(ServiceSpecId,VmDir,Node)||ServiceSpecId<-Services],
		     CreateResult;
		 Err ->
		     misc_log:msg(log,
				  ["{error,[Err,?MODULE,?LINE]}  = ",Err],
				  node(),?MODULE,?LINE),
		     {error,[Err,?MODULE,?LINE]}
	     end,
    Result.
