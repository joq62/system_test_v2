%% This is the application resource file (.app file) for the 'base'
%% application.
{application,syslog,
[{description, "syslog " },
{vsn, "1.0.0" },
{modules, 
	  [syslog_app,syslog_sup,syslog,common]},
{registered,[syslog]},
{applications, [kernel,stdlib]},
{mod, {syslog_app,[]}},
{start_phases, []}
]}.
