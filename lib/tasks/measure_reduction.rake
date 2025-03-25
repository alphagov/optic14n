namespace :opt do
  desc "Measure reduction from canonicalisation"
  task :measure, [:filename, :output_file] do |_, args|
    filename = args[:filename]
    output_file = args[:output_file]

    Optic14n::CanonicalizedUrls.from_urls(File.read(filename).each_line).tap do |urls|
      urls.write(output_file) if output_file

      puts "#{urls.seen} urls seen, #{urls.size} after canonicalisation"
    end
  end
end
