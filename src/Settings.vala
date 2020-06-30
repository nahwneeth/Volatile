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

public class V.Settings : Object {
    private GLib.Settings app_settings;

    private int _window_width;
    private const string _window_width_key = "window-width";
    public int window_width {
        get { return _window_width; }
        set {
            _window_width = value;
            app_settings.set_int(_window_width_key, _window_width);
        }
    }

    private int _window_height;
    private const string _window_height_key = "window-height";
    public int window_height {
        get { return _window_height; }
        set {
            _window_height = value;
            app_settings.set_int(_window_height_key, _window_height);
        }
    }

    private bool _window_maximized;
    private const string _window_maximized_key = "window-maximized";
    public bool window_maximized {
        get { return _window_maximized; }
        set {
            _window_maximized = value;
            app_settings.set_boolean(_window_maximized_key, _window_maximized);
        }
    }

    private int _window_x;
    private const string _window_x_key = "window-x";
    public int window_x {
        get {
            return _window_x;
        }
        set {
            _window_x = value;
            app_settings.set_int(_window_x_key, _window_x);
        }
    }

    private int _window_y;
    private const string _window_y_key = "window-y";
    public int window_y {
        get { return _window_y; }
        set {
            _window_y = value;
            app_settings.set_int(_window_y_key, _window_y);
        }
    }

    private string? _default_template;
    private const string _default_template_key = "default-template";
    public string? default_template {
        get {
            return _default_template;
        }
        set {
            if(value == "") _default_template = null;
            else _default_template = value;

            app_settings.set_string(
                _default_template_key,
                ((_default_template == null) ? "" : _default_template)
            );
        }
    }

    private string[] _opened_files;
    private const string _opened_files_key = "opened-files";
    public string[] opened_files {
        get { return _opened_files; }
        set {
            _opened_files = value;
            app_settings.set_strv(_opened_files_key, _opened_files);
        }
    }

    private string[] _tab_ids;
    private const string _tab_ids_key = "tab-ids";
    public string[] tab_ids {
        get { return _tab_ids; }
        set {
            _tab_ids = value;
            app_settings.set_strv(_tab_ids_key, _tab_ids);
        }
    }

    private string _shown_tab_id;
    private const string _shown_tab_id_key = "show-tab-id";
    public string shown_tab_id {
        get { return _shown_tab_id; }
        set {
            _shown_tab_id = value;
            app_settings.set_string(_shown_tab_id_key, _shown_tab_id);
        }
    }

    public const int ASK = 0;
    public const int SAVE = 1;
    public const int DONT_SAVE = 2;
    private int _save_preference;
    private const string _save_preference_key = "save-preference";
    public int save_preference {
        get { return _save_preference; }
        set {
            _save_preference = value;
            app_settings.set_int(_save_preference_key, _save_preference);
        }
    }

    private int _main_pane_pos;
    private const string _main_pane_pos_key = "main-pane-pos";
    public int main_pane_pos {
        get { return _main_pane_pos; }
        set {
            _main_pane_pos = value;
            app_settings.set_int (_main_pane_pos_key, _main_pane_pos);
        }
    }

    private int _tests_pane_pos;
    private const string _tests_pane_pos_key = "tests-pane-pos";
    public int tests_pane_pos {
        get { return _tests_pane_pos; }
        set {
            _tests_pane_pos = value;
            app_settings.set_int (_tests_pane_pos_key, _tests_pane_pos);
        }
    }

    public Settings() {
        app_settings = new GLib.Settings(V.Application.APP_ID);

        _window_width = app_settings.get_int(_window_width_key);
        _window_height = app_settings.get_int(_window_height_key);
        _window_maximized = app_settings.get_boolean(_window_maximized_key);
        _window_x = app_settings.get_int(_window_x_key);
        _window_y = app_settings.get_int(_window_y_key);
        default_template = app_settings.get_string(_default_template_key); 
        _opened_files = app_settings.get_strv(_opened_files_key);
        _tab_ids = app_settings.get_strv(_tab_ids_key);
        _shown_tab_id = app_settings.get_string(_shown_tab_id_key);
        _save_preference = app_settings.get_int(_save_preference_key);
        _main_pane_pos = app_settings.get_int(_main_pane_pos_key);
        _tests_pane_pos = app_settings.get_int(_tests_pane_pos_key);
    }
}