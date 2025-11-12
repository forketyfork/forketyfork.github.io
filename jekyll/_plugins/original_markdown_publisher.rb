# frozen_string_literal: true

require 'fileutils'

module OriginalMarkdownPublisher
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

    llms_source = File.join(site.source, 'llms.txt')
    if File.exist?(llms_source)
      llms_destination = File.join(site.dest, 'llms.txt')
      FileUtils.mkdir_p(File.dirname(llms_destination))
      FileUtils.cp(llms_source, llms_destination)
    end
  end
end
