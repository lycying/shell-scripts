#!/usr/bin/python

import os
import re
import sys
import socket
import signal 
import string
import time
from optparse import OptionParser

def print_err(string): print >> sys.stderr, string

def print_debug(string): 
    if verbose:
        print_err(string)

def error_exit(msg):
    print_err('%s: %s' % (sys.argv[0], msg))
    sys.exit(1)
    
def check_java(pid):
    comm = open('/proc/%d/stat' % pid).read().split()[1]
    if comm != '(java)': 
        error_exit('%d %s - Not a Java process' % (pid, comm))

class ProcessError(Exception):
    pass

def attach_and_dump(pid):
    # If necessary, downgrade to JVM user and group, so it accepts the connection
    stat = os.stat('/proc/%d' % pid)
    print_debug("Checking process user and group: %s,%s" % (stat.st_uid, stat.st_gid))
    os.setgid(stat.st_gid)
    os.setuid(stat.st_uid)
    socket = socket_path(pid)
    if not exists(socket):
        start_server(pid, socket)
    return dump(socket)
    
def socket_path(pid): 
    path = '/tmp/.java_pid%d' % pid
    print_debug("Socket path: %s" % path)
    return path
            
def start_server(pid, socket):
    print_debug("Socket file does not exist. Asking process to start server...")
    touch('/proc/%d/cwd/.attach_pid%d' % (pid, pid))
    os.kill(pid, signal.SIGQUIT)
    if not wait_for_existence(socket, wait = 0.05, timeout = 1):
        raise ProcessError('Cannot attach: JVM not responding (or not a Java process)')
    
def touch(path):
    print_debug("Touching " + path)
    f = open(path, 'w')
    try: f.write('')
    finally: f.close()
   
def wait_for_existence(path, wait, timeout):
    print_debug("Waiting for existence of %s..." % path)
    t = 0
    while t < timeout:
        if exists(path):
            return True
        else:
            t += wait
            time.sleep(wait)
    print_debug("Wait timed out after %.2f seconds" % timeout) 
    return False

def exists(path):
    try:
        os.stat(path)
        return True
    except OSError as oe:
        if oe.errno == 2:
            return False
        else:
            raise oe
    
def dump(socket_file):
    protocol_version = '1'
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.connect(socket_file)
    print_debug("Connected to socket")
    try:
        send_string(sock, protocol_version)
        send_string(sock, 'threaddump')
        args = ['', '','  ']
        for arg in args:
            send_string(sock, arg)
        print_debug("Asked for dump, waiting for reply...")
        res = read_all(sock)
        status, dump = string.split(res, "\n", 1)
        print_debug("Reply read. Status: %s." % status)
        if status != "0":
            raise Exception("Invalid status: " + status)
        return dump
    finally:
        sock.close()
        
def send_string(sock, string):
    sock.sendall(string + '\0')

def read_all(sock):
    data = ''
    while True:
        ret = sock.recv(4096)
        if ret:
            data += ret
        else:
            break
    return data

def get_stack_pointers(pid):
    max_addr = 2 ** os.sysconf('SC_LONG_BIT') - 1
    lwp_list = os.listdir('/proc/%d/task' % pid)
    def task_stat_gen():
        for lwp in lwp_list:
            try:
                stat_data = open('/proc/%d/task/%s/stat' % (pid, lwp)).read()
                # Position 29th in /proc/<pid>/task/<lwp>/stat is stack pointer
                pointer = int(stat_data.split()[28])
                # If stack pointer is absent, there is "-1", interpreted as unsigned, so equals max_addr
                if pointer != max_addr:
                    yield int(lwp), pointer
            except IOError, e:
                # Accounting for the fact that a thread can terminate between the moment we
                # ask for the list (directory) and we try to read the file
                if e.errno == 2: print_err('WARN: Missing task: %s' % lwp)
                else: raise
    return dict(task_stat_gen())

class Header(object): pass
class Segment(object): pass

def parse_map_header(parts):
    addr_range = parts[0]
    start, end = addr_range.split('-')
    res = Header()
    res.start = int(start, 16)
    res.end = int(end, 16)
    res.perms = parts[1]
    if len(parts) >= 6:
        res.file = parts[5]
    else:
        res.file = None 
    return res

def parse_size(parts):
    name = parts[0][:-1]
    size = parts[1]
    return name, int(size)

