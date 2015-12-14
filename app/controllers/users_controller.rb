class UsersController < ApplicationController
  def create 

    u = User.new
    u.email = params[:email]             
    u.name = params[:name]              
    u.password = params[:password]
    u.username = params[:username]          
    u.registered_at = Time.now
    u.partner = Partner.find params[:partner_id]

    u.save
    render json: u
  end
end
