-module(cohttp).
-compile(export_all).

create_worker( Url, Manager ) ->
    spawn(?MODULE, worker, [ Url, Manager ]).


worker( Url, Manager ) ->
    Method = get,
    URL = list_to_binary(Url),
    Headers = [],
    Payload = <<>>,
    Options = [],
    {Flag, StatusCode, _, _} = hackney:request(Method, URL, Headers, Payload, Options),
    case Flag of
        ok ->
            ok;
        error ->
            error
    end,
    Manager ! [ Url, StatusCode ]. % Manager にメッセージ送信

create_manager() ->
    spawn(?MODULE, manager, []).

manager() ->
    receive
        % 受信したメッセージをパターンマッチ
        [ Url, Status ] -> io:format("~s is ~w~n", [ Url, Status ]),
            manager() % loop
    end.

main( UrlList ) ->
    application:ensure_all_started(hackney),
    Manager = create_manager(),
    [ create_worker( Url, Manager ) || Url <- UrlList ].
