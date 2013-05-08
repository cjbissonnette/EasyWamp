# EasyWamp

A simple full implementation of the wamp websocket protocol (http://wamp.ws/)

## Installation

Add this line to your application's Gemfile:

    gem 'easy_wamp'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install easy_wamp

## Usage

I designed the syntax to be close to DRB.  The following will start the wamp server.

    EasyWamp::WampServer.start_service("localhost", 9090, TestApi.new)
    
This will run the server in a thread, then return.  The thread can be accessed with:
    
    EasyWamp::WampServer.thread
    
So to pause execution and run the server just do:

    EasyWamp::WampServer.thread.join
    
Where all WAMP remote procedure calls will be sent to the TestApi class.  To publish an event on the server simply call:

    EasyWamp::WampServer.publish_event("localhost/test/uri, "event_name", [exclusion_list], [inclusion_list])
    
For WAMP message details: http://wamp.ws/spec

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
