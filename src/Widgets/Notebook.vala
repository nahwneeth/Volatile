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

public class V.Notebook : Granite.Widgets.DynamicNotebook {
    V.Settings settings = V.Application.settings;
    public V.Window window {get; construct;}

    public Notebook(V.Window window) {
        Object(window: window);
    }

    public V.Tab get_shown_tab() {
        return (V.Tab) current;
    }
    
    construct {
        string[] file_paths = settings.opened_files;
        string[] tab_ids = settings.tab_ids;
        for(int i = 0; i < file_paths.length; ++i) {
            var file = File.new_for_path(file_paths[i]);
            if(file.query_exists()) {
                var creation_type = V.CreationType.OPEN;
                if(V.Path.temp_dir() + file.get_basename() == file.get_path()) {
                    creation_type = V.CreationType.TEMP;
                }
                create_tab(file, tab_ids[i], creation_type);
            }
        }

        if(n_tabs == 0) create_temp_tab();
        else set_current_by_id(settings.shown_tab_id);

        construct_menu();
        set_event_handlers();
        save_opened_file_paths();
    }

    void set_event_handlers() {
        new_tab_requested.connect(create_temp_tab);
        tab_added.connect((_) => { save_opened_file_paths(); });
        tab_reordered.connect((_,__) => { save_opened_file_paths(); });
        close_tab_requested.connect(close_tab);
        tab_removed.connect((_) => {
            if(n_tabs == 0) create_temp_tab();
            save_opened_file_paths();
        });
    }

    void save_opened_file_paths() {
        string[] opened_file_paths = new string[n_tabs];
        string[] tab_ids = new string[n_tabs];
        int i = 0;
        tabs.foreach((tab) => {
            opened_file_paths[i] = ((V.Tab) tab).file.get_path();
            tab_ids[i] = ((V.Tab) tab).id;
            ++i;
        });
        settings.opened_files = opened_file_paths;
        settings.tab_ids = tab_ids;
    }

    void create_tab(File file, string? id, V.CreationType creation_type) {
        string? tab_id = id;
        if(tab_id == null) {
            tab_id = (new DateTime.now_local()).to_unix().to_string() + "_" + n_tabs.to_string();
        }

        var tab = new V.Tab(file, tab_id, creation_type, window);
        tab.notify["file"].connect(save_opened_file_paths);
        insert_tab(tab, n_tabs);
        current = tab;
    }

    public void create_temp_tab() {
        DirUtils.create_with_parents(V.Path.templates_dir(), 0755);
        DirUtils.create_with_parents(V.Path.temp_dir(), 0755);
        
        File file = V.FileRoutines.get_new_temp_file_with_content_from(settings.default_template);
        create_tab(file, null, V.CreationType.TEMP);
    }

    bool close_tab(Granite.Widgets.Tab gtab) {
        var tab = (V.Tab) gtab;
        if(tab.creation_type == V.CreationType.TEMP) {
            return handle_temp_file_deletion(tab);
        } else {
            tab.save();
            return true;
        }
    }

    public void open_file() {
        var file_chooser = new FileChooser(window);
        File file_to_open = file_chooser.get_selection(V.FileChooserType.OPEN);
        if(file_to_open != null && !show_if_open(file_to_open)) {
            create_tab(file_to_open, null, V.CreationType.OPEN);
        }
    }

    bool handle_temp_file_deletion(V.Tab tab) {
        var save_dialog = new V.SaveDialog(window);
        bool? should_save = true;
        if(save_dialog.ask(out should_save)) {
            if(should_save != null && should_save) return tab.save_as_or_move_if_temporary();
            else {
                return tab.delete_files();
            }
        }
        return false;
    }

    bool show_if_open(File file) {
        for(int i = 0; i < tabs.length(); ++i) {
            if (((V.Tab)tabs.nth_data(i)).file.get_path() == file.get_path()) {
                current = tabs.nth_data(i);
                return true;
            }
        }
        return false;
    }

    bool set_current_by_id(string id) {
        for(int i = 0; i < tabs.length(); ++i) {
            if (((V.Tab)tabs.nth_data(i)).id == id) {
                current = tabs.nth_data(i);
                return true;
            }
        }
        return false;
    }

    void construct_menu() {
        var open_option = new Gtk.MenuItem.with_label("Open");
        open_option.activate.connect(open_file);
        open_option.show_all();

        var seperator = new Gtk.SeparatorMenuItem();
        seperator.show_all();

        menu.add(open_option);
        menu.add(seperator);

        var empty_template_option = new Gtk.RadioMenuItem.with_label_from_widget(null, "Empty File");
        empty_template_option.toggled.connect(() => {
            if(empty_template_option.active) settings.default_template = null;
        });
        menu.add(empty_template_option);
        empty_template_option.show_all();

        var template_names = V.FileRoutines.get_file_names(V.Path.templates_dir());
        bool is_any_active = false;
        template_names.foreach((template_name) => {
            var template_item = new Gtk.RadioMenuItem.with_label_from_widget(empty_template_option, template_name);
            if(template_name == settings.default_template) template_item.active = is_any_active = true;
            template_item.toggled.connect(() => {
                if(template_item.active) settings.default_template = template_name;
            });
            menu.add(template_item);
            template_item.show_all();
            return true;
        });

        if(!is_any_active) {
            empty_template_option.active = true;
            settings.default_template = null;
        }
    }
}