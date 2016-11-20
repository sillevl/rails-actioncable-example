class Message < ApplicationRecord
    after_save :broadcast
    
    def broadcast
        ActionCable.server.broadcast "message", data: message
    end
end
