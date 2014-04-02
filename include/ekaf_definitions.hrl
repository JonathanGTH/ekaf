%%======================================================================
%% Constants
%%======================================================================
-define(API_VERSION, 0).
-define(PRODUCE_REQUEST, 0).
-define(METADATA_REQUEST, 3).

%%======================================================================
%% Macros
%%======================================================================
-define(INFO_MSG(Format, Args),
    case application:get_env(kafboy,enable_logging) of
         {ok,true} ->
            lager:info
              ("~p:~p ~p:"++Format, [?MODULE, ?LINE, self()]++Args);
        _ ->
            io:format
          ("~n~p:~p ~p:"++Format, [?MODULE, ?LINE, self()]++Args)
    end
       ).

-define(ERROR_MSG(Format, Args),
        case application:get_env(kafboy,enable_logging) of
            {ok,true} ->
                lager:error("~p:~p "++Format++"~n~p", [?MODULE, ?LINE]++Args++[erlang:get_stacktrace()]);
        _ ->
                io:format("~n{~p:~p ~p}:"++Format++"~n~p", [?MODULE, ?LINE, self()]++Args++[erlang:get_stacktrace()])
    end
       ).

-define(DEBUG_MSG(Format, Args),
        case application:get_env(kafboy,enable_logging) of
            {ok,true} ->
                lager:debug(Format,Args);
            _ ->
                ok
        end
       ).

%%======================================================================
%% Specs
%%======================================================================
-define(record_to_list(Rec, Ref), lists:zip(record_info(fields, Rec),tl(tuple_to_list(Ref)))).
-define(BITMASK_REQUIRE_ACK,1).
-type kafka_api_key() :: 0..7.
-type kafka_correlation_id() :: -2147483648..2147483647.
-type kafka_byte() :: <<_:8>>.
-type kafka_word() :: <<_:16>>.
-type kafka_bytes() :: <<_:32, _:_*8>>.
-type kafka_string() :: <<_:16, _:_*8>>.
-type kafka_array() :: <<_:32, _:_*8>>.
-type kafka_request() :: <<_:64, _:_*8>>.
-type kafka_message() :: {iodata(), iodata()} | {iodata(), iodata(), 0..2}.

%%======================================================================
%% Records
%%======================================================================

%% Requests
-record(produce_request, { required_acks=0::kafka_word(), timeout=0::integer(), topics = []::list()}).

%% Responses
-record(produce_response, { cor_id::kafka_word(), timeout=0::integer(), topics = []::list()}).
-record(metadata_response, { cor_id = 0 :: kafka_correlation_id(), brokers = [], topics = [] }).

%% Other Records
-record(broker, {node_id = 1 :: integer(), host = <<"localhost">> :: binary(), port = 9091 :: integer()}).
-record(topic, {name:: binary(), error_code = 0:: integer(), partitions = []}).
-record(partition, {id=0::integer(), error_code=0:: integer(), leader=0:: integer(), replicas = []::list(), isrs = []::list(), message_sets_size=0::integer(), message_sets=[]::list()}).
-record(message_set, {offset=0::integer(), size=0::integer(), messages=[]::list()}).
-record(message, {crc=0::integer(), magicbyte=0::kafka_byte(), attributes=0::kafka_byte(), key = undefined::binary(), value::binary()}).
-record(isr, {id::integer() }).
-record(replica, {id::integer() }).