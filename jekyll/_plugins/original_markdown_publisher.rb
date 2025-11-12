# frozen_string_literal: true

require 'fileutils'
require 'yaml'
require 'date'

module OriginalMarkdownPublisher
  def self.generate_llms_txt(site)
    all_posts = if site.config['languages']
                  languages = site.config['languages'] || ['en']
                  languages.flat_map do |lang|
                    posts_dir = if lang == site.config['default_lang']
                                  File.join(site.source, '_posts')
                                else
                                  File.join(site.source, '_posts', lang)
                                end

                    next [] unless Dir.exist?(posts_dir)

                    Dir.glob(File.join(posts_dir, '*.md')).map do |file|
                      begin
                        content = File.read(file)
                        if content =~ /\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)/m
                          data = YAML.safe_load(Regexp.last_match(1))
                          {
                            lang: data['lang'] || site.config['default_lang'],
                            title: data['title'],
                            date: data['date'],
                            file: file
                          }
                        end
                      rescue StandardError
                        nil
                      end
                    end.compact
                  end.compact
                else
                  site.posts.docs.map do |post|
                    {
                      lang: post.data['lang'] || 'en',
                      title: post.data['title'],
                      date: post.date,
                      url: post.url
                    }
                  end
                end

    posts_by_lang = all_posts.group_by { |post| post[:lang] }

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

      posts = posts_by_lang[lang].sort_by { |p| p[:date].is_a?(Date) ? p[:date] : Date.parse(p[:date].to_s) }.reverse
      posts.each do |post|
        title = post[:title]
        date_obj = post[:date].is_a?(Date) ? post[:date] : Date.parse(post[:date].to_s)
        date = date_obj.strftime('%Y-%m-%d')

        url = if post[:url]
                post[:url]
              else
                filename = File.basename(post[:file], '.md')
                match = filename.match(/^(\d{4})-(\d{2})-(\d{2})-(.+)$/)
                slug = match[4]
                if lang == 'en'
                  "/blog/#{match[1]}/#{match[2]}/#{match[3]}/#{slug}/"
                else
                  "/#{lang}/blog/#{match[1]}/#{match[2]}/#{match[3]}/#{slug}/"
                end
              end

        url = url.chomp('/')
        md_url = "#{site.config['url']}#{url}.md"
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
      relative_url = post.url.sub(%r{^/}, '').chomp('/')
      next if relative_url.empty?

      destination_path = File.join(site.dest, "#{relative_url}.md")
      FileUtils.mkdir_p(File.dirname(destination_path))
      File.binwrite(destination_path, original_content)
    end

    generate_llms_txt(site)
  end
end
