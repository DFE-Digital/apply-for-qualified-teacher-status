module BackLinkHelper
  def back_link_url(back = url_for(:back))
    params[:next].presence || back
  end
end
