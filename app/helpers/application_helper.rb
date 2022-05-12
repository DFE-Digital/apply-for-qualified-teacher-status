module ApplicationHelper
  def back_link_url(back = url_for(:back))
    back
  end
end
