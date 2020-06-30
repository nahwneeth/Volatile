/*
    Copyright (C) 2020  Navaneeth P <navaneethp123@outlook.com>
    
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

class V.System {
    string final_string;
    uint timeout;

    public async string call(string path_to_file, string path_to_exec, string? input, uint exec_time_limit) {
        this.timeout = exec_time_limit;
        GLib.DirUtils.create_with_parents(V.Path.executables_dir(), 0755);
        final_string = "";

        string path_to_file_quoted = "\"" + path_to_file + "\"";
        
        if (compile(path_to_file_quoted, path_to_exec)) {
            yield run(path_to_exec, input);
        }
        
        return final_string;
    }

    bool compile(string path_to_file, string path_to_exec) {
        string command = "g++ " + path_to_file + " -o " + path_to_exec;
        string? output_string;
        string? error_string;
        int ret;
        
        try {
            GLib.Process.spawn_command_line_sync(command, out output_string, out error_string, out ret);
        } catch(GLib.Error e) {
            print("Error: spawn_command_line_sync: %s\n", e.message);
            return false;
        } 
        
        final_string = output_string + error_string;
        if(final_string != "") final_string += "\n";
        
        return (ret == 0);
    }

    async void run(string path_to_exec, string? input) {
        bool was_forced = false;
        string? output_string = null;
        string? error_string = null;

        GLib.Subprocess run_subp = null;
        try {
            run_subp = new GLib.Subprocess.newv(
                {path_to_exec}, 
                SubprocessFlags.STDIN_PIPE | 
                SubprocessFlags.STDOUT_PIPE |
                SubprocessFlags.STDERR_PIPE);
        } catch(GLib.Error e) {
            print("Error while creating subprocess in V.System.run(string,string?): %s\n", e.message);
        }

        run_subp.communicate_utf8_async.begin(input, null, (obj, res) => {
            try {
                run_subp.communicate_utf8_async.end(res, out output_string, out error_string);
            } catch(GLib.Error e) {
                print("Error while communicating with subprocess in V.System.run(string,string?): %s\n", e.message);
            }

            if(!was_forced && output_string != null && output_string.length <= 100000) {
                final_string += output_string;
            }

            if(output_string.length > 100000) {
                final_string += "Output greater than 100_000 characters\n";
            }

            if(!was_forced && error_string != null) {
                final_string += error_string;
            }

            if(was_forced) {
                final_string += "Timelimit Exceeded " + timeout.to_string() + "s\n";
            }

            if(run_subp.get_if_signaled ()) {
                add_term_signal (run_subp.get_term_sig ());
            }

            Idle.add(run.callback);
        });

        GLib.Timeout.add_seconds(timeout, () => {
            run_subp.force_exit();
            was_forced = true;
            return false;
        });

        yield;
    }

    void add_term_signal(uint term_signal) {
        string es = "";

        switch(term_signal) {
            case Posix.Signal.FPE : es = "SIGFPE"; break;
            case Posix.Signal.ILL : es = "SIGILL"; break;
            case Posix.Signal.SEGV : es = "SIGSEGV"; break;
            case Posix.Signal.BUS : es = "SIGBUS"; break;
            case Posix.Signal.ABRT : es = "SIGABRT"; break;
            case Posix.Signal.TRAP : es = "SIGTRAP"; break;
            case Posix.Signal.SYS : es = "SIGSYS"; break;
            case Posix.Signal.KILL : es = "SIGKILL"; break;
            default: es = "Unkown term signal received"; break;
        }
        
        final_string += es;
    }
}