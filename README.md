# mocha-server

<code>mocha-server</code> mounts code and
[mocha][mocha] tests so they can be run in browser, and can even run
them headlessly with [mocha-phamtomjs][mocha-phantomjs] so they can  be part of your build
process.

## Installation

```sh
npm install mocha-server
```

## Usage

In its simplest form, you run <code>mocha-server</code> from the
command-line:

```sh

$ mocha-server

```

This will launch a server that can be accessed at http://localhost:8888
; open it with a browser to run the mounted tests.

The following flags can also be used:

```sh

  Usage: mocha-server [options] [test files...]

  Options:

    -h, --help             output usage information
    -V, --version          output the version number
    -r, --require <name>   require the given module
    -R, --reporter <name>  specify the reporter to use
    -u, --ui <name>        specify user-interface (bdd|tdd|exports)
    -b, --bail             bail after first test failure
    -h, --headless         run headless with phantomjs
    -c, --compiler <name>  pass in [ext]:[path to compiler]
    --ignore-leaks         ignore global variable leaks
    --recursive            include sub directories

```

By default, tests are pulled in from the <code>test</code> directory.

### Load Order

As dependencies can be very important in running Javascripts code and tests,
<code>mocha-server</code> provides two mechanisms for ensuring the load
order.

#### <code>--require</code>

First, the <code>--require</code> or <code>-r</code> flags can be used
repeatedly to identify files that should be loaded first. For example:

```sh
$ mocha-server -r ./test/test-helper.js ./test/my-tests
```

Will load <code>./test/test-helper.js</code> before it loads any of the
tests found uncer <code>./test/my-tests</code>.

#### Sprocket-style <code>require</code>

Alternatively, you can use [sprockets][sprockets] style
<code>require</code> directives to indicate depdencies. This
functionality is supplied by [snockets][snockets].

#### Adding Additional Javascript Compilers

Out of the box, <code>mocha-server</code> supports Javascript and
[coffeescript][coffeescript] files, through [snokets][snockets]. You can
pass in additional compilers through the <code>--compiler</code flag as
follows:

```sh
$ mocha-server --compiler jade:./test/compilers/jade.js
```

Will compile all files with the <code>.jade</code> extension using the
compiler defined in <code>./test/compilers/jade.js</code>.

A compiler is made up of a <code>match</code> property that is
regular-expression that indicates the files type returned and a
<code>compileSync</code> function that will return the source generated.

Look under the <code>spec/support</code> for an example compiler.

### <code>mocha-server.opts</code>

Much like [mocha][mocha] will attempt to load
<code>./test/mocha.opts</code>, <code>mocha-server</code> will attempt
to load <code>./test/mocha-server.opts</code>, concatenating the
arguments to those passed on the command line. For example, suppose you
have the following:

```sh

--require ./test/support
-h
test/assets

```

It will ensure the contents of <code>test/support</code> is loaded
first, that the tests are run headlessly, and that all the tests in
<code>test/assets</code> are run.

### Running Headlessly

<code>mocha-server</code> uses [mocha-phantomjs][mocha-phantomjs] to run
headlessly. You need to install [PhantomJS v.1.7.0][phantomjs] or
greater and then you can enter:

```sh
$ mocha-server --headless
```

Or:

```sh
$ mocha-server -h
```

This launches the server, then runs <code>mocha-phantomjs</code>
against it. Several command-line arguments are passed through to it.

## Examples

The files under <code>test</code> folder provide examples of writing
tests for the system. You can run them by:

```sh
$ mocha-server
```

## Testing

You can test <code>mocha-server</code> by cloning this repository and
running:

```sh
$ cake test
```

This will run the tests under the <code>spec</code> folder.

## Contributing

Fork the repo, make your changes, and submit a pull-request!

## Contributors

* [Rudy Jahchan][rudy-jahchan]
* [Hugo Melo][squanto]
* [Andy Peterson][ndp]

  [ndp]: http://github.com/ndp
  [squanto]: http://github.com/squanto
  [rudy-jahchan]: http://github.com/rudyjahchan
  [mocha-server]: http://github.com/carbonfive/mocha-server
  [mocha]: http://visionmedia.github.com/mocha/
  [mocha-phantomjs]: https://github.com/metaskills/mocha-phantomjs
  [phantomjs]: http://phantomjs.org/
  [sprockets]: https://github.com/sstephenson/sprockets
  [snockets]: https://github.com/TrevorBurnham/snockets
  [coffeescript]: http://coffeescript.org/
