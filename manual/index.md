---
layout: page
title: ANZNN User Manual
---
{% include JB/setup %}

<a href="full.html" class="btn pull-right">Printable Version</a>

{% for category in site.categories %}
  <h2 id="{{ category[0] }}-ref">{{ category[0] | join: "/" }}</h2>
  <ul>
    {% assign pages_list = (category[1]) %}
    {% include JB/pages_list %}
  </ul>
{% endfor %}

