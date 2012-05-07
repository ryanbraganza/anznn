module ApplicationHelper

  # set the page title to be used as browser title and h1 at the top of the page
  def title(page_title)
    content_for(:title) { page_title }
  end

  # shorthand for the required asterisk
  def required
    "<span class='required' title='Required'>* Required</span>".html_safe
  end

  # convenience method to render a field on a view screen - saves repeating the div/span etc each time
  def render_field(label, value)
    render_field_content(label, (h value))
  end

  # as above but only render if the value is not empty
  def render_field_if_not_empty(label, value)
    render_field_content(label, (h value)) if value != nil && !value.empty?
  end

  # as above but takes a block for the field value
  def render_field_with_block(label, &block)
    content = with_output_buffer(&block)
    render_field_content(label, content)
  end

  # generate a sorting link for a table of values
  def sortable(column, title = nil)
    title ||= column.humanize
    direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
    css_class = (column == sort_column) ? "sort_link current #{sort_direction}" : "sort_link"
    link_to title, params.merge(sort: column, direction: direction), {class: css_class}
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
