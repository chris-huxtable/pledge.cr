# Copyright (c) 2017 Christian Huxtable <chris@huxtable.ca>.
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

	# The current process is forced into a restricted-service operating mode. A
	# few subsets are available, roughly described as computation, memory
	# management, read-write operations on file descriptors, opening of files,
	# networking. In general, these modes were selected by studying the operation
	# of many programs using libc and other such interfaces, and setting promises
	# or execpromises.
	#
	# A process which attempts a restricted operation is killed with an
	# uncatchable SIGABRT.
	#
	# More information is available in the OpenBSD [man pages](http://man.openbsd.org/pledge)
	#
	# ```
	# Process.pledge([:stdio, :rpath, :wpath, :flock])
	# Process.pledge(["stdio", "rpath"], ["/some/exec/promise"])
	# ```
	def self.pledge(promises : Array(String|Symbol), execpromises : Array(String)? = nil)
		{% if flag?(:openbsd) %}
			promises = promises.join(' ')
			execpromises =  execpromises.join(' ') if ( !execpromises.nil? )
			return if ( LibC.pledge(promises, execpromises) == 0 )
			_pledge_error()
		{% else %}
			raise NotImplementedError.new("Process.pledge")
		{% end %}
	end

	# Similar to `Process.pledge(promises, execpromises)`.
	#
	# ```
	# Process.pledge(:stdio, :rpath, :wpath, :flock)
	# Process.pledge("stdio", "rpath")
	# ```
	def self.pledge(*promises : String|Symbol)
		{% if flag?(:openbsd) %}
			return if ( LibC.pledge(promises.join(' '), nil) == 0 )
			_pledge_error()
		{% else %}
			raise NotImplementedError.new("Process.pledge")
		{% end %}
	end

	# Equivilent to calling `Process.pledge("", nil)`.
	#
	# ```
	# Process.pledge()
	# ```
	def self.pledge()
		{% if flag?(:openbsd) %}
			return if ( LibC.pledge("", nil) == 0 )
			_pledge_error()
		{% else %}
			raise NotImplementedError.new("Process.pledge")
		{% end %}
	end

	# :nodoc:
	private def self._pledge_error()
		{% if flag?(:openbsd) %}
			case ( Errno.value )
				when Errno::EFAULT then raise Errno.new("promises or execpromises points outside the process's allocated address space.")
				when Errno::EINVAL then raise Errno.new("promises is malformed or contains invalid keywords.")
				when Errno::EPERM  then raise Errno.new("This process is attempting to increase permissions.")
				else raise Errno.new("...")
			end
		{% else %}
			raise NotImplementedError.new("Process._pledge_error")
		{% end %}
	end

end
