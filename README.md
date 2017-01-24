# chiscore

_Timekeeping and Scoring application for the CHIditarod._

## Requirements

- Redis
- Ruby & Sinatra
- Node.js

## Architecture

Chiscore consists of client and server component.

## Developer Setup

_Assumes you are using OSX. Pull requests for other setups gladly accepted._

#### Setup Daemons and Environment

- Install [homebrew](http://brew.sh/).
- [Install rbenv](https://github.com/rbenv/rbenv#homebrew-on-mac-os-x) using homebrew.
- Install prequisites and clone the code:

```bash
brew install ruby-build
rbenv install 2.3.1
brew install redis
git clone github.com:chiditarod/chiscore
cd chiscore
```

#### Server

```bash
gem install bundler
bundle install
bundle exec rake gen_secrets # generate secret keys
```

#### Client

You need node.js for compilation and running of JavaScript specs

```bash
brew install node
npm install -g grunt-cli # the grunt-cli may require sudo.
npm install
```

## Usage Examples

#### Server

Start redis:

    redis-server
    
Start the server:

    bundle exec rackup # or `unicorn` if you're into that 

Run the ruby unit test suite:

    bundle exec rake

#### Client

Run the JavaScript spec suite:

    grunt spec

Compile coffee and EJS templates:

    grunt build

Watch and compile coffee and EJS templates:

    grunt watch

Remove compiled JS targets:

    grunt clean

#### Development Login

- use `test-checkpoint` / `secret`
- use a number between 1 and 160 to check in a team
