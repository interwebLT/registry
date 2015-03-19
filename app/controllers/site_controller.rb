class SiteController < ApplicationController
  def sha
    render text: File.read('REVISION')
  end
end
