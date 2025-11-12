# frozen_string_literal: true

require 'fileutils'

module OriginalMarkdownPublisher
  def self.generate_llms_txt(site)
    posts_by_lang = site.posts.docs.group_by { |post| post.data['lang'] || 'en' }

    content = []
    content << "# Forketyfork Dev Blog"
    content << ""
    content << "> A retro-styled developer blog exploring software engineering, AI tools, productivity, and modern development practices."
    content << ""
    content << "This site publishes articles in multiple languages (English, German, Russian) covering topics including:"
    content << "- Software development tools and techniques"
    content << "- AI and LLM applications"
    content << "- Developer productivity and workflows"
    content << "- Command-line utilities and shell customization"
    content << ""
    content << "All articles are available in their original Markdown format for easy consumption by LLMs and other tools."
    content << ""

    posts_by_lang.keys.sort.each do |lang|
      lang_name = case lang
                  when 'en' then 'English Articles'
                  when 'de' then 'German Articles (Deutsch)'
                  when 'ru' then 'Russian Articles (Русский)'
                  else "#{lang.upcase} Articles"
                  end

      content << "## #{lang_name}"
      content << ""

      posts = posts_by_lang[lang].sort_by { |p| p.date }.reverse
      posts.each do |post|
        title = post.data['title']
        date = post.date.strftime('%Y-%m-%d')
        md_url = "#{site.config['url']}#{post.url}.md"
        content << "- [#{title}](#{md_url}): #{date}"
      end
      content << ""
    end

    llms_destination = File.join(site.dest, 'llms.txt')
    FileUtils.mkdir_p(File.dirname(llms_destination))
    File.write(llms_destination, content.join("\n"))
  end

  Jekyll::Hooks.register :site, :post_write do |site|
    site.posts.docs.each do |post|
      source_path = post.path
      next unless source_path && File.exist?(source_path)

      original_content = File.binread(source_path)
      relative_url = post.url.sub(%r{^/}, '')
      next if relative_url.empty?

      destination_path = File.join(site.dest, "#{relative_url}.md")
      FileUtils.mkdir_p(File.dirname(destination_path))
      File.binwrite(destination_path, original_content)
    end

    generate_llms_txt(site)
  end
end
