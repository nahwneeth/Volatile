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

public enum V.FileChooserType {
    NEW,
    OPEN,
    SAVE_AS
}

public class V.FileChooser {
    private Gtk.Window parent_window;
    private Gtk.FileFilter text_files_filter;

    public FileChooser(Gtk.Window window) {
        parent_window = window;

        text_files_filter = new Gtk.FileFilter();
        text_files_filter.set_filter_name("Text files");
        text_files_filter.add_mime_type("text/*");
    }

    Gtk.FileChooserNative? get_file_chooser(V.FileChooserType type) {
        string title;
        Gtk.FileChooserAction action;
        bool do_overwrite_confirmation;
        string accept_label;

        switch(type) {
            case V.FileChooserType.NEW:
                title = "New File";
                action = Gtk.FileChooserAction.SAVE;
                do_overwrite_confirmation = true;
                accept_label = "Create";
                break;
            case V.FileChooserType.OPEN:
                title = "Open File";
                action = Gtk.FileChooserAction.OPEN;
                do_overwrite_confirmation = false;
                accept_label = "Open";
                break;
            case V.FileChooserType.SAVE_AS:
                title = "Save File As";
                action = Gtk.FileChooserAction.SAVE;
                do_overwrite_confirmation = true;
                accept_label = "Save";
                break;
            default:
                return null;
        }

        var file_chooser = new Gtk.FileChooserNative(
            title,
            parent_window,
            action,
            accept_label,
            "Cancel"
        );

        file_chooser.do_overwrite_confirmation = do_overwrite_confirmation;
        file_chooser.select_multiple = false;
        file_chooser.add_filter(text_files_filter);

        return file_chooser;
    }

    public File? get_selection(V.FileChooserType type) {
        var file_chooser = get_file_chooser(type);

        if(file_chooser == null) return null;
        
        var response_value = file_chooser.run();
        if(response_value == Gtk.ResponseType.ACCEPT) {
            return file_chooser.get_file();
        }

        return null;
    }
}