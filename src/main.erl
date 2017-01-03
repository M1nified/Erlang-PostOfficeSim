-module(main).
-export([
  start/0,
  start/2
]).
-include("../headers/general.hrl").

start() ->
  start(?CLIENTS_NUM,?COUNTERS_NUM).
start(ArgClients,ArgCounters) ->
  gen_server:start_link({local, ?QUEUE}, ?QUEUE, ArgClients, [{debug,[log]}]),
  Counters = counter:populate(ArgCounters),
  io:fwrite("After counters population: ~p\n",[Counters]),
  display_run(Counters),
  ok.

display_run(Counters) ->
  Refs = lists:map(fun get_quest/1, Counters),
  CurrentQuests = display_receive(Refs,Refs),
  PendingQuests = gen_server:call(?QUEUE,length),
  io:fwrite("\nPending count: ~p\n",[PendingQuests]),
  io:fwrite("Quests: ~p\n\n",[CurrentQuests]),
  timer:sleep(100),
  display_run(Counters).


display_receive([],Quests) ->
  Quests;
display_receive(Refs, Quests) ->
  % io:fwrite("Refs: ~p\n",[Refs]),
  receive
    {Ref, {quest, Quest}} ->
      % io:fwrite("Quest ~p\n",[Quest]),
      display_receive(lists:filter(fun(R) -> R /= Ref end,Refs),lists:map(fun(Q) -> case Q == Ref of true -> Quest; _ -> Q end end ,Quests));
    Other ->
      io:fwrite("Other ~p\n",[Other])
  end.


get_quest(Counter) ->
  ?DBG("get_quest: ~p\n",[Counter]),
  Ref = make_ref(),
  Counter ! {self(), Ref, get, client_quest},
  Ref.