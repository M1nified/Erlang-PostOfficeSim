-module(queue_static).
-behaviour(gen_server).
-export([
  init/0,
  init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3
]).
-include("../headers/general.hrl").

init() ->
  init(rand:uniform(10000)).
init(NumberOfClients) when is_integer(NumberOfClients) ->
  init([#client{quest = case rand:uniform(2) of 1 -> get; _ -> send end} || _ <- lists:seq(1,NumberOfClients)]);
init(Clients) when is_list(Clients) ->
  ?DBG("[queue_static] init, Clients = ~p\n",[Clients]),
  {ok,Clients}.

handle_call(next,_From,State) ->
  {Next,NewState} = shift(State),
  ?DBG("[queue_static] handle_call, Next = ~p\n",[Next]),
  case Next of
    {error, queue_empty} ->
      {reply, Next, NewState};
    _ ->
      {reply, {client, Next}, NewState}
  end;
handle_call(length,_From,State) ->
  {reply, lists:flatlength(State),State};
handle_call(_Request,_From,State) ->
  {reply, {error, no_match} ,State}.

shift([]) ->
  {{error, queue_empty},[]};
shift([Last]) ->
  {Last,[]};
shift([Head|Tail]) ->
  {Head,Tail}.

% Unused
terminate(_,_) ->
  ok.
handle_cast(_,_) ->
  ok.
handle_info(_,_) ->
  ok.
code_change(_,_,_) ->
  ok.