def get_smaps(pid):
    maps = open('/proc/%d/smaps' % pid).read()
    res = []
    curr_map = None
    curr_sizes = {}
    for line in maps.split('\n'):
        if not line: 
            continue
        if line.startswith('VmFlags:'): 
            continue
        parts = line.split()
        if len(parts) > 3:
            # Header line, a new mapping
            if curr_map is not None: 
                res.append((curr_map, curr_sizes))
                curr_sizes = {} 
            curr_map = parse_map_header(parts)
        else:
            # Size line
            category, size = parse_size(parts)
            curr_sizes[category] = size
    if curr_map is not None: 
        res.append((curr_map, curr_sizes))
    return res

class JStackThread: pass

def get_jstack(pid):
    jstack = attach_and_dump(pid)
    def thread_gen():
        for line in jstack.split('\n'):
            mo = re.search(r'"([^"]+)".*tid=(0x[0-9a-f]+).*nid=(0x[0-9a-f]+)', line)
            if mo is not None:
                jthread = JStackThread()
                jthread.name = mo.group(1)
                jthread.tid = int(mo.group(2), 16)
                jthread.nid = int(mo.group(3), 16)
                jthread.esp = None
                # Try to parse stack pointer (not always present and may be zero)
                mo2 = re.search(r'\[(0x[0-9a-f]+)\]', line)
                if mo2 is not None:
                    val = int(mo2.group(1), 16)
                    if val != 0: jthread.esp = val
                yield jthread
    return dict((jthread.nid, jthread) for jthread in thread_gen())

def get_segments(smaps_data):
    for header, sizes in smaps_data:
        t = Segment()
        t.start = header.start
        t.end = header.end
        t.vsize = sizes['Size']
        t.rss = sizes['Rss']
        t.pss = sizes['Pss']
        t.dirty = sizes['Private_Dirty'] + sizes['Shared_Dirty'] 
        t.file = header.file
        t.perms = header.perms
        yield t

excluded_threads = ['CompilerThread0', 'VM Thread']

def associate_stack_segments(segments, pid, jstack, force_jstack):
    stack_pointers = get_stack_pointers(pid)
    if len(stack_pointers) == 0 or force_jstack:
        # Old kernels do not put stack pointers in /proc. Resorting to pointers in jstack,
        # although it misses some (in native threads).
        print_err('WARN: Using java stack pointers, some stack segments will appear as anon')
        stack_pointers = get_stack_pointers_from_jstack(jstack)
    found_segments = {}
    for lwp, esp in stack_pointers.items():
        found_seg = None        
        for seg in segments:
            if esp >= seg.start and esp < seg.end:
                found_seg = seg
                break
        if found_seg is not None:
            found_segments[lwp] = found_seg 
    found_threads = dict((seg, lwp) for lwp, seg in found_segments.items()) # inverse map
    for s in segments:
        s.lwp = found_threads.get(s)
        jthread = jstack.get(s.lwp)
        s.jvm_tid = None
        s.thread_name = None
        if jthread is not None:
            if jthread.name in excluded_threads:
                # Some threads are known to not have an exclusive stack segment
                s.lwp = None
            else:
                s.jvm_tid = jthread.tid 
                s.thread_name = jthread.name

def get_stack_pointers_from_jstack(jthreads):
    return dict((lwp, jthread.esp) for lwp, jthread in jthreads.items())
    
def classify(segments): 
    for s in segments: 
        if s.lwp is not None:
            s.type = '[stack]'
        elif s.file is not None:
            if re.match(r'^\[[a-z]+\]$', s.file): s.type = s.file
            elif s.file.endswith('.jar'): s.type = '[jlib]'
            elif s.file.endswith('/java'): s.type = '[exec]'
            elif re.match('.*.so(.[0-9]+)*$', s.file): s.type = '[vmlib]'
            else: s.type = '[file]'
        else:
            s.type = '[anon]'

def get_totals(segments):
    total_pss = sum(s.pss for s in segments)
    total_rss = sum(s.rss for s in segments)
    total_dirty = sum(s.dirty for s in segments)
    total_vsize = sum(s.vsize for s in segments)
    return total_pss, total_rss, total_dirty, total_vsize

