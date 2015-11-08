Readme
======

This is a customized gitit application I use for my web site.

For the moment, the main distinction is that I compile my plugins as part
of the server instead of using the dynamic plugin load provided by default
which is not very robust (does not currently work on nix/nixos) and oftentime
result in performances issues. With this method, everything is pretty fast
and I get no dynamic load issues. 

This repository depends on *jrg-gitit-plugins* which holds the custom
plugins I use. This dependency is assumed to live alongside the current
repository.


How to develop
--------------

In order to test the wiki:

~~~
nix-shell
cabal configure
cabal build
cabal run -- -f test.conf
~~~


Whenever a change to the `*.cabal` file occur (most likely only in
dependencies), you need to run the following command:

~~~
cabal2nix . > ./default.nix
~~~

