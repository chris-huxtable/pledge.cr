# Copyright (c) 2021 joshua stein <jcs@jcs.org>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

require "./lib_c/unistd"

class Process
  class UnveilError < Exception
    include SystemError
  end

  # The first call to unveil that specifies a path removes visibility of the
  # entire filesystem from all other filesystem-related system calls (such as
  # open(2), chmod(2) and rename(2)), except for the specified path and
  # permissions.
  #
  # The unveil system call remains capable of traversing to any path in the
  # filesystem, so additional calls can set permissions at other points in the
  # filesystem hierarchy.
  #
  # After establishing a collection of path and permissions rules, future calls
  # to unveil can be disabled by calling Process.unveil.
  #
  # More information is available in the OpenBSD [man pages](http://man.openbsd.org/unveil).
  #
  # To restrict a process's view of the filesystem:
  # ```
  # Process.unveil({"/home/foo/bar" => "r", "/home/foo/bar/data" => "rwc"})
  # Process.unveil
  # ```
  def self.unveil(paths : Hash(String, String))
    {% if flag?(:openbsd) %}
      if paths.size == 0
        if LibC.unveil(nil, nil) != 0
          case Errno.value
          when Errno::EPERM
            raise UnveilError.new("unveil already locked")
          else
            raise UnveilError.from_errno("unveil")
          end
        end
      else
        paths.each do |path, permission|
          if LibC.unveil(path, permission) != 0
            case Errno.value
            when Errno::E2BIG
              raise UnveilError.new("unveiled path list too large")
            when Errno::ENOENT
              raise UnveilError.new("directory in #{path} does not exist")
            when Errno::EINVAL
              raise UnveilError.new("invalid permissions #{permission.inspect}")
            when Errno::EPERM
              raise UnveilError.new("attempt to increase permissions, path not accessible, or already locked")
            else
              raise UnveilError.from_errno("unveil")
            end
          end
        end
      end
    {% else %}
      raise NotImplementedError.new("Process.unveil")
    {% end %}
  end

  def self.unveil
    unveil({} of String => String)
  end
end
