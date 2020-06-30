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

public class V.Window : Gtk.ApplicationWindow {
    public weak V.Application app {get; construct;}
    V.Settings settings = V.Application.settings;
    private V.Notebook notebook;
    bool was_resized = false;
    
    public Window(V.Application app) {
        Object(
            application: app,
            app: app,
            title: V.Application.APP_NAME
        );
    }

    construct {
        var gtk_settings = Gtk.Settings.get_default();
        gtk_settings.gtk_application_prefer_dark_theme = true;

        init_actions();
        apply_and_bind_settings();
        delete_event.connect(save_settings);

        notebook = new V.Notebook(this);
        add(notebook);

        disable({});
    }

    void apply_and_bind_settings() {
        set_default_size(settings.window_width, settings.window_height);
        if(settings.window_maximized) maximize();
        
        if(settings.window_x != -1 || settings.window_y != -1) {
            move(settings.window_x, settings.window_y);
        }

        bind_property("is-maximized", settings, "window-maximized");
    }

    public override bool configure_event(Gdk.EventConfigure event) {
        was_resized = true;
        return base.configure_event(event);
    }

    bool save_settings() {
        settings.shown_tab_id = notebook.get_shown_tab().id;

        if(!was_resized) return false;
        
        int width, height;
        get_size(out width, out height);
        settings.window_width = width;
        settings.window_height = height;

        int x, y;
        get_position(out x, out y);
        settings.window_x = x;
        settings.window_y = y;

        was_resized = false;
        return false;
    }

    // A C T I O N S
    public SimpleActionGroup actions;
    Gee.HashMap<string,bool> action_status = new Gee.HashMap<string,bool> ();

    public const string PREFIX = "win.";
    public const string NEW_TAB = "action-new-tab";
    public const string OPEN = "action-open";
    public const string SAVE_AS = "action-save-as";
    public const string RUN = "action-run";
    public const string FOCUS_EDITOR = "action-focus-editor";
    public const string FOCUS_INPUT = "action-focus-input";
    public const string TOGGLE_COMMENT = "action-toggle-comment";
    public const string INSERT_SNIPPET = "action-insert-snippet";
    public const string QUIT = "action-quit";
    
    public static Gee.MultiMap<string,string> action_accelerators = new Gee.HashMultiMap<string,string>();

    public const ActionEntry[] ACTION_ENTRIES = {
        {NEW_TAB, action_new_tab},
        {OPEN, action_open},
        {SAVE_AS, action_save_as},
        {RUN, action_run},
        {FOCUS_EDITOR, action_focus_editor},
        {FOCUS_INPUT, action_focus_input},
        {TOGGLE_COMMENT, action_toggle_comment},
        {INSERT_SNIPPET, action_insert_snippet},
        {QUIT, action_quit}
    };

    void init_actions() {
        actions = new SimpleActionGroup();
        actions.add_action_entries(ACTION_ENTRIES, this);
        insert_action_group("win", actions);

        action_accelerators.set(NEW_TAB, "<Control>t");
        action_accelerators.set(SAVE_AS, "<Control><shift>s");
        action_accelerators.set(OPEN, "<Control>o");
        action_accelerators.set(RUN, "F5");
        action_accelerators.set(FOCUS_EDITOR, "F1");
        action_accelerators.set(FOCUS_INPUT, "F2");
        action_accelerators.set(TOGGLE_COMMENT, "<Control>slash");
        action_accelerators.set(INSERT_SNIPPET, "<Control>i");
        action_accelerators.set(QUIT, "<Control>q");

        foreach(var action in action_accelerators.get_keys()) {
            action_status.set(action, false);

            var accels_array = action_accelerators[action].to_array();
            accels_array += null;

            app.set_accels_for_action(PREFIX + action, accels_array);
        }
    }

    bool does_exist(string action, string[] actions) {
        foreach(var a in actions) {
            if(a == action) {
                return true;
            }
        }
        return false;
    }

    private void enable(string[] actions) {
        action_status.foreach((entry) => {
            action_status[entry.key] = does_exist(entry.key, actions);
            return true;
        });
    }

    private void disable(string[] actions) {
        action_status.foreach ((entry) => {
            action_status[entry.key] = !(does_exist(entry.key, actions));
            return true;
        });
    }

    void action_new_tab() { if(action_status[NEW_TAB]) notebook.create_temp_tab(); }
    void action_open() { if(action_status[OPEN]) notebook.open_file(); }
    void action_save_as() { if(action_status[SAVE_AS]) notebook.get_shown_tab().save_as_or_move_if_temporary(); }
    void action_run() { if(action_status[RUN]) notebook.get_shown_tab().run.begin(); }
    void action_focus_editor() { if(action_status[FOCUS_EDITOR]) set_focus(((V.Tab) notebook.get_shown_tab()).view); }
    void action_focus_input() { if(action_status[FOCUS_INPUT]) set_focus(((V.Tab) notebook.get_shown_tab()).tests_pane.input_source_view); }
    void action_toggle_comment() { if(action_status[TOGGLE_COMMENT]) notebook.get_shown_tab().view.toggle_comment(); }
    void action_insert_snippet() { if(action_status[INSERT_SNIPPET]) notebook.get_shown_tab().view.insert_snippet(); }
    void action_quit() { 
        if(action_status[QUIT]) {
            save_settings();
            destroy();
        }; 
    }
}