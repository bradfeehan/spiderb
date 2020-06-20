# frozen_string_literal: true

require 'forwardable'

module Spiderb
  # Saves documents to disk and rewrites links
  class Persistence
    attr_reader :base_url, :destination

    def initialize(base_url:, destination:)
      @base_url = base_url
      @destination = Pathname.new(destination)
    end

    def save(document)
      path = fullpath(base_url.route_to(document.url).to_s)
      mkdir(path.dirname)
      File.write(path, document.body)
      files[Spiderb::URL.of(document.url)] = [document.type, path]
    end

    def rewrite_links
      files.each do |url, tuple|
        type, path = tuple

        document = Document.new(body: File.read(path), type: type, url: url)
        document.rewrite_links do |node|
          href = url.merge(node.content)
          rewritten(href) if href.start_with?(base_url)
        end

        path.write(document.body)
      end
    end

    private

    def files
      @files ||= {}
    end

    def fullpath(relative)
      path = destination / relative
      path += 'index.html' if add_index?(path, relative)
      path
    end

    def add_index?(path, relative)
      path.to_s.end_with?('/') || relative == '' || path.directory?
    end

    def mkdir(path)
      parent = path.dirname

      mkdir(parent) unless parent.directory?

      if path.file?
        indexify(path)
      else
        path.mkdir unless path.directory?
      end
    end

    def indexify(path)
      content = path.read
      path.unlink
      path.mkdir
      newpath = path / 'index.html'
      newpath.write(content)
      files
        .select { |_url, filepath| filepath == path }
        .each { |url, _filepath| files[url][1] = newpath }
    end

    def rewritten(href)
      new_tuple = files[href]

      if new_tuple
        new_tuple[1].relative_path_from(path.dirname).to_s
      else
        puts "Unknown URL to rewrite: #{href}"
      end
    end
  end
end
