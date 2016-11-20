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
    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:message)
    end
end
