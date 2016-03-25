chiscore-two
============

Scoring app for Chiditarod 2013 (and possibly beyond)

You need redis.

`brew install redis` and follow those instructions

You need bundle, and it needs to install some gems!

`gem install bundler && bundle `

You need node.js for compilation and running of JavaScript specs

`brew install node` if you don't has it,
then `npm install -g grunt-cli` -- the grunt-cli may require sudo.

Then, from the root `chiscore-two` directory, `npm install`

## Server Stuff
Start the server:
    `rackup` (or `unicorn` if you're into that)

Run the ruby unit test suite:
    `rake`

## Client Stuff
Run the JavaScript spec suite:
    `grunt spec`

Compile coffee and EJS templates:
    `grunt build`

Watch and compile coffee and EJS templates:
    `grunt watch`

Remove compiled JS targets:
    `grunt clean`

Logging in: dev environment
- use test-checkpoint / secret
- use a number between 1 and 160 to check in a team
