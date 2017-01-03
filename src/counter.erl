-module(counter).
-export([
  init/0,
  init/1,
  populate/1
]).
-include("../headers/general.hrl").

init() ->
  init(#counter{}).
init(Counter) ->
  spawn(fun () -> start(Counter) end).

start(Counter) ->
  ?DBG("[~p] Counter START, PID: ~p\n",[Counter#counter.ref,self()]),
  next(Counter),
  ok.

loop(Counter) ->
  receive
    {From, Ref, get, client_quest} ->
      ?DBG("[~p] Counter loop receive\n",[Counter#counter.ref]),
      case undefined == Counter#counter.client of
        false ->
          From ! {Ref, {quest ,Counter#counter.client#client.quest}};
        _ ->
          From ! {Ref, {quest ,none}}
      end,
      next(Counter),
      ok;
    Other ->
      ?DBG("[~p] Counter loop receive Other: ~p\n",[Counter#counter.ref,Other]),
      next(Counter),
      ok
  after 0 ->
    next(Counter)
  end.

next(Counter) ->
  Now = os:system_time(millisecond),
  Dt = Now - Counter#counter.busy_until,
  ?DBG("[~p]\tCounter busy until ~p ~p\n",[Counter#counter.ref,Counter#counter.busy_until,Counter#counter.client#client.quest]),
  ?DBG("[~p] Counter Dt = ~p\n",[Counter#counter.ref,Dt]),
  case Dt > 0 of
    true ->
      ?DBG("[~p] Counter next -> true\n",[Counter#counter.ref]),
      case gen_server:call(?QUEUE, next) of
        {error, queue_empty} ->
          loop(Counter#counter{client=undefined});
        {error, _} ->
          loop(Counter);
        {client, Client} ->
          BusyUntil = Now+quest_duration(Client,Counter),
          loop(Counter#counter{client=Client,busy_until=BusyUntil});
        Other ->
          ?DBG("[~p] Counter queue call Other: ~p\n",[Counter#counter.ref,Other])
      end;
    _ ->
      ?DBG("[~p] Counter next -> false\n",[Counter#counter.ref]),
      loop(Counter)
  end.

quest_duration(Client,Counter) ->
  QuestTime = maps:get(Client#client.quest, ?DURATIONS, 0),
  QuestTime / Client#client.efficiency / Counter#counter.efficiency.

% Populating
populate(NumberOfCounters) when is_integer(NumberOfCounters)->
  lists:map(fun (_) -> init() end, lists:seq(1,NumberOfCounters));
populate(Counters) when is_list(Counters) ->
  lists:map(fun (Counter) -> counter:init(Counter) end, Counters).

