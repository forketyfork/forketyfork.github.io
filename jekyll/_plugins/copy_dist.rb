Jekyll::Hooks.register :site, :post_write do |site|
  # dist_dir is in the same directory as the Jekyll source  
  dist_dir = File.join(site.source, 'dist')
  site_dir = site.dest
  
  if Dir.exist?(dist_dir)
    # Copy only the contents, not the dist directory itself
    Dir.glob(File.join(dist_dir, '*')).each do |item|
      if File.directory?(item)
        # For directories, copy contents to site_dir maintaining structure
        FileUtils.cp_r(item, site_dir)
      else
        # For files, copy directly to site_dir
        FileUtils.cp(item, site_dir)
      end
    end
  end
end