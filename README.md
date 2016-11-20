# ActionCable example

In this example ActionCable is used to notify other users of new messages that are added to the application.
More information about ActionCable can be found in the [Rails Documentation](http://edgeguides.rubyonrails.org/action_cable_overview.html).

## Prerequisites

In this example we start from an new Rails project. You can create a project just by running the `rails new my-actioncable-app` command.
A `Message` model is used to store and retrieve messages. The model can be created with the `rails generate model Message message:string` command.
Next there must be a page where people can view the messages and post a new message. A `home` controller is provided with an `index` and `message` action.
The controller can be created with the `rails generate controller home index message` command. The `home` action fetches all the messages from the database and prepares a new message for the form.

```ruby
class HomeController < ApplicationController
  def index
      @message = Message.new
      @messages = Message.all.reverse
  end

  def message
      @message = Message.create(message_params)
      redirect_to root_path
  end

  private
    def message_params
      params.require(:message).permit(:message)
    end
end
```

The `root` route points at the index action of the home controller. A route for the message post is also defined.

```ruby
Rails.application.routes.draw do
  root 'home#index'
  post 'message' => 'home#message', as: 'message'
end
```

The webpage will show a list of previous messages with an input field and submit button on the top. This functionality is defined in the index view.

```html
<h1>Rails ActionCable example</h1>

<%= form_for(@message, url: {action: "message"}) do |f| %>
    <%= f.label :message %><br />
    <%= f.text_field :message %>
    <%= f.submit %>
<% end %>

<ul id="messages">
    <% @messages.each do |message| %>
    <li><%= message.message %></li>
    <% end %>
</ul>

```

## Adding an ActionCable Channel to your project

You can simply add a ActionCable channel to your application by using the _channel generator_. In this example our channel is called `message`.

```bash
rails generate channel message
```

The generator will create some file for you. A `message_channel.rb` file in the `app/channels/` directory. In this file the server-side behavior is defined. A `message.coffee` file is created in the `app/assets/javascripts/channels/` directory. In this file the client-side behavior is defined.

```bash
create  app/channels/message_channel.rb
identical  app/assets/javascripts/cable.js
create  app/assets/javascripts/channels/message.coffee
```

## Seting up the channel

Generated `app/channels/message_channel.rb` file:
```Ruby
# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class MessageChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_from "message"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
```

In the `app/channels/message_channel.rb` file we need to create a new channel when a subscription request is received. We can do this by adding `stream_from "message"` to the `subscribed` method.

```Ruby
  def subscribed
    # stream_from "some_channel"
    stream_from "message"
  end
```

On the server-side everything is ready now for streaming updates on the `message` channel.

## Broadcasting new updates

We can now use the channel to broadcast data to all the subscribed clients. This can be done with the `broadcast` method of the `ActionCable.server` object. We need to specify the channel (`message` in our case), and the data that needs to be broadcasted.

```ruby
ActionCable.server.broadcast "message", data: message
```

The best place to call this method in our example is in the `Message` model. There we can specify code that needs to be executed when a new message is saved.
This can be done by specifying the method to be calles with `after_save`.

The Model (`app/models/message.rb`) code will look like this:

```ruby
class Message < ApplicationRecord
    after_save :broadcast

    def broadcast
        ActionCable.server.broadcast "message", data: message
    end
end
```

## Receiving the updates

The updetes are received on the client-side in JavaScript. Rails provided an CoffeeScript file (`app/assets/javascripts/channels/message.coffee`) where we can specify the behavior in the `received` function

````coffee
App.message = App.cable.subscriptions.create "MessageChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    $("#messages").prepend("<li>" + data.message + "</li>")
```

This is all we need :)

## Remarks

At the moment, the page is refreshed after sending a new message with the HTML form. It would be better to implement this with an AJAX request...
