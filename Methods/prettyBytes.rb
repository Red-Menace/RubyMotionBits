
# Pretty up a file size into a more human readable form.
# If binary parameter is true use IEC (binary) prefix, otherwise use SI prefix (metric).
def prettyBytes(bytes, binary = true)
   base = binary ? 1024 : 1000
   prefix = binary ? %W(PiB TiB GiB MiB KiB B) : %W(PB TB GB MB KB B)
   size = bytes.to_f
   index = prefix.length - 1
   while size > (base - 1) && index > 0
      index -= 1
      size /= base
   end
   ((size > base || size.modulo(1) < 0.01 ? '%d' : '%.2f') % size) + ' ' + prefix[index]
end

