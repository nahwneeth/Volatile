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

public class V.Dialog : Gtk.Dialog {
    const string DIALOG_TITLE = "label {font-size: 16pt;}";

    private Gtk.Image image;
    private Gtk.Label title_label;
    private Gtk.Label subtitle_label;
    
    public string icon_name_string {get; construct;}
    public string title_text {get; construct;}
    public string subtitle_text {get; construct;}
    
    public Gee.ArrayList<Gtk.Button> buttons = new Gee.ArrayList<Gtk.Button>();
    public Gtk.Grid grid;
    
    public Dialog(
        Gtk.Window window,
        string icon_name_string,
        string title_text,
        string subtitle_text
    ) {
        Object(
            use_header_bar: (int) false,
            transient_for: window,

            icon_name_string: icon_name_string,
            title_text: title_text,
            subtitle_text: subtitle_text
        );
    }

    construct {
        image = new Gtk.Image.from_icon_name(icon_name_string, Gtk.IconSize.DIALOG);
        image.margin_end = 10;

        title_label = new Gtk.Label(title_text);
        title_label.xalign = 0;

        try {
            var cssp = new Gtk.CssProvider();
            cssp.load_from_data(DIALOG_TITLE);
            title_label.get_style_context().add_provider(cssp, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        } catch(Error e) {}
        //  Granite.Widgets.Utils.set_theming(title_label, DIALOG_TITLE, Gtk.STYLE_CLASS_LABEL, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        subtitle_label = new Gtk.Label(_subtitle_text);

        grid = new Gtk.Grid();
        grid.attach(image, 0, 0, 2, 2);
        grid.attach(title_label, 2, 0);
        grid.attach(subtitle_label, 2, 1);

        grid.margin_start = grid.margin_end = grid.margin_bottom = 10;
        get_content_area().add(grid);
    }

    public void add_dialog_button(
        string label, 
        int response_type, 
        string? class
    ) {
        var button = new Gtk.Button.with_label(label);
        if(class != null) button.get_style_context().add_class(class);
        add_action_widget(button, response_type);
        buttons.add(button);
    }
}