#= require support/load_env
#= require helpers/spy

#= require application

#= require support/sinon
#= require support/sinon-chai

#= require_tree ./templates


mocha.ui('bdd')                      # set the Mocha test interface
# mocha.globals(['YUI']);            # ignore the following globals during leak detection
# mocha.ignoreLeaks();               # or, ignore all leaks
# mocha.timeout(5);                  # set slow test timeout in ms

chai.Assertion.includeStack = true;  # Show stack trace on failing assertion.
