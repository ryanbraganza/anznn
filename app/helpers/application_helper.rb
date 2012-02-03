module ApplicationHelper
  def title(page_title)
    content_for(:title) { page_title }
  end

  #shorthand for the required asterisk
  def required
    "<span class='required' title='Required'>* Required</span>".html_safe
  end

  #when the stylesheets are updated, this will be the class to use
  #def required
  #  "<a class='asterisk_icon' title='Required'></a>".html_safe
  #end

  # convenience method to render a field on a view screen - saves repeating the div/span etc each time
  def render_field(label, value)
    render_field_content(label, (h value))
  end

  def render_field_if_not_empty(label, value)
    render_field_content(label, (h value)) if value != nil && !value.empty?
  end

  # as above but takes a block for the field value
  def render_field_with_block(label, &block)
    content = with_output_buffer(&block)
    render_field_content(label, content)
  end

  private
  def render_field_content(label, content)
    div_id = label.tr(" ,", "_").downcase
    html = "<div class='detail-item inlineblock' id='display_#{div_id}'>"
    html << '<strong>'
    html << (h label)
    html << ": "
    html << '</strong>'
    html << content
    html << '</div>'
    html.html_safe
  end


end
