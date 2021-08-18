# frozen_string_literal: true

require 'forwardable'

module Spiderb
  # Saves documents to disk and rewrites links
  class Persistence
    attr_reader :destination

    def initialize(destination:, tags: tags)
      @destination = Pathname.new(destination)
      @mutex = Mutex.new
      @tags = tags
    end

    def save(document)
      @mutex.synchronize do
        path = fullpath(document)
        puts "[thread #{Thread.current[:id]}] saving #{document.url} to #{path}"
        mkdir(path.dirname)
        File.write(path, document.body)
        files[Spiderb::URL.of(document.url)] = [document.type, path]
      end
    end

    def rewrite_links
      files.each do |url, tuple|
        type, path = tuple

        puts "[thread #{Thread.current[:id]}] re-writing #{path} (url: #{url})"

        document = Document.new(
          body: File.read(path),
          type: type,
          url: url,
          tags: tags
        )

        document.rewrite_links do |link|
          href = url.merge(link)
          rewritten(href, path)
        end

        path.write(document.body)
      end
    end

    private

    def files
      @files ||= {}
    end

    def fullpath(document)
      relative = Pathname.new(document.url.path).relative_path_from('/')
      path = destination / document.url.host / relative
      path += 'index.html' if add_index?(path, relative, document.type)
      path
    end

    def add_index?(path, relative, type)
      path.to_s.end_with?('/') ||
        relative == '' ||
        path.directory? ||
        (type == 'text/html' && !path.basename.to_s.match?(/.html?$/))
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
      puts "[thread #{Thread.current[:id]}] moving #{path} to #{newpath}"
      newpath.write(content)
      files
        .select { |_url, filepath| filepath == path }
        .each { |url, _filepath| files[url][1] = newpath }
    end

    def rewritten(href, path)
      new_tuple = files[href]

      if new_tuple
        new_href = new_tuple[1].relative_path_from(path.dirname).to_s
        puts "[thread #{Thread.current[:id]}]   * #{href} -> #{new_href}"
        new_href
      else
        puts "Unknown URL to rewrite: #{href}"
      end
    end
  end
end
