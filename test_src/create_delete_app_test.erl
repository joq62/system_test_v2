%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(create_delete_app_test).    
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
%% --------------------------------------------------------------------

%% External exports
-export([start/0]).


-define(CalcC2,"calc_c_100.app_spec").
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

    ?debugMsg("Start create"),
    ?assertEqual(ok,create("calc_c_100.app_spec")),
    ?debugMsg("stop create"),

    ?debugMsg("Start delete"),
    ?assertEqual(ok,delete("calc_c_100.app_spec")),
    ?debugMsg("stop delete"),


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
create(AppSpec)->
    R=deployment:create_application(AppSpec),
    [CalcNode]=sd:get("calc"),
    CalcNode=sd:get_one("calc"),
    ?assertMatch(42,rpc:call(CalcNode,calc,add,[20,22])),
  %  io:format("sd:get(calc)  ~p~n",[sd:get("calc")]),
  %  io:format("sd:get_one(calc)  ~p~n",[sd:get_one("calc")]),
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
delete(AppSpec)->
    R=deployment:delete_application(AppSpec),
    io:format("R  ~p~n",[R]),
    ok.



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------


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
