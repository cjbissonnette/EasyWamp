module EasyWamp
  class WampServer
    
    PROTOCOL_VERSION = 1
    TYPE_ID_WELCOME = 0
    TYPE_ID_PREFIX = 1
    TYPE_ID_CALL = 2
    TYPE_ID_CALLRESULT = 3
    TYPE_ID_CALLERROR = 4
    TYPE_ID_SUBSCRIBE = 5
    TYPE_ID_UNSUBSCRIBE = 6
    TYPE_ID_PUBLISH = 7
    TYPE_ID_EVENT = 8
    
    @@prefix = {}
    @@events = {}
    @@clients = {}
    @@thread = nil
    @@call_back = {}
    
    def self.thread()
      return @@thread
    end
    
    def self.register_callback(callback, &block)
      @@call_back[callback] = block
    end
    
    def self.call_callback(action, *args)
      @@call_back[action].call(*args) if @@call_back[action]
    end
    
    def self.expand(curi)
      @@prefix[curi.split(':')[0]] || curi
    end
    
    def self.get_api_call(uri)
      uri = expand(uri)
      uri.include?('#') ? uri.split('#')[1] : uri
    end
    
    def self.subscribe(uri, client)
      uri = expand(uri)
      @@events[uri] ||= Set.new
      @@events[uri].add(client)
      call_callback(:on_subscribe, uri)
    end
    
    def self.unsubscribe(uri, client)
      uri = expand(uri)
      @@events[uri] ||= Set.new
      @@events[uri].delete(client)
    end
    
    def self.session_id
      SecureRandom.uuid
    end
    
    def self.register_new_client(ws, id)
      @@clients[ws] = id
    end
    
    def self.remove_client(ws)
      @@clients.delete(ws)
    end
    
    def self.get_client_id(ws)
      @@clients[ws]
    end
    
    def self.get_client_ws(id)
      @@clients.key(id)
    end
    
    def self.add_prefix(prefix, value)
      @@prefix[prefix] = value
    end
    
    def self.each_registered(uri, bad, good)
      @@events[uri].each do |e|
        yield(get_client_ws(e)) if get_client_ws(e) && 
                                   !bad.include?(e) && 
                                   (good == nil || good.empty? || good.include?(e))
      end if(@@events[uri])
    end
    
    def self.send_msg(ws, msg)
      ws.send(msg.to_json)
    end
    
    def self.send_welcome(ws, id)
      send_msg(ws, [TYPE_ID_WELCOME,
                    id,
                    PROTOCOL_VERSION,
                    "EasyWampServer/#{EasyWamp::VERSION}"])
    end
    
    def self.send_error(ws, id, type, desc, details)
      send_msg(ws, [TYPE_ID_CALLERROR,
                    id,
                    "#{@host}/error##{type}",
                    desc,
                    details])
    end
    
    def self.send_result(ws, id, result)
      send_msg(ws, [TYPE_ID_CALLRESULT, id, result])
    end
    
    def self.send_event(ws, uri, event)
      send_msg(ws, [TYPE_ID_EVENT, uri, event])
    end
    
    def self.publish_event(uri, event, ex_list=[], inc_list=[])
      uri = expand(uri)
      each_registered(uri, ex_list, inc_list) do |ws|
        send_event(ws, uri, event)
      end
    end
    
    def self.handle_open(ws)
      id = session_id()
      register_new_client(ws, id)
      send_welcome(ws, id)
      call_callback(:on_open)
    end
    
    def self.handle_close(ws)
      remove_client(ws)
      call_callback(:on_close)
    end
    
    def self.handle_msg(ws, msg)
      client_id = get_client_id(ws)
      msg = JSON.parse(msg)
      case msg[0]
        when TYPE_ID_PREFIX
          add_prefix(msg[1], msg[2])
        when TYPE_ID_CALL
          begin
            send_result(ws, msg[1], @@api.send(get_api_call(msg[2]), *msg[3..-1]))
          rescue Exception => e
            send_error(ws, msg[1], e.class.name, e.to_s, e.backtrace.join("\n"))
          end
        when TYPE_ID_SUBSCRIBE
          subscribe(msg[1], client_id)
        when TYPE_ID_UNSUBSCRIBE
          unsubscribe(msg[1], client_id)
        when TYPE_ID_PUBLISH
          publish_event(*msg[1..-1])
      end
    end
    
    def self.start_service(host, port, api)
      @@api = api
      @@host = host
      @@port = port
      
      @@thread = Thread.new do
        EM.run do
          WebSocket::EventMachine::Server.start(:host => host, :port => port) do |ws|         
            ws.onopen do
              handle_open(ws)
            end
            ws.onmessage do |msg, type|
              begin
                handle_msg(ws, msg)
              rescue Exception => e
                puts "Error Handling Message: #{e.to_s}"
              end
            end
            ws.onclose do
              handle_close(ws)
            end
          end
        end
      end
    end
  end
end