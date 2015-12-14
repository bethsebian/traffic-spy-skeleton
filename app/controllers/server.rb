module TrafficSpy
  class Server < Sinatra::Base
    helpers do
      def pluralize_times(n)
        if n == 1
          "time"
        else
          "times"
        end
      end
    end

    get '/' do
      erb :index
    end

    post '/sources' do
      registrator = Registrator.new(params)
      status registrator.status
      body   registrator.response
    end

    post '/sources/:id/data' do |id|
      registrator = RequestManager.new(params)
      status registrator.status
      body   registrator.response
    end

    get '/sources/:id' do |id|
      @app = Application.find_by(identifier: id)

      if @app.nil?
        erb :error, locals: {message: "Application not registered", link: ""}
      elsif @app.requests.empty?
        erb :error, locals: {message: "No documented requests", link: ""}
      else
        erb :urls
      end
    end

    get '/sources/:id/urls/*' do | id, splat |
      application = Application.find_by(identifier: id)
      if @url_ = application.urls.find_by(path: splat)
        erb :url
      else
        erb :error, locals: {message: "No documented requests", link: ""}
      end
    end

    get '/sources/:id/events' do |id|
      @application = Application.find_by(identifier: id)

      if @application.events.count == 0
        erb :error, locals: {message: "No events have been defined", link: ""}
      else
        erb :events
      end
    end

    get '/sources/:id/events/:event_name' do |id, event_name|
      @app = Application.find_by(identifier: id)
      @event = Event.find_by(name: event_name)

      if @event.nil?
        erb :error, locals: { message: "Event not defined",
                              link: "<a href='/sources/#{id}/events'>
                              View #{id.capitalize} Events</a>"}
      else
        @event_total = @event.total_requests(@app.id)
        @hour_breakdown = @event.sorted_list_by_hour(@app.id)
        erb :event
      end
    end

    not_found do
      erb :error, locals: {message: "Oops! We don't know what you mean", link: ""}
    end
  end
end
