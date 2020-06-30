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

public enum V.CreationType { OPEN, TEMP }

public class V.Tab : Granite.Widgets.Tab {
    public string id {get; construct;}
    public File file {get; set construct;}
    public V.CreationType creation_type {get; set construct;}
    public V.Window window {get; construct;}
    uint timeout_id = 0;
    
    private V.Settings settings = V.Application.settings;
    public V.SourceView view;
    public V.IOPane tests_pane;
    public Gtk.Paned main_pane;
    public Gtk.Grid grid;
    public Gtk.Overlay overlay;
    public Granite.Widgets.OverlayBar overlaybar;

    public Tab(File file, string id, V.CreationType creation_type, V.Window window) {
        Object(
            id: id,
            file: file,
            creation_type: creation_type,
            window: window,

            label: file.get_basename()
        );
    }

    construct {
        view = new V.SourceView();
        var scrolled_window = new Gtk.ScrolledWindow (null, null);
        scrolled_window.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        scrolled_window.add(view);
        scrolled_window.hexpand = true;
        scrolled_window.vexpand = true;

        tests_pane = new V.IOPane(this);
        tests_pane.position = settings.tests_pane_pos;
        
        main_pane = new Gtk.Paned(Gtk.Orientation.HORIZONTAL);
        main_pane.add1(scrolled_window);
        main_pane.add2(tests_pane);
        main_pane.position = settings.main_pane_pos;

        overlay = new Gtk.Overlay ();
        overlay.add (main_pane);

        grid = new Gtk.Grid();
        grid.add(overlay);

        page = grid;

        string contents = "";
        try {
            FileUtils.get_contents(file.get_path(), out contents);
            view.buffer.text = contents;
        } catch (Error e) {
            print("Error while getting contents in V.Tab.construct: %s\n", e.message);
        }

        timeout_id = Timeout.add_seconds(1, ()=> {
            if(view.buffer.get_modified()) save();
            return true;
        });

        construct_menu();
        bind_pane_positions();
        window.set_focus(view);
    }

    ~Tab() {
        if (timeout_id != 0){
            Source.remove(timeout_id);   
            timeout_id = 0;
        }
    }

    public void save() {
        try {
            FileUtils.set_contents(file.get_path(), view.buffer.text);
            view.buffer.set_modified(false);
        } catch (Error e) {
            print("Error in V.Tab.save(): %s\n", e.message);
        }
    }

    public string executable_path() {
        return (V.Path.executables_dir() + id);
    }

    public async void run() {
        show_overlay_bar("Running");
        save();
        yield tests_pane.compile_and_run();
        hide_overlay_bar(null);
    }

    public bool move_file_to(File dest_file) {
        try {
            file.move(dest_file, FileCopyFlags.OVERWRITE);
            file = dest_file;
            creation_type = V.CreationType.OPEN;
            label = file.get_basename();
            save();
            return true;
        } catch(Error e) {
            print("Error in V.Tab.move_file_to(File): %s\n", e.message);
            return false;
        }
    }

    public bool save_as_or_move_if_temporary() {
        var file_chooser = new V.FileChooser(window);
        File save_to_file = file_chooser.get_selection(V.FileChooserType.SAVE_AS);
        if (save_to_file != null) {
            if(creation_type == V.CreationType.TEMP) {
                return move_file_to(save_to_file);
            } else {
                try {
                    FileUtils.set_contents(save_to_file.get_path(), view.buffer.text);
                    return true;
                } catch(Error e) {
                    print("Error in V.Tab.save_as_or_move_if_temporary(): %s\n", e.message);
                    return false;
                }
            }
        }
        return false;
    }

    void construct_menu() {
        var save_as_option = new Gtk.MenuItem.with_label("Save As");
        save_as_option.activate.connect(() => { save_as_or_move_if_temporary(); });
        menu.add(save_as_option);
        save_as_option.show_all();
    }

    void bind_pane_positions() {
        tests_pane.bind_property("position", settings, "tests-pane-pos", BindingFlags.BIDIRECTIONAL);
        main_pane.bind_property("position", settings, "main-pane-pos", BindingFlags.BIDIRECTIONAL);
    }

    public bool delete_files() {
        try{
            file.delete();
            FileUtils.remove(V.Path.executables_dir() + id);
            FileUtils.remove(V.Path.inputs_dir() + id);
            return true;
        } catch (Error e) {
            print("Error while deleting file in V.Tab.delete_files: %s\n", e.message);
            return false;
        }
    }

    public void show_overlay_bar (string label) {
        overlaybar = new Granite.Widgets.OverlayBar(overlay);
        overlaybar.label = label;
        overlaybar.active = true;
        overlaybar.halign = Gtk.Align.END;
        overlaybar.show_all();
    }

    public void hide_overlay_bar (string? label) {
        if (label == null) {
            overlaybar.destroy ();
        } else {
            overlaybar.label = label;
            overlaybar.active = false;
            GLib.Timeout.add_seconds (1, () => {
                overlaybar.destroy ();
                return false;
            });
        }
    }
}