-define(DEBUG, false).
-define(DBG(Str, Arr), case ?DEBUG of true -> (io:fwrite(lists:flatten(io_lib:format(Str,Arr)))); _ -> (null) end).
-define(COUT(Str, Arr), io:fwrite(lists:flatten(io_lib:format(Str,Arr)))).


-define(QUEUE, queue_static).
-define(COUNTERS_NUM, 10).
-define(CLIENTS_NUM, 100).

-define(DURATIONS, #{ % milliseconds
  get => 1000,
  send => 3000
}).

-type quest() :: get | send.

-record(client,{
  efficiency = 1 :: number(),
  quest = get :: quest()
}).
-type client() :: #client{}.

-record(counter,{
  efficiency = 1 :: number(),
  client = #client{} :: client(),
  busy_until = 0 :: integer(),
  ref = make_ref() :: reference()
}).
-type counter() :: #counter{}.
