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

public class V.SaveDialog : V.Dialog {
    private Gtk.CheckButton check_button;
    private V.Settings settings = V.Application.settings;

    public SaveDialog(Gtk.Window window) {
        Object(
            transient_for: window,
            use_header_bar: (int) false,

            icon_name_string: "document-save",
            title_text: "Save Changes",
            subtitle_text: "Do you want to save changes before continuing?"
        );
    }

    construct {
        add_dialog_button("Don't Save", V.Settings.DONT_SAVE, null);
        add_dialog_button("Cancel", Gtk.ResponseType.CLOSE, null);
        add_dialog_button("Save", V.Settings.SAVE, "suggested-action");

        check_button = new Gtk.CheckButton.with_label("Don't ask again");
        check_button.margin_top = 5;
        grid.attach(check_button, 2, 2, 3, 1);
    }

    public bool ask(out bool? should_save) {
        int res_id = settings.save_preference;
        
        if(res_id == V.Settings.ASK) {
            this.show_all();
            present();
    
            set_focus(buttons[1]);
            
            res_id = run();
            destroy();
        }

        switch(res_id) {
            case V.Settings.SAVE:
                if(check_button.active) settings.save_preference = V.Settings.SAVE;
                should_save = true;
                return true;
            case V.Settings.DONT_SAVE:
                if(check_button.active) settings.save_preference = V.Settings.DONT_SAVE;
                should_save = false;
                return true;
            default:
                should_save = null;
                return false;
        }
    }
}