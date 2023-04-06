module StatusHelper
  def status_text(status, context: :teacher)
    key_with_context = "components.status_tag.#{status}.#{context}"
    key_without_context = "components.status_tag.#{status}"
    I18n.t(key_with_context, default: I18n.t(key_without_context))
  end
end
