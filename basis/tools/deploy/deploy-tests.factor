IN: tools.deploy.tests
USING: tools.test system io.files kernel tools.deploy.config
tools.deploy.config.editor tools.deploy.backend math sequences
io.launcher arrays namespaces continuations layouts accessors
io.encodings.ascii urls math.parser ;

: shake-and-bake ( vocab -- )
    [ "test.image" temp-file delete-file ] ignore-errors
    "resource:" [
        [ vm "test.image" temp-file ] dip
        dup deploy-config make-deploy-image
    ] with-directory ;

: small-enough? ( n -- ? )
    [ "test.image" temp-file file-info size>> ] [ cell 4 / * ] bi* <= ;

[ t ] [ "hello-world" shake-and-bake 500000 small-enough? ] unit-test

[ t ] [ "sudoku" shake-and-bake 800000 small-enough? ] unit-test

[ t ] [ "hello-ui" shake-and-bake 1300000 small-enough? ] unit-test

[ "staging.math-compiler-threads-ui-strip.image" ] [
    "hello-ui" deploy-config
    [ bootstrap-profile staging-image-name file-name ] bind
] unit-test

[ t ] [ "maze" shake-and-bake 1200000 small-enough? ] unit-test

[ t ] [ "tetris" shake-and-bake 1500000 small-enough? ] unit-test

[ t ] [ "bunny" shake-and-bake 2500000 small-enough? ] unit-test

os macosx? [
    [ t ] [ "webkit-demo" shake-and-bake 500000 small-enough? ] unit-test
] when

: run-temp-image ( -- )
    vm
    "-i=" "test.image" temp-file append
    2array try-process ;

{
    "tools.deploy.test.1"
    "tools.deploy.test.2"
    "tools.deploy.test.3"
    "tools.deploy.test.4"
} [
    [ ] swap [
        shake-and-bake
        run-temp-image
    ] curry unit-test
] each

USING: http.client http.server http.server.dispatchers
http.server.responses http.server.static io.servers.connection ;

SINGLETON: quit-responder

M: quit-responder call-responder*
    2drop stop-this-server "Goodbye" "text/html" <content> ;

: add-quot-responder ( responder -- responder )
    quit-responder "quit" add-responder ;

: test-httpd ( responder -- )
    [
        main-responder set
        <http-server>
            0 >>insecure
            f >>secure
        dup start-server*
        sockets>> first addr>> port>>
        dup number>string "resource:temp/port-number" ascii set-file-contents
    ] with-scope
    "port" set ;

[ ] [
    <dispatcher>
        add-quot-responder
        "resource:basis/http/test" <static> >>default

    test-httpd
] unit-test

[ ] [
    "tools.deploy.test.5" shake-and-bake
    run-temp-image
] unit-test

: add-port ( url -- url' )
    >url clone "port" get >>port ;

[ ] [ "http://localhost/quit" add-port http-get 2drop ] unit-test

[ ] [
    "tools.deploy.test.6" shake-and-bake
    run-temp-image
] unit-test

[ ] [
    "tools.deploy.test.7" shake-and-bake
    run-temp-image
] unit-test

[ ] [
    "tools.deploy.test.8" shake-and-bake
    run-temp-image
] unit-test

[ ] [
    "tools.deploy.test.9" shake-and-bake
    run-temp-image
] unit-test