def print_segments(segments, printing_all):
    print '%-16s %9s %9s %9s %10s %-6s %-10s %s' % \
        ('START ADDRESS', 'PSS', 'RSS', 'DIRTY', 'VSIZE', 'PERMS', 'TYPE', 'FILE/THREAD')
    for seg in segments:
        if seg.type == '[stack]':
            if seg.jvm_tid is not None:
                detail = '"%s" lwp=%d jvm_id=%#x' % (seg.thread_name, seg.lwp, seg.jvm_tid)
            else:
                detail = '<non-java thread> pid=%s' % seg.lwp
        elif seg.type in ['[jlib]', '[vmlib]', '[file]', '[exec]']:
            detail = seg.file
        else:
            detail = ''
        print '%016x %9d %9d %9d %10d %-6s %-10s %s' % \
            (seg.start, seg.pss, seg.rss, seg.dirty, seg.vsize, seg.perms, seg.type, detail)
    t_pss, t_rss, t_dirty, t_vsize = get_totals(segments)
    print '%-16s %9d %9d %9d' % ('TOTALS:', t_pss, t_rss, t_dirty),
    if printing_all:
        # Total virtual size only makes sense if printing all segments 
        print ' %9d' % t_vsize
    
def print_summary(segments):
    pss_counter = {}
    rss_counter = {}
    dirty_counter = {}
    vsize_counter = {}
    for seg in segments:
        pss_counter[seg.type] = pss_counter.setdefault(seg.type, 0) + seg.pss
        rss_counter[seg.type] = rss_counter.setdefault(seg.type, 0) + seg.rss
        dirty_counter[seg.type] = dirty_counter.setdefault(seg.type, 0) + seg.dirty
        vsize_counter[seg.type] = vsize_counter.setdefault(seg.type, 0) + seg.vsize
    print '%-10s %9s %9s %9s %10s' % ('TYPE', 'PSS', 'RSS', 'DIRTY', 'VSIZE')
    for stype, pss in sorted(pss_counter.items(), key = lambda (x, y): -y):
        print '%-10s %9s %9s %9s %10s' % (stype, pss, rss_counter[stype], dirty_counter[stype], vsize_counter[stype])
    t_pss, t_rss, t_dirty, t_vsize = get_totals(segments)
    print '%-10s %9d %9d %9d %10d' % ('TOTALS:', t_pss, t_rss, t_dirty, t_vsize)
      
orders = {
    'addr':   lambda s: s.start,
    'pss':    lambda s: -s.pss,
    'rss':    lambda s: -s.rss,
    'dirty':  lambda s: -s.dirty,
    'vsize':  lambda s: -s.vsize,
}

filters = {
    "all":       lambda s: True,
    "rss_only":  lambda s: s.rss > 0,
}

def parse_args():
    parser = OptionParser('usage: %prog [options] pid\n' + 
        'Print memory segments, similarly to pmap, but include information about java threads')
    parser.add_option("-s", "--summary", action = "store_true", dest = "summary", default = False, 
        help = "summarise display with only a total for each segment type")
    parser.add_option("-a", "--all", action = "store_true", dest = "all", default = False, 
        help = "print all segments (default is to only print segments with resident pages)")
    parser.add_option("-o", dest = "order", type = 'choice',  default = 'pss', 
        help = 'sort by ORDER; valid options: pss, rss, dirty, vsize, addr; default: %default', 
        choices = ['pss', 'addr', 'rss', 'dirty', 'vsize'])
    parser.add_option("--use-java-pointers", dest = "force_jpointers", action = 'store_true', default = False, 
        help = 'force the use of jstack to obtain stack pointers for stack segment mapping (default is to ' +
        'use /proc filesystem if possible)')
    parser.add_option('-v', action = 'store_true', dest = 'verbose', help = "activate verbose mode")
    options, args = parser.parse_args()
    if len(args) != 1:
        parser.error('A java pid must be supplied')
    pid = int(args[0])
    return pid, options

verbose = None
    
if __name__ == '__main__':
    pid, options = parse_args()
    verbose = options.verbose
    try:
        check_java(pid)
        segments = list(get_segments(get_smaps(pid)))
        jstack = get_jstack(pid)
        associate_stack_segments(segments, pid, jstack, options.force_jpointers)
        classify(segments)
        try:
            if options.summary:
                print_summary(segments)
            else:
                if options.all: _filter = filters['all']
                else: _filter = filters['rss_only']
                fil_segments = [s for s in segments if _filter(s)]
                print_segments(sorted(fil_segments, key = orders[options.order]), printing_all = options.all)
        except IOError, e:
            if e.errno == 32: pass # ignoring broken pipe for sane shell use
            else: raise
    except EnvironmentError, e:
        error_exit(e)