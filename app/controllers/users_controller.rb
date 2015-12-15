class UsersController < ApplicationController
  def create 

    u = User.new
    u.email = params[:email]             
    u.name = params[:name]              
    u.password = params[:password]
    u.username = params[:username]          
    u.registered_at = Time.now
    u.partner = Partner.find params[:partner_id]

    if u.save
        render json: u
    elsif u.errors.added? :email, "already_exists"
        render validation_failed u
    else
        render bad_request
    end
  end
end
