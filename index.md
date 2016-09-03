---
layout: default
title: Matt Rude's Github Projects
---

Here are a few of the plugins for various applications I have published. All plugins are licensed under the GPLv2 so you are welcome to change them as you wish.

If you need support, please leave a comment on the projects page.

You my also view <a href="{{ site.github.owner_url }}">My Repository</a> on [Github.com](http://github.com).

## WordPress Themes

<ul>
{% for repo in site.data.wordpress-themes %}
<li><strong><a href="{{ site.github.url }}/{{ repo.uri }}">{{ repo.name }}</a></strong> - {{ repo.description }} (<a href="{{ site.github.owner_url }}/{{ repo.uri }}">repository</a>)</li>
{% endfor %}
</ul>

## WordPress Plugins

<ul>
{% for repo in site.data.wordpress-plugins %}
<li><strong><a href="{{ site.github.url }}/{{ repo.uri }}">{{ repo.name }}</a></strong> - {{ repo.description }} (<a href="{{ site.github.owner_url }}/{{ repo.uri }}">repository</a>)</li>
{% endfor %}
</ul>

## Other Repositories

<ul>
{% for repo in site.data.other-repos %}
<li><strong><a href="{{ site.github.url }}/{{ repo.uri }}">{{ repo.name }}</a></strong> - {{ repo.description }} (<a href="{{ site.github.owner_url }}/{{ repo.uri }}">repository</a>)</li>
{% endfor %}
</ul>
