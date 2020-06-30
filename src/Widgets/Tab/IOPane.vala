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

public class V.IOPane : Gtk.Paned {
    private const uint timeout = 2;

    public V.Tab parent_tab {get; construct;}
    public Gtk.SourceView input_source_view;
    private Gtk.SourceView output_source_view;
    uint timeout_id;

    public IOPane(V.Tab parent_tab) {
        Object(
            parent_tab: parent_tab,
            orientation: Gtk.Orientation.VERTICAL
        );
    }

    construct {
        DirUtils.create_with_parents(V.Path.inputs_dir(), 0755);

        var input_box = construct_io_box(
            (input_source_view = new Gtk.SourceView()), 
            "Input"
        );

        timeout_id = Timeout.add_seconds(1, ()=> {
            if(input_source_view.buffer.get_modified()) save_input();
            return true;
        });

        var output_box = construct_io_box(
            (output_source_view = new Gtk.SourceView()),
            "Output"
        );

        pack1(input_box, false, false);
        pack2(output_box, false, false);
        load_input();
    }

    ~IOPane() {
        if (timeout_id != 0){
            Source.remove(timeout_id);   
            timeout_id = 0;
        }
    }

    Gtk.Box construct_io_box(Gtk.SourceView source_view, string box_title) {
        source_view.monospace = true;

        var scrolled_window = new Gtk.ScrolledWindow(null, null);
        scrolled_window.add(source_view);
        scrolled_window.hexpand = true;
        scrolled_window.vexpand = true;

        var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        box.add(new Gtk.Label (box_title));
        box.add(scrolled_window);

        return box;
    }

    public string get_input() {
        return this.input_source_view.buffer.text;
    }

    public void clear_output() {
        this.output_source_view.buffer.text = "";
    }

    public void set_output(string output) {
        this.output_source_view.buffer.text = output;
    }

    public async void compile_and_run() {
        string final_str = "";
                
        new Thread<bool>("sys_call", () => {
            var sys = new V.System();
            sys.call.begin(
                parent_tab.file.get_path(),
                parent_tab.executable_path(),
                get_input(),
                timeout,
                (obj, res) => {
                    final_str = sys.call.end(res);
                    Idle.add(compile_and_run.callback);
                }
            );
            return false;
        });

        yield;
        set_output(final_str);
    }

    public void save_input() {
        try {
            FileUtils.set_contents(V.Path.inputs_dir() + parent_tab.id, input_source_view.buffer.text);
            input_source_view.buffer.set_modified(false);
        } catch (Error e) {
            print("Error in V.IOPane.save_input(): %s\n", e.message);
        }
    }

    public void load_input() {
        try {
            string input = "";
            FileUtils.get_contents(V.Path.inputs_dir() + parent_tab.id, out input);
            input_source_view.buffer.text = input;
        } catch (Error e) {
            print("Error in V.IOPane.load_input(): %s\n", e.message);
        }
    }
}
